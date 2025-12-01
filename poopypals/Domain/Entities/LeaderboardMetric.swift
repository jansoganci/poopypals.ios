//
//  LeaderboardMetric.swift
//  PoopyPals
//
//  Domain Entity - Leaderboard Ranking Metric
//

import Foundation

enum LeaderboardMetric: String, CaseIterable, Codable {
    case streak = "streak"
    case totalLogs = "total_logs"
    case flushFunds = "flush_funds"
    
    var displayName: String {
        switch self {
        case .streak: return "Streak"
        case .totalLogs: return "Total Logs"
        case .flushFunds: return "Flush Funds"
        }
    }
    
    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .totalLogs: return "list.bullet.circle.fill"
        case .flushFunds: return "dollarsign.circle.fill"
        }
    }
}

