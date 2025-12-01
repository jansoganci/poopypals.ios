//
//  FetchUnlockedAchievementsUseCase.swift
//  PoopyPals
//
//  Use case for fetching unlocked achievements
//

import Foundation

protocol FetchUnlockedAchievementsUseCaseProtocol {
    func execute() async throws -> [Achievement]
}

class FetchUnlockedAchievementsUseCase: FetchUnlockedAchievementsUseCaseProtocol {
    private let repository: AchievementRepositoryProtocol
    
    init(repository: AchievementRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Achievement] {
        return try await repository.fetchUnlockedAchievements()
    }
}

