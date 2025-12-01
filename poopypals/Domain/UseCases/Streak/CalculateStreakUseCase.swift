//
//  CalculateStreakUseCase.swift
//  PoopyPals
//
//  Use case for calculating streak
//

import Foundation

protocol CalculateStreakUseCaseProtocol {
    func execute() async throws -> Int
}

class CalculateStreakUseCase: CalculateStreakUseCaseProtocol {
    private let repository: PoopLogRepositoryProtocol
    
    init(repository: PoopLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> Int {
        // Fetch all logs
        let logs = try await repository.fetchLogs(limit: 365, offset: 0)
        
        guard !logs.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        while true {
            let hasLogForDay = logs.contains { log in
                Calendar.current.isDate(log.loggedAt, inSameDayAs: currentDate)
            }
            
            if hasLogForDay {
                streak += 1
                guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            } else {
                break
            }
        }
        
        return streak
    }
}

