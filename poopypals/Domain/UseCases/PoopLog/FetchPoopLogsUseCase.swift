//
//  FetchPoopLogsUseCase.swift
//  PoopyPals
//
//  Use case for fetching poop logs
//

import Foundation

protocol FetchPoopLogsUseCaseProtocol {
    func execute(limit: Int, offset: Int) async throws -> [PoopLog]
}

class FetchPoopLogsUseCase: FetchPoopLogsUseCaseProtocol {
    private let repository: PoopLogRepositoryProtocol
    
    init(repository: PoopLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(limit: Int, offset: Int) async throws -> [PoopLog] {
        return try await repository.fetchLogs(limit: limit, offset: offset)
    }
}

