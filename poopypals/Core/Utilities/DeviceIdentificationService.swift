//
//  DeviceIdentificationService.swift
//  PoopyPals
//
//  Device ID management for anonymous authentication
//

import Foundation
import CryptoKit
import StableID

enum DeviceError: LocalizedError {
    case invalidStableID
    case synchronizationError
    
    var errorDescription: String? {
        switch self {
        case .invalidStableID:
            return "Could not generate a valid UUID from StableID"
        case .synchronizationError:
            return "Could not retrieve device ID synchronously"
        }
    }
}

class DeviceIdentificationService {
    // MARK: - Properties
    private var cachedDeviceId: UUID?
    
    // MARK: - Public Methods

    /// Gets the device ID using StableID (Persistent across reinstalls)
    func getDeviceId() async throws -> UUID {
        // 1. Return cached value if available
        if let cached = cachedDeviceId {
            return cached
        }

        // 2. Get Stable ID string
        // Note: StableID library provides a persistent string identifier
        let stableIdString = StableID.id
        
        // 3. Convert to deterministic UUID
        let uuid = try generateUUID(from: stableIdString)
        
        // 4. Cache and return
        cachedDeviceId = uuid
        return uuid
    }

    /// Gets device ID synchronously (uses cached value or computes immediately)
    func getDeviceIdSync() throws -> UUID {
        if let cached = cachedDeviceId {
            return cached
        }

        // StableID.id is synchronous, so we can use it directly
        let stableIdString = StableID.id
        let uuid = try generateUUID(from: stableIdString)
        
        cachedDeviceId = uuid
        return uuid
    }

    /// Check if device ID is cached
    func hasDeviceId() -> Bool {
        return cachedDeviceId != nil
    }

    /// Reset cached ID (Does not reset StableID as it persists in Keychain)
    func resetCache() {
        cachedDeviceId = nil
    }
    
    // MARK: - Private Methods
    
    /// Generates a deterministic UUID from a string using SHA256
    private func generateUUID(from string: String) throws -> UUID {
        guard let data = string.data(using: .utf8) else {
            throw DeviceError.invalidStableID
        }
        
        let hash = SHA256.hash(data: data)
        
        // UUID requires 16 bytes. SHA256 produces 32 bytes.
        // We'll use the first 16 bytes of the hash.
        var truncatedHash = [UInt8]()
        for byte in hash {
            truncatedHash.append(byte)
            if truncatedHash.count == 16 { break }
        }
        
        if truncatedHash.count != 16 {
             throw DeviceError.invalidStableID
        }
        
        // Create UUID from bytes
        let uuid = NSUUID(uuidBytes: truncatedHash) as UUID
        return uuid
    }
}
