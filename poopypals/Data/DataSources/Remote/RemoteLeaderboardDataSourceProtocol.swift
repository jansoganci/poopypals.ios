//
//  RemoteLeaderboardDataSourceProtocol.swift
//  PoopyPals
//
//  Protocol for remote leaderboard data source
//

import Foundation

protocol RemoteLeaderboardDataSourceProtocol {
    func fetchLeaderboard(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int,
        currentDeviceId: UUID
    ) async throws -> [LeaderboardEntry]
    
    func fetchUserRank(
        deviceId: UUID,
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry?
}

