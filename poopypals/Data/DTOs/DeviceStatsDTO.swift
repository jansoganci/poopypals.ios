//
//  DeviceStatsDTO.swift
//  PoopyPals
//
//  Data Transfer Object for Device Stats
//

import Foundation

struct DeviceStatsDTO: Codable {
    let streakCount: Int
    let totalFlushFunds: Int
    let totalLogs: Int
    let lastLogDate: Date?

    enum CodingKeys: String, CodingKey {
        case streakCount = "streak_count"
        case totalFlushFunds = "flush_funds"
        case totalLogs = "total_logs"
        case lastLogDate = "last_log_date"
    }
}

// MARK: - Domain Conversion

extension DeviceStatsDTO {
    /// Convert DTO to Domain Entity
    func toDomain() -> DeviceStats {
        DeviceStats(
            streakCount: streakCount,
            totalFlushFunds: totalFlushFunds,
            totalLogs: totalLogs,
            lastLogDate: lastLogDate
        )
    }
}

// MARK: - Domain Entity

struct DeviceStats: Codable {
    let streakCount: Int
    let totalFlushFunds: Int
    let totalLogs: Int
    let lastLogDate: Date?

    init(
        streakCount: Int = 0,
        totalFlushFunds: Int = 0,
        totalLogs: Int = 0,
        lastLogDate: Date? = nil
    ) {
        self.streakCount = streakCount
        self.totalFlushFunds = totalFlushFunds
        self.totalLogs = totalLogs
        self.lastLogDate = lastLogDate
    }
}

extension DeviceStats {
    /// Convert Domain Entity to DTO
    func toDTO() -> DeviceStatsDTO {
        DeviceStatsDTO(
            streakCount: streakCount,
            totalFlushFunds: totalFlushFunds,
            totalLogs: totalLogs,
            lastLogDate: lastLogDate
        )
    }
}

