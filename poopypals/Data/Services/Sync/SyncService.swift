//
//  SyncService.swift
//  PoopyPals
//
//  Background sync service for offline-first data synchronization
//

import Foundation

@MainActor
class SyncService: ObservableObject {
    static let shared = SyncService()
    
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    
    private let cacheManager: LocalCacheManager
    private let deviceService: DeviceIdentificationService
    private let supabaseService: SupabaseService
    
    private var backgroundSyncTask: Task<Void, Never>?
    private let syncInterval: TimeInterval = 300 // 5 minutes
    
    private init() {
        self.cacheManager = LocalCacheManager.shared
        self.deviceService = DeviceIdentificationService()
        self.supabaseService = SupabaseService.shared
        
        // Load last sync date
        self.lastSyncDate = cacheManager.loadDate(forKey: .lastSyncDate)
    }
    
    // MARK: - Queue Management
    
    func enqueue(item: SyncItem) throws {
        var queue = try loadQueue()
        queue.append(item)
        try saveQueue(queue)
    }
    
    func dequeue() throws -> SyncItem? {
        var queue = try loadQueue()
        guard !queue.isEmpty else { return nil }
        
        let item = queue.removeFirst()
        try saveQueue(queue)
        return item
    }
    
    func removeFromQueue(id: UUID) throws {
        var queue = try loadQueue()
        queue.removeAll { $0.id == id }
        try saveQueue(queue)
    }
    
    private func loadQueue() throws -> [SyncItem] {
        return try cacheManager.loadArray(SyncItem.self, forKey: .syncQueue)
    }
    
    private func saveQueue(_ queue: [SyncItem]) throws {
        try cacheManager.saveArray(queue, forKey: .syncQueue)
    }
    
    // MARK: - Sync Operations
    
    func syncNow() async throws {
        guard !isSyncing else { return }
        
        BackendLogger.shared.logInfo("🔄 Starting sync...")
        isSyncing = true
        defer { 
            isSyncing = false
            BackendLogger.shared.logInfo("✅ Sync completed")
        }
        
        // 1. Upload local changes
        BackendLogger.shared.logInfo("📤 Uploading local changes...")
        try await uploadLocalChanges()
        
        // 2. Download remote changes
        BackendLogger.shared.logInfo("📥 Downloading remote changes...")
        try await downloadRemoteChanges()
        
        // 3. Update last sync date
        lastSyncDate = Date()
        cacheManager.saveDate(lastSyncDate!, forKey: .lastSyncDate)
        BackendLogger.shared.logInfo("💾 Last sync date updated")
    }
    
    // MARK: - Upload Local Changes
    
    private func uploadLocalChanges() async throws {
        var queue = try loadQueue()
        guard !queue.isEmpty else { return }
        
        let deviceId = try await deviceService.getDeviceId()
        var processedItems: [UUID] = []
        
        for item in queue {
            do {
                try await RetryUtility.retry {
                    try await processSyncItem(item, deviceId: deviceId)
                }
                
                processedItems.append(item.id)
            } catch {
                // Increment retry count
                if queue.first(where: { $0.id == item.id }) != nil {
                    var updatedQueue = queue
                    if let index = updatedQueue.firstIndex(where: { $0.id == item.id }) {
                        var itemCopy = updatedQueue[index]
                        itemCopy = SyncItem(
                            id: itemCopy.id,
                            type: itemCopy.type,
                            action: itemCopy.action,
                            data: itemCopy.data,
                            createdAt: itemCopy.createdAt,
                            retryCount: itemCopy.retryCount + 1
                        )
                        updatedQueue[index] = itemCopy
                        
                        // Remove if retry count exceeded
                        if itemCopy.retryCount >= 3 {
                            updatedQueue.remove(at: index)
                        } else {
                            queue = updatedQueue
                        }
                    }
                }
            }
        }
        
        // Remove processed items
        queue.removeAll { processedItems.contains($0.id) }
        try saveQueue(queue)
    }
    
    private func processSyncItem(_ item: SyncItem, deviceId: UUID) async throws {
        switch item.type {
        case .poopLog:
            try await processPoopLogSync(item, deviceId: deviceId)
        case .achievement:
            try await processAchievementSync(item, deviceId: deviceId)
        case .deviceStats:
            try await processDeviceStatsSync(item, deviceId: deviceId)
        }
    }
    
    private func processPoopLogSync(_ item: SyncItem, deviceId: UUID) async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let dto = try decoder.decode(PoopLogDTO.self, from: item.data)
        
        let remoteDataSource = SupabasePoopLogDataSource()
        
        switch item.action {
        case .create:
            _ = try await remoteDataSource.createLog(deviceId: deviceId, log: dto)
        case .update:
            _ = try await remoteDataSource.updateLog(deviceId: deviceId, log: dto)
        case .delete:
            guard let id = dto.id else { return }
            try await remoteDataSource.deleteLog(deviceId: deviceId, id: id)
        }
    }
    
    private func processAchievementSync(_ item: SyncItem, deviceId: UUID) async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let dto = try decoder.decode(AchievementDTO.self, from: item.data)
        
        let remoteDataSource = SupabaseAchievementDataSource()
        
        switch item.action {
        case .create:
            _ = try await remoteDataSource.unlockAchievement(deviceId: deviceId, achievement: dto)
        case .update:
            // Achievements are typically only created, not updated
            break
        case .delete:
            // Achievements are not deleted
            break
        }
    }
    
    private func processDeviceStatsSync(_ item: SyncItem, deviceId: UUID) async throws {
        // Device stats are updated via RPC, not queued
        // This is a placeholder for future implementation
    }
    
    // MARK: - Download Remote Changes
    
    private func downloadRemoteChanges() async throws {
        let deviceId = try await deviceService.getDeviceId()
        let lastSync = lastSyncDate ?? Date.distantPast
        
        // Fetch logs updated since last sync
        let remoteDataSource = SupabasePoopLogDataSource()
        let remoteLogs = try await remoteDataSource.fetchLogs(deviceId: deviceId, limit: 100, offset: 0)
        
        // Filter by updatedAt > lastSync
        let newLogs = remoteLogs.filter { $0.updatedAt > lastSync }
        
        // Merge with local (conflict resolution)
        let localDataSource = LocalPoopLogDataSource()
        let localLogs = try localDataSource.loadLogs()
        
        var merged: [PoopLogDTO] = localLogs
        
        for remoteLog in newLogs {
            if let existingIndex = merged.firstIndex(where: { $0.id == remoteLog.id }) {
                // Conflict: last-write-wins
                if remoteLog.updatedAt > merged[existingIndex].updatedAt {
                    merged[existingIndex] = remoteLog
                }
            } else {
                // New log
                merged.append(remoteLog)
            }
        }
        
        try localDataSource.saveLogs(merged)
    }
    
    // MARK: - Background Sync
    
    func startBackgroundSync() {
        stopBackgroundSync() // Stop existing if any
        
        backgroundSyncTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(syncInterval * 1_000_000_000))
                
                if !Task.isCancelled {
                    try? await syncNow()
                }
            }
        }
    }
    
    func stopBackgroundSync() {
        backgroundSyncTask?.cancel()
        backgroundSyncTask = nil
    }
}

