//
//  AchievementDTO.swift
//  PoopyPals
//
//  Data Transfer Object for Achievement (Supabase/PostgreSQL format)
//

import Foundation

struct AchievementDTO: Codable {
    var id: UUID
    var deviceId: UUID?
    let achievementKey: String
    let achievementType: String
    let title: String
    let description: String
    let iconName: String?
    let flushFundsReward: Int
    let unlockedAt: Date
    let isViewed: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case deviceId = "device_id"
        case achievementKey = "achievement_key"
        case achievementType = "achievement_type"
        case title
        case description
        case iconName = "icon_name"
        case flushFundsReward = "flush_funds_reward"
        case unlockedAt = "unlocked_at"
        case isViewed = "is_viewed"
    }
}

// MARK: - Domain Conversion

extension AchievementDTO {
    /// Convert DTO to Domain Entity
    func toDomain() -> Achievement {
        Achievement(
            id: id,
            achievementKey: achievementKey,
            achievementType: Achievement.AchievementType(rawValue: achievementType) ?? .milestone,
            title: title,
            description: description,
            iconName: iconName ?? "star.fill",
            flushFundsReward: flushFundsReward,
            unlockedAt: unlockedAt,
            isViewed: isViewed
        )
    }
}

extension Achievement {
    /// Convert Domain Entity to DTO
    func toDTO(deviceId: UUID? = nil) -> AchievementDTO {
        AchievementDTO(
            id: id,
            deviceId: deviceId,
            achievementKey: achievementKey,
            achievementType: achievementType.rawValue,
            title: title,
            description: description,
            iconName: iconName,
            flushFundsReward: flushFundsReward,
            unlockedAt: unlockedAt,
            isViewed: isViewed
        )
    }
}

