//
//  FetchUserRankUseCase.swift
//  PoopyPals
//
//  Use case for fetching current user's rank
//

import Foundation

protocol FetchUserRankUseCaseProtocol {
    func execute(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry?
}

class FetchUserRankUseCase: FetchUserRankUseCaseProtocol {
    private let repository: LeaderboardRepositoryProtocol
    
    init(repository: LeaderboardRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry? {
        return try await repository.fetchCurrentUserRank(
            period: period,
            metric: metric
        )
    }
}

