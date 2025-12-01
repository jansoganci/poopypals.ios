//
//  LocalCacheManager.swift
//  PoopyPals
//
//  UserDefaults wrapper for local storage
//

import Foundation

class LocalCacheManager {
    static let shared = LocalCacheManager()
    
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    // MARK: - Storage Keys
    
    enum StorageKey: String {
        case poopLogs = "poop_logs"
        case achievements = "achievements"
        case deviceStats = "device_stats"
        case syncQueue = "sync_queue"
        case lastSyncDate = "last_sync_date"
    }
    
    // MARK: - Initialization
    
    private init() {
        self.userDefaults = UserDefaults.standard
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        
        // Configure date encoding/decoding for ISO8601
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Generic Save/Load Methods
    
    /// Save Codable object to UserDefaults
    func save<T: Codable>(_ value: T, forKey key: StorageKey) throws {
        let data = try encoder.encode(value)
        userDefaults.set(data, forKey: key.rawValue)
    }
    
    /// Load Codable object from UserDefaults
    func load<T: Codable>(_ type: T.Type, forKey key: StorageKey) throws -> T? {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            return nil
        }
        return try decoder.decode(T.self, from: data)
    }
    
    /// Save array of Codable objects
    func saveArray<T: Codable>(_ array: [T], forKey key: StorageKey) throws {
        let data = try encoder.encode(array)
        userDefaults.set(data, forKey: key.rawValue)
    }
    
    /// Load array of Codable objects
    func loadArray<T: Codable>(_ type: T.Type, forKey key: StorageKey) throws -> [T] {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            return []
        }
        return try decoder.decode([T].self, from: data)
    }
    
    /// Save Date
    func saveDate(_ date: Date, forKey key: StorageKey) {
        userDefaults.set(date, forKey: key.rawValue)
    }
    
    /// Load Date
    func loadDate(forKey key: StorageKey) -> Date? {
        return userDefaults.object(forKey: key.rawValue) as? Date
    }
    
    /// Remove value for key
    func remove(forKey key: StorageKey) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
    
    /// Check if key exists
    func exists(forKey key: StorageKey) -> Bool {
        return userDefaults.object(forKey: key.rawValue) != nil
    }
    
    /// Clear all app data
    func clearAll() {
        StorageKey.allCases.forEach { key in
            userDefaults.removeObject(forKey: key.rawValue)
        }
    }
}

// MARK: - StorageKey Extension

extension LocalCacheManager.StorageKey: CaseIterable {}

