//
//  PoopLogRepositoryProtocol.swift
//  PoopyPals
//
//  Repository protocol for PoopLog (Domain Layer)
//

import Foundation

protocol PoopLogRepositoryProtocol {
    func fetchLogs(limit: Int, offset: Int) async throws -> [PoopLog]
    func fetchTodayLogs() async throws -> [PoopLog]
    func fetchLog(id: UUID) async throws -> PoopLog
    func createLog(_ log: PoopLog) async throws -> PoopLog
    func updateLog(_ log: PoopLog) async throws -> PoopLog
    func deleteLog(id: UUID) async throws
}

