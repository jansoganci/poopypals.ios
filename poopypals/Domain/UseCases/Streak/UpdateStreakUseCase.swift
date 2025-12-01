//
//  UpdateStreakUseCase.swift
//  PoopyPals
//
//  Use case for updating streak
//

import Foundation

protocol UpdateStreakUseCaseProtocol {
    func execute(_ count: Int) async throws
}

class UpdateStreakUseCase: UpdateStreakUseCaseProtocol {
    private let repository: DeviceStatsRepositoryProtocol
    
    init(repository: DeviceStatsRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ count: Int) async throws {
        guard count >= 0 else {
            throw DataError.invalidData
        }
        
        try await repository.updateStreak(count)
    }
}

