//
//  UpdateFlushFundsUseCase.swift
//  PoopyPals
//
//  Use case for updating flush funds
//

import Foundation

protocol UpdateFlushFundsUseCaseProtocol {
    func execute(amount: Int) async throws
}

class UpdateFlushFundsUseCase: UpdateFlushFundsUseCaseProtocol {
    private let repository: DeviceStatsRepositoryProtocol
    
    init(repository: DeviceStatsRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(amount: Int) async throws {
        guard amount > 0 else {
            throw DataError.invalidData
        }
        
        try await repository.addFlushFunds(amount)
    }
}

