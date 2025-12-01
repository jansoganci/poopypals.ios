//
//  AchievementRepository.swift
//  PoopyPals
//
//  Repository implementation for Achievement (Data Layer)
//

import Foundation

class AchievementRepository: AchievementRepositoryProtocol {
    private let localDataSource: LocalAchievementDataSourceProtocol
    private let remoteDataSource: RemoteAchievementDataSourceProtocol
    private let deviceService: DeviceIdentificationService
    private let syncService: SyncService
    
    init(
        localDataSource: LocalAchievementDataSourceProtocol = LocalAchievementDataSource(),
        remoteDataSource: RemoteAchievementDataSourceProtocol = SupabaseAchievementDataSource(),
        deviceService: DeviceIdentificationService = DeviceIdentificationService(),
        syncService: SyncService = .shared
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.deviceService = deviceService
        self.syncService = syncService
    }
    
    // MARK: - Fetch Operations (Offline-First)
    
    func fetchUnlockedAchievements() async throws -> [Achievement] {
        // Read from local first
        let localDTOs = try localDataSource.loadAchievements()
        let localAchievements = localDTOs.map { $0.toDomain() }
        
        // Background: Refresh from remote
        Task {
            do {
                let deviceId = try await deviceService.getDeviceId()
                let remoteDTOs = try await remoteDataSource.fetchUnlockedAchievements(deviceId: deviceId)
                let mergedDTOs = try await mergeAchievements(local: localDTOs, remote: remoteDTOs)
                try localDataSource.saveAchievements(mergedDTOs)
            } catch {
                print("Background refresh failed: \(error)")
            }
        }
        
        return localAchievements
    }
    
    // MARK: - Create Operations (Offline-First)
    
    func unlockAchievement(_ achievement: Achievement) async throws -> Achievement {
        // Save to local first
        let dto = achievement.toDTO()
        try localDataSource.saveAchievement(dto)
        
        // Enqueue for sync
        Task { @MainActor in
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(dto)
                
                let syncItem = SyncItem(
                    type: .achievement,
                    action: .create,
                    data: data
                )
                
                try syncService.enqueue(item: syncItem)
            } catch {
                print("Failed to enqueue sync item: \(error)")
            }
        }
        
        return achievement
    }
    
    // MARK: - Update Operations
    
    func markAsViewed(achievementId: UUID) async throws {
        // Update local first
        try localDataSource.markAsViewed(achievementId: achievementId)
        
        // Background: Sync to remote
        Task {
            do {
                let deviceId = try await deviceService.getDeviceId()
                try await remoteDataSource.markAsViewed(deviceId: deviceId, achievementId: achievementId)
            } catch {
                print("Background sync failed: \(error)")
            }
        }
    }
    
    // MARK: - Conflict Resolution
    
    private func mergeAchievements(local: [AchievementDTO], remote: [AchievementDTO]) async throws -> [AchievementDTO] {
        var merged: [UUID: AchievementDTO] = [:]
        
        // Add all local achievements
        for achievement in local {
            merged[achievement.id] = achievement
        }
        
        // Merge remote achievements (last-write-wins)
        for remoteAchievement in remote {
            if let localAchievement = merged[remoteAchievement.id] {
                // Conflict: choose the one with newer unlockedAt
                if remoteAchievement.unlockedAt > localAchievement.unlockedAt {
                    merged[remoteAchievement.id] = remoteAchievement
                }
            } else {
                // New remote achievement
                merged[remoteAchievement.id] = remoteAchievement
            }
        }
        
        return Array(merged.values).sorted { $0.unlockedAt > $1.unlockedAt }
    }
}

