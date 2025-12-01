//
//  PoopLogRepository.swift
//  PoopyPals
//
//  Repository implementation for PoopLog (Data Layer)
//

import Foundation

class PoopLogRepository: PoopLogRepositoryProtocol {
    private let localDataSource: LocalPoopLogDataSourceProtocol
    private let remoteDataSource: RemotePoopLogDataSourceProtocol
    private let deviceService: DeviceIdentificationService
    private let syncService: SyncService
    
    init(
        localDataSource: LocalPoopLogDataSourceProtocol = LocalPoopLogDataSource(),
        remoteDataSource: RemotePoopLogDataSourceProtocol? = nil,
        deviceService: DeviceIdentificationService = DeviceIdentificationService(),
        syncService: SyncService? = nil
    ) {
        let remote = remoteDataSource ?? SupabasePoopLogDataSource()
        let sync = syncService ?? SyncService.shared
        self.localDataSource = localDataSource
        self.remoteDataSource = remote
        self.deviceService = deviceService
        self.syncService = sync
    }
    
    // MARK: - Fetch Operations (Offline-First)
    
    func fetchLogs(limit: Int, offset: Int) async throws -> [PoopLog] {
        // Read from local first
        let localDTOs = try localDataSource.loadLogs()
        let localLogs = localDTOs.map { $0.toDomain() }
        
        // Return local data immediately
        let paginatedLogs = Array(localLogs.dropFirst(offset).prefix(limit))
        
        // Background: Refresh from remote
        Task {
            do {
                let deviceId = try await deviceService.getDeviceId()
                let remoteDTOs = try await remoteDataSource.fetchLogs(
                    deviceId: deviceId,
                    limit: limit,
                    offset: offset
                )
                
                // Merge with local (conflict resolution)
                let mergedDTOs = try await mergeLogs(local: localDTOs, remote: remoteDTOs)
                try localDataSource.saveLogs(mergedDTOs)
            } catch {
                // Silently fail background refresh
                print("Background refresh failed: \(error)")
            }
        }
        
        return paginatedLogs
    }
    
    func fetchTodayLogs() async throws -> [PoopLog] {
        // Read from local first
        let localDTOs = try localDataSource.loadLogs()
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let todayLogs = localDTOs
            .filter { log in
                log.loggedAt >= today && log.loggedAt < tomorrow
            }
            .map { $0.toDomain() }
        
        // Background: Refresh from remote
        Task {
            do {
                let deviceId = try await deviceService.getDeviceId()
                let remoteDTOs = try await remoteDataSource.fetchTodayLogs(deviceId: deviceId)
                let mergedDTOs = try await mergeLogs(local: localDTOs, remote: remoteDTOs)
                try localDataSource.saveLogs(mergedDTOs)
            } catch {
                print("Background refresh failed: \(error)")
            }
        }
        
        return todayLogs
    }
    
    func fetchLog(id: UUID) async throws -> PoopLog {
        // Try local first
        let localDTOs = try localDataSource.loadLogs()
        if let localDTO = localDTOs.first(where: { $0.id == id }) {
            return localDTO.toDomain()
        }
        
        // Fallback to remote
        let deviceId = try await deviceService.getDeviceId()
        let remoteDTO = try await remoteDataSource.fetchLog(deviceId: deviceId, id: id)
        
        // Save to local
        try localDataSource.saveLog(remoteDTO)
        
        return remoteDTO.toDomain()
    }
    
    // MARK: - Create Operations (Offline-First)
    
    func createLog(_ log: PoopLog) async throws -> PoopLog {
        // Save to local first (immediate UI update)
        let dto = log.toDTO()
        try localDataSource.saveLog(dto)
        
        // Enqueue for sync
        Task { @MainActor in
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(dto)
                
                let syncItem = SyncItem(
                    type: .poopLog,
                    action: .create,
                    data: data
                )
                
                try syncService.enqueue(item: syncItem)
            } catch {
                print("Failed to enqueue sync item: \(error)")
            }
        }
        
        return log
    }
    
    // MARK: - Update Operations
    
    func updateLog(_ log: PoopLog) async throws -> PoopLog {
        // Update local first
        var updatedLog = log
        updatedLog.updatedAt = Date()
        
        let dto = updatedLog.toDTO()
        try localDataSource.saveLog(dto)
        
        // Enqueue for sync
        Task { @MainActor in
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(dto)
                
                let syncItem = SyncItem(
                    type: .poopLog,
                    action: .update,
                    data: data
                )
                
                try syncService.enqueue(item: syncItem)
            } catch {
                print("Failed to enqueue sync item: \(error)")
            }
        }
        
        return updatedLog
    }
    
    // MARK: - Delete Operations
    
    func deleteLog(id: UUID) async throws {
        // Get log before deleting for sync queue
        let localDTOs = try localDataSource.loadLogs()
        guard let logDTO = localDTOs.first(where: { $0.id == id }) else {
            throw DataError.notFound
        }
        
        // Delete from local first
        try localDataSource.deleteLog(id: id)
        
        // Enqueue for sync
        Task { @MainActor in
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(logDTO)
                
                let syncItem = SyncItem(
                    type: .poopLog,
                    action: .delete,
                    data: data
                )
                
                try syncService.enqueue(item: syncItem)
            } catch {
                print("Failed to enqueue sync item: \(error)")
            }
        }
    }
    
    // MARK: - Conflict Resolution
    
    private func mergeLogs(local: [PoopLogDTO], remote: [PoopLogDTO]) async throws -> [PoopLogDTO] {
        var merged: [UUID: PoopLogDTO] = [:]
        
        // Add all local logs
        for log in local {
            if let id = log.id {
                merged[id] = log
            }
        }
        
        // Merge remote logs (last-write-wins)
        for remoteLog in remote {
            if let id = remoteLog.id {
                if let localLog = merged[id] {
                    // Conflict: choose the one with newer updatedAt
                    if remoteLog.updatedAt > localLog.updatedAt {
                        merged[id] = remoteLog
                    }
                } else {
                    // New remote log
                    merged[id] = remoteLog
                }
            }
        }
        
        return Array(merged.values).sorted { $0.loggedAt > $1.loggedAt }
    }
}

