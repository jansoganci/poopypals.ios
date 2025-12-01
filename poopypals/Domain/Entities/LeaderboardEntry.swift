//
//  LeaderboardEntry.swift
//  PoopyPals
//
//  Domain Entity - Leaderboard Entry
//

import Foundation

struct LeaderboardEntry: Identifiable {
    let id: UUID  // device_id
    let rank: Int
    let streakCount: Int
    let totalLogs: Int
    let flushFunds: Int
    let lastSeenAt: Date
    var isCurrentUser: Bool  // Set by ViewModel
    
    // Computed properties
    var displayName: String {
        // Generate anonymous name from device UUID
        // Example: "FlushMaster#A1B2"
        let hash = id.uuidString.prefix(4).uppercased()
        return "FlushMaster#\(hash)"
    }
    
    init(
        id: UUID,
        rank: Int,
        streakCount: Int,
        totalLogs: Int,
        flushFunds: Int,
        lastSeenAt: Date,
        isCurrentUser: Bool = false
    ) {
        self.id = id
        self.rank = rank
        self.streakCount = streakCount
        self.totalLogs = totalLogs
        self.flushFunds = flushFunds
        self.lastSeenAt = lastSeenAt
        self.isCurrentUser = isCurrentUser
    }
}

// MARK: - Codable (exclude isCurrentUser from encoding/decoding)

extension LeaderboardEntry: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "device_id"
        case rank
        case streakCount = "streak_count"
        case totalLogs = "total_logs"
        case flushFunds = "flush_funds"
        case lastSeenAt = "last_seen_at"
        // isCurrentUser is excluded - set after decoding
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        rank = try container.decode(Int.self, forKey: .rank)
        streakCount = try container.decode(Int.self, forKey: .streakCount)
        totalLogs = try container.decode(Int.self, forKey: .totalLogs)
        flushFunds = try container.decode(Int.self, forKey: .flushFunds)
        lastSeenAt = try container.decode(Date.self, forKey: .lastSeenAt)
        isCurrentUser = false  // Default value, will be set by ViewModel
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(rank, forKey: .rank)
        try container.encode(streakCount, forKey: .streakCount)
        try container.encode(totalLogs, forKey: .totalLogs)
        try container.encode(flushFunds, forKey: .flushFunds)
        try container.encode(lastSeenAt, forKey: .lastSeenAt)
        // isCurrentUser is not encoded
    }
}

