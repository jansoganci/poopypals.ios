//
//  LocalPoopLogDataSource.swift
//  PoopyPals
//
//  Local data source for PoopLog (UserDefaults)
//

import Foundation

protocol LocalPoopLogDataSourceProtocol {
    func saveLogs(_ logs: [PoopLogDTO]) throws
    func loadLogs() throws -> [PoopLogDTO]
    func saveLog(_ log: PoopLogDTO) throws
    func deleteLog(id: UUID) throws
    func clearAll() throws
}

class LocalPoopLogDataSource: LocalPoopLogDataSourceProtocol {
    private let cacheManager: LocalCacheManager
    
    init(cacheManager: LocalCacheManager = .shared) {
        self.cacheManager = cacheManager
    }
    
    // MARK: - Save Operations
    
    func saveLogs(_ logs: [PoopLogDTO]) throws {
        try cacheManager.saveArray(logs, forKey: .poopLogs)
    }
    
    func saveLog(_ log: PoopLogDTO) throws {
        var logs = try loadLogs()
        
        // Remove existing log with same ID if exists
        logs.removeAll { $0.id == log.id }
        
        // Add new/updated log
        logs.append(log)
        
        // Sort by loggedAt descending (newest first)
        logs.sort { $0.loggedAt > $1.loggedAt }
        
        try saveLogs(logs)
    }
    
    // MARK: - Load Operations
    
    func loadLogs() throws -> [PoopLogDTO] {
        return try cacheManager.loadArray(PoopLogDTO.self, forKey: .poopLogs)
    }
    
    // MARK: - Delete Operations
    
    func deleteLog(id: UUID) throws {
        var logs = try loadLogs()
        logs.removeAll { $0.id == id }
        try saveLogs(logs)
    }
    
    // MARK: - Clear Operations
    
    func clearAll() throws {
        cacheManager.remove(forKey: .poopLogs)
    }
}

