//
//  DeletePoopLogUseCase.swift
//  PoopyPals
//
//  Use case for deleting a poop log
//

import Foundation

protocol DeletePoopLogUseCaseProtocol {
    func execute(id: UUID) async throws
}

class DeletePoopLogUseCase: DeletePoopLogUseCaseProtocol {
    private let repository: PoopLogRepositoryProtocol
    
    init(repository: PoopLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: UUID) async throws {
        try await repository.deleteLog(id: id)
    }
}

