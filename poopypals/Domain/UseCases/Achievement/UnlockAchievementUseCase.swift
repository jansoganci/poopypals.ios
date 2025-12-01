//
//  UnlockAchievementUseCase.swift
//  PoopyPals
//
//  Use case for unlocking an achievement
//

import Foundation

protocol UnlockAchievementUseCaseProtocol {
    func execute(_ achievement: Achievement) async throws -> Achievement
}

class UnlockAchievementUseCase: UnlockAchievementUseCaseProtocol {
    private let repository: AchievementRepositoryProtocol
    
    init(repository: AchievementRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ achievement: Achievement) async throws -> Achievement {
        // Business logic: Check if already unlocked
        let unlocked = try await repository.fetchUnlockedAchievements()
        if unlocked.contains(where: { $0.achievementKey == achievement.achievementKey }) {
            // Already unlocked, return existing
            return unlocked.first(where: { $0.achievementKey == achievement.achievementKey })!
        }
        
        return try await repository.unlockAchievement(achievement)
    }
}

