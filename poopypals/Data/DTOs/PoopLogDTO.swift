//
//  PoopLogDTO.swift
//  PoopyPals
//
//  Data Transfer Object for PoopLog (Supabase/PostgreSQL format)
//

import Foundation

struct PoopLogDTO: Codable {
    var id: UUID?
    var deviceId: UUID?
    let loggedAt: Date
    let durationSeconds: Int
    let rating: String
    let consistency: Int
    let notes: String?
    let flushFundsEarned: Int
    let isStreakCounted: Bool?
    let localId: String?
    let isDeleted: Bool?
    let syncedAt: Date?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case deviceId = "device_id"
        case loggedAt = "logged_at"
        case durationSeconds = "duration_seconds"
        case rating
        case consistency
        case notes
        case flushFundsEarned = "flush_funds_earned"
        case isStreakCounted = "is_streak_counted"
        case localId = "local_id"
        case isDeleted = "is_deleted"
        case syncedAt = "synced_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Domain Conversion

extension PoopLogDTO {
    /// Convert DTO to Domain Entity
    func toDomain() -> PoopLog {
        PoopLog(
            id: id ?? UUID(),
            loggedAt: loggedAt,
            durationSeconds: durationSeconds,
            rating: PoopLog.Rating(rawValue: rating) ?? .okay,
            consistency: consistency,
            notes: notes,
            flushFundsEarned: flushFundsEarned,
            localId: localId,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension PoopLog {
    /// Convert Domain Entity to DTO
    func toDTO(deviceId: UUID? = nil) -> PoopLogDTO {
        PoopLogDTO(
            id: id,
            deviceId: deviceId,
            loggedAt: loggedAt,
            durationSeconds: durationSeconds,
            rating: rating.rawValue,
            consistency: consistency,
            notes: notes,
            flushFundsEarned: flushFundsEarned,
            isStreakCounted: true,
            localId: localId,
            isDeleted: false,
            syncedAt: nil,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

