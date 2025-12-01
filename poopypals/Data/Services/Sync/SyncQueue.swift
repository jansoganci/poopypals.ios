//
//  SyncQueue.swift
//  PoopyPals
//
//  Sync queue models for background synchronization
//

import Foundation

enum SyncAction: String, Codable {
    case create
    case update
    case delete
}

enum SyncType: String, Codable {
    case poopLog
    case achievement
    case deviceStats
}

struct SyncItem: Identifiable, Codable {
    let id: UUID
    let type: SyncType
    let action: SyncAction
    let data: Data  // JSON encoded entity data
    let createdAt: Date
    var retryCount: Int
    
    init(
        id: UUID = UUID(),
        type: SyncType,
        action: SyncAction,
        data: Data,
        createdAt: Date = Date(),
        retryCount: Int = 0
    ) {
        self.id = id
        self.type = type
        self.action = action
        self.data = data
        self.createdAt = createdAt
        self.retryCount = retryCount
    }
}

