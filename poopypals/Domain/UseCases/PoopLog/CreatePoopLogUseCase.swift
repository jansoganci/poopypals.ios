//
//  CreatePoopLogUseCase.swift
//  PoopyPals
//
//  Use case for creating a poop log
//

import Foundation

protocol CreatePoopLogUseCaseProtocol {
    func execute(_ log: PoopLog) async throws -> PoopLog
}

class CreatePoopLogUseCase: CreatePoopLogUseCaseProtocol {
    private let repository: PoopLogRepositoryProtocol
    
    init(repository: PoopLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ log: PoopLog) async throws -> PoopLog {
        // Validation
        guard log.durationSeconds > 0 && log.durationSeconds <= 7200 else {
            throw DataError.invalidData
        }
        
        guard log.consistency >= 1 && log.consistency <= 7 else {
            throw DataError.invalidData
        }
        
        return try await repository.createLog(log)
    }
}

