//
//  LeaderboardRepository.swift
//  PoopyPals
//
//  Repository implementation for Leaderboard (Data Layer)
//

import Foundation

class LeaderboardRepository: LeaderboardRepositoryProtocol {
    private let remoteDataSource: RemoteLeaderboardDataSourceProtocol
    private let deviceService: DeviceIdentificationService
    
    init(
        remoteDataSource: RemoteLeaderboardDataSourceProtocol,
        deviceService: DeviceIdentificationService = DeviceIdentificationService()
    ) {
        self.remoteDataSource = remoteDataSource
        self.deviceService = deviceService
    }
    
    func fetchLeaderboard(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int
    ) async throws -> [LeaderboardEntry] {
        let deviceId = try await deviceService.getDeviceId()
        return try await remoteDataSource.fetchLeaderboard(
            period: period,
            metric: metric,
            limit: limit,
            currentDeviceId: deviceId
        )
    }
    
    func fetchCurrentUserRank(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry? {
        let deviceId = try await deviceService.getDeviceId()
        return try await remoteDataSource.fetchUserRank(
            deviceId: deviceId,
            period: period,
            metric: metric
        )
    }
}

