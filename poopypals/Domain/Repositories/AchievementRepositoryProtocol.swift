//
//  AchievementRepositoryProtocol.swift
//  PoopyPals
//
//  Repository protocol for Achievement (Domain Layer)
//

import Foundation

protocol AchievementRepositoryProtocol {
    func fetchUnlockedAchievements() async throws -> [Achievement]
    func unlockAchievement(_ achievement: Achievement) async throws -> Achievement
    func markAsViewed(achievementId: UUID) async throws
}

