//
//  FetchDeviceStatsUseCase.swift
//  PoopyPals
//
//  Use case for fetching device stats
//

import Foundation

protocol FetchDeviceStatsUseCaseProtocol {
    func execute() async throws -> DeviceStats
}

class FetchDeviceStatsUseCase: FetchDeviceStatsUseCaseProtocol {
    private let repository: DeviceStatsRepositoryProtocol
    
    init(repository: DeviceStatsRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> DeviceStats {
        return try await repository.fetchStats()
    }
}

