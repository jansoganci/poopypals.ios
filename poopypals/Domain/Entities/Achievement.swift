//
//  Achievement.swift
//  PoopyPals
//
//  Domain Entity - Achievements (VIRAL FEATURE)
//

import Foundation
import SwiftUI

struct Achievement: Identifiable, Codable {
    let id: UUID
    let achievementKey: String
    let achievementType: AchievementType
    let title: String
    let description: String
    let iconName: String
    let flushFundsReward: Int
    let unlockedAt: Date
    var isViewed: Bool

    init(
        id: UUID = UUID(),
        achievementKey: String,
        achievementType: AchievementType,
        title: String,
        description: String,
        iconName: String,
        flushFundsReward: Int = 100,
        unlockedAt: Date = Date(),
        isViewed: Bool = false
    ) {
        self.id = id
        self.achievementKey = achievementKey
        self.achievementType = achievementType
        self.title = title
        self.description = description
        self.iconName = iconName
        self.flushFundsReward = flushFundsReward
        self.unlockedAt = unlockedAt
        self.isViewed = isViewed
    }

    // MARK: - Achievement Types

    enum AchievementType: String, Codable {
        case milestone
        case streak
        case special
        case consistency
    }

    // MARK: - Shareable Content (VIRAL FEATURE!)

    var shareableText: String {
        let emojis: [String: String] = [
            "first_log": "🎉",
            "streak_7": "🔥",
            "streak_30": "🔥🔥",
            "streak_100": "🔥🔥🔥",
            "logs_50": "💯",
            "logs_100": "💯💯",
            "perfect_week": "⭐️",
            "morning_person": "🌅",
            "speed_runner": "⚡️"
        ]

        let emoji = emojis[achievementKey] ?? "🏆"

        return """
        Just unlocked the "\(title)" achievement in @PoopyPalsApp! \(emoji)

        \(description)

        Who else is tracking their bathroom habits like a boss? 💩
        """
    }

    var isShareable: Bool {
        // Only certain achievements are worth sharing
        let shareableKeys = [
            "streak_7", "streak_30", "streak_100",
            "logs_50", "logs_100", "logs_365",
            "perfect_week", "perfect_month"
        ]
        return shareableKeys.contains(achievementKey)
    }
}

// MARK: - Predefined Achievements

extension Achievement {
    static let allAchievements: [Achievement] = [
        // First Steps
        Achievement(
            achievementKey: "first_log",
            achievementType: .milestone,
            title: "First Steps",
            description: "Your journey begins! You've logged your first bathroom visit.",
            iconName: "star.fill",
            flushFundsReward: 100
        ),

        // Streak Achievements
        Achievement(
            achievementKey: "streak_3",
            achievementType: .streak,
            title: "Getting Started",
            description: "3-day streak! You're building a healthy habit.",
            iconName: "flame.fill",
            flushFundsReward: 150
        ),

        Achievement(
            achievementKey: "streak_7",
            achievementType: .streak,
            title: "Week Warrior",
            description: "7-day streak! One week of consistent tracking.",
            iconName: "flame.fill",
            flushFundsReward: 300
        ),

        Achievement(
            achievementKey: "streak_30",
            achievementType: .streak,
            title: "Monthly Master",
            description: "30-day streak! You're a tracking legend.",
            iconName: "flame.fill",
            flushFundsReward: 1000
        ),

        Achievement(
            achievementKey: "streak_100",
            achievementType: .streak,
            title: "Century Streak",
            description: "100-day streak! Unbelievable dedication!",
            iconName: "flame.fill",
            flushFundsReward: 5000
        ),

        // Log Count Milestones
        Achievement(
            achievementKey: "logs_10",
            achievementType: .milestone,
            title: "Double Digits",
            description: "10 logs tracked! Keep it going!",
            iconName: "number.circle.fill",
            flushFundsReward: 100
        ),

        Achievement(
            achievementKey: "logs_50",
            achievementType: .milestone,
            title: "Half Century",
            description: "50 logs! You're halfway to the Century Club.",
            iconName: "number.circle.fill",
            flushFundsReward: 500
        ),

        Achievement(
            achievementKey: "logs_100",
            achievementType: .milestone,
            title: "Century Club",
            description: "100 logs tracked! Welcome to the elite club.",
            iconName: "crown.fill",
            flushFundsReward: 1000
        ),

        Achievement(
            achievementKey: "logs_365",
            achievementType: .milestone,
            title: "Year of Logging",
            description: "365 logs! A full year of tracking.",
            iconName: "calendar.circle.fill",
            flushFundsReward: 5000
        ),

        // Special Achievements
        Achievement(
            achievementKey: "morning_person",
            achievementType: .special,
            title: "Morning Person",
            description: "5 logs before 9am! Early bird gets the... relief.",
            iconName: "sunrise.fill",
            flushFundsReward: 200
        ),

        Achievement(
            achievementKey: "speed_runner",
            achievementType: .special,
            title: "Speed Runner",
            description: "Average under 2 minutes for 10 logs. Efficient!",
            iconName: "bolt.fill",
            flushFundsReward: 300
        ),

        Achievement(
            achievementKey: "perfect_week",
            achievementType: .consistency,
            title: "Perfect Week",
            description: "7 days in a row, all 'Great' ratings!",
            iconName: "star.circle.fill",
            flushFundsReward: 500
        ),

        Achievement(
            achievementKey: "ideal_consistency",
            achievementType: .consistency,
            title: "Gut Health Champion",
            description: "10 logs with ideal consistency (3-4). Your gut is happy!",
            iconName: "heart.circle.fill",
            flushFundsReward: 400
        )
    ]

    // MARK: - Sample for Previews

    static let sample = Achievement(
        achievementKey: "streak_7",
        achievementType: .streak,
        title: "Week Warrior",
        description: "7-day streak! You're on fire!",
        iconName: "flame.fill",
        flushFundsReward: 300
    )
}
