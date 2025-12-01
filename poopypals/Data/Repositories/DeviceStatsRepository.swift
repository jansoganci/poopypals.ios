//
//  DeviceStatsRepository.swift
//  PoopyPals
//
//  Repository implementation for Device Stats (Data Layer)
//

import Foundation

class DeviceStatsRepository: DeviceStatsRepositoryProtocol {
    private let localDataSource: LocalDeviceStatsDataSourceProtocol
    private let remoteDataSource: RemoteDeviceStatsDataSourceProtocol
    private let deviceService: DeviceIdentificationService
    
    init(
        localDataSource: LocalDeviceStatsDataSourceProtocol = LocalDeviceStatsDataSource(),
        remoteDataSource: RemoteDeviceStatsDataSourceProtocol = SupabaseDeviceStatsDataSource(),
        deviceService: DeviceIdentificationService = DeviceIdentificationService()
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.deviceService = deviceService
    }
    
    // MARK: - Fetch Operations (Offline-First)
    
    func fetchStats() async throws -> DeviceStats {
        // Read from local first
        if let localStats = try localDataSource.loadStats() {
            // Background: Refresh from remote
            Task {
                do {
                    let deviceId = try await deviceService.getDeviceId()
                    let remoteStats = try await remoteDataSource.fetchStats(deviceId: deviceId)
                    
                    // Merge (remote wins for stats)
                    try localDataSource.saveStats(remoteStats)
                } catch {
                    print("Background refresh failed: \(error)")
                }
            }
            
            return localStats.toDomain()
        }
        
        // Fallback to remote if no local data
        let deviceId = try await deviceService.getDeviceId()
        let remoteStats = try await remoteDataSource.fetchStats(deviceId: deviceId)
        try localDataSource.saveStats(remoteStats)
        
        return remoteStats.toDomain()
    }
    
    // MARK: - Update Operations
    
    func updateStreak(_ count: Int) async throws {
        // Update local first
        try localDataSource.updateStreak(count)
        
        // Background: Sync to remote
        Task {
            do {
                let deviceId = try await deviceService.getDeviceId()
                try await remoteDataSource.updateStreak(deviceId: deviceId, count: count)
            } catch {
                print("Background sync failed: \(error)")
            }
        }
    }
    
    func addFlushFunds(_ amount: Int) async throws {
        // Update local first
        try localDataSource.addFlushFunds(amount)
        
        // Background: Sync to remote
        Task {
            do {
                let deviceId = try await deviceService.getDeviceId()
                try await remoteDataSource.addFlushFunds(deviceId: deviceId, amount: amount)
            } catch {
                print("Background sync failed: \(error)")
            }
        }
    }
}

