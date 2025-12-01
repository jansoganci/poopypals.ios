//
//  DeviceStatsRepositoryProtocol.swift
//  PoopyPals
//
//  Repository protocol for Device Stats (Domain Layer)
//

import Foundation

protocol DeviceStatsRepositoryProtocol {
    func fetchStats() async throws -> DeviceStats
    func updateStreak(_ count: Int) async throws
    func addFlushFunds(_ amount: Int) async throws
}

