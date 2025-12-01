//
//  ConflictResolver.swift
//  PoopyPals
//
//  Conflict resolution logic (last-write-wins)
//

import Foundation

enum ConflictResolver {
    /// Resolve conflict between local and remote entities using last-write-wins
    /// - Parameters:
    ///   - local: Local entity
    ///   - remote: Remote entity
    /// - Returns: The winning entity (newer updatedAt)
    static func resolveConflict<T: HasUpdatedAt>(local: T, remote: T) -> T {
        return local.updatedAt > remote.updatedAt ? local : remote
    }
}

// MARK: - Protocol for entities with updatedAt

protocol HasUpdatedAt {
    var updatedAt: Date { get }
}

// MARK: - Conformance

extension PoopLog: HasUpdatedAt {}
extension Achievement: HasUpdatedAt {
    var updatedAt: Date { unlockedAt }
}
extension DeviceStats: HasUpdatedAt {
    var updatedAt: Date { lastLogDate ?? Date.distantPast }
}

