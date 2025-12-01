//
//  FetchLeaderboardUseCase.swift
//  PoopyPals
//
//  Use case for fetching leaderboard rankings
//

import Foundation

protocol FetchLeaderboardUseCaseProtocol {
    func execute(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int
    ) async throws -> [LeaderboardEntry]
}

class FetchLeaderboardUseCase: FetchLeaderboardUseCaseProtocol {
    private let repository: LeaderboardRepositoryProtocol
    
    init(repository: LeaderboardRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int = 100
    ) async throws -> [LeaderboardEntry] {
        return try await repository.fetchLeaderboard(
            period: period,
            metric: metric,
            limit: limit
        )
    }
}

