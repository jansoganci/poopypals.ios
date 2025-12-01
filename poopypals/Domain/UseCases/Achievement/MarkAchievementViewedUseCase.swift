//
//  MarkAchievementViewedUseCase.swift
//  PoopyPals
//
//  Use case for marking achievement as viewed
//

import Foundation

protocol MarkAchievementViewedUseCaseProtocol {
    func execute(achievementId: UUID) async throws
}

class MarkAchievementViewedUseCase: MarkAchievementViewedUseCaseProtocol {
    private let repository: AchievementRepositoryProtocol
    
    init(repository: AchievementRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(achievementId: UUID) async throws {
        try await repository.markAsViewed(achievementId: achievementId)
    }
}

