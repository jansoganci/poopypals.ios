//
//  FetchTodayLogsUseCase.swift
//  PoopyPals
//
//  Use case for fetching today's logs
//

import Foundation

protocol FetchTodayLogsUseCaseProtocol {
    func execute() async throws -> [PoopLog]
}

class FetchTodayLogsUseCase: FetchTodayLogsUseCaseProtocol {
    private let repository: PoopLogRepositoryProtocol
    
    init(repository: PoopLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [PoopLog] {
        return try await repository.fetchTodayLogs()
    }
}

