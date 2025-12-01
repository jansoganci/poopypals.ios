//
//  LeaderboardEntryDTO.swift
//  PoopyPals
//
//  Data Transfer Object for Leaderboard Entry
//

import Foundation

struct LeaderboardEntryDTO: Codable {
    let deviceId: UUID
    let rank: Int
    let streakCount: Int
    let totalLogs: Int
    let flushFunds: Int
    let lastSeenAt: Date
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case rank
        case streakCount = "streak_count"
        case totalLogs = "total_logs"
        case flushFunds = "flush_funds"
        case lastSeenAt = "last_seen_at"
    }
}

// MARK: - Domain Conversion

extension LeaderboardEntryDTO {
    /// Convert DTO to Domain Entity
    func toDomain() -> LeaderboardEntry {
        LeaderboardEntry(
            id: deviceId,
            rank: rank,
            streakCount: streakCount,
            totalLogs: totalLogs,
            flushFunds: flushFunds,
            lastSeenAt: lastSeenAt
        )
    }
}

