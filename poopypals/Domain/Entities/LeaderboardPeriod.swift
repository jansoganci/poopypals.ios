//
//  LeaderboardPeriod.swift
//  PoopyPals
//
//  Domain Entity - Leaderboard Time Period
//

import Foundation

enum LeaderboardPeriod: String, CaseIterable, Codable {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .weekly: return "This Week"
        case .monthly: return "This Month"
        case .yearly: return "This Year"
        }
    }
    
    var interval: String {
        switch self {
        case .weekly: return "7 days"
        case .monthly: return "30 days"
        case .yearly: return "365 days"
        }
    }
}

