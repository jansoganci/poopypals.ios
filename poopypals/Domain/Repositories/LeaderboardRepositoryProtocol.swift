//
//  LeaderboardRepositoryProtocol.swift
//  PoopyPals
//
//  Repository protocol for Leaderboard data access
//

import Foundation

protocol LeaderboardRepositoryProtocol {
    func fetchLeaderboard(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int
    ) async throws -> [LeaderboardEntry]
    
    func fetchCurrentUserRank(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry?
}

