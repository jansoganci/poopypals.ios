//
//  LocalDeviceStatsDataSource.swift
//  PoopyPals
//
//  Local data source for Device Stats (UserDefaults)
//

import Foundation

protocol LocalDeviceStatsDataSourceProtocol {
    func saveStats(_ stats: DeviceStatsDTO) throws
    func loadStats() throws -> DeviceStatsDTO?
    func updateStreak(_ count: Int) throws
    func addFlushFunds(_ amount: Int) throws
}

class LocalDeviceStatsDataSource: LocalDeviceStatsDataSourceProtocol {
    private let cacheManager: LocalCacheManager
    
    init(cacheManager: LocalCacheManager = .shared) {
        self.cacheManager = cacheManager
    }
    
    // MARK: - Save Operations
    
    func saveStats(_ stats: DeviceStatsDTO) throws {
        try cacheManager.save(stats, forKey: .deviceStats)
    }
    
    // MARK: - Load Operations
    
    func loadStats() throws -> DeviceStatsDTO? {
        return try cacheManager.load(DeviceStatsDTO.self, forKey: .deviceStats)
    }
    
    // MARK: - Update Operations
    
    func updateStreak(_ count: Int) throws {
        let stats = try loadStats() ?? DeviceStatsDTO(
            streakCount: 0,
            totalFlushFunds: 0,
            totalLogs: 0,
            lastLogDate: nil
        )
        
        let updatedStats = DeviceStatsDTO(
            streakCount: count,
            totalFlushFunds: stats.totalFlushFunds,
            totalLogs: stats.totalLogs,
            lastLogDate: stats.lastLogDate
        )
        
        try saveStats(updatedStats)
    }
    
    func addFlushFunds(_ amount: Int) throws {
        let stats = try loadStats() ?? DeviceStatsDTO(
            streakCount: 0,
            totalFlushFunds: 0,
            totalLogs: 0,
            lastLogDate: nil
        )
        
        let updatedStats = DeviceStatsDTO(
            streakCount: stats.streakCount,
            totalFlushFunds: stats.totalFlushFunds + amount,
            totalLogs: stats.totalLogs,
            lastLogDate: stats.lastLogDate
        )
        
        try saveStats(updatedStats)
    }
}

