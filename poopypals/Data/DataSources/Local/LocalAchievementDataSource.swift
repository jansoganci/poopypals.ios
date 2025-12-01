//
//  LocalAchievementDataSource.swift
//  PoopyPals
//
//  Local data source for Achievement (UserDefaults)
//

import Foundation

protocol LocalAchievementDataSourceProtocol {
    func saveAchievements(_ achievements: [AchievementDTO]) throws
    func loadAchievements() throws -> [AchievementDTO]
    func saveAchievement(_ achievement: AchievementDTO) throws
    func markAsViewed(achievementId: UUID) throws
}

class LocalAchievementDataSource: LocalAchievementDataSourceProtocol {
    private let cacheManager: LocalCacheManager
    
    init(cacheManager: LocalCacheManager = .shared) {
        self.cacheManager = cacheManager
    }
    
    // MARK: - Save Operations
    
    func saveAchievements(_ achievements: [AchievementDTO]) throws {
        try cacheManager.saveArray(achievements, forKey: .achievements)
    }
    
    func saveAchievement(_ achievement: AchievementDTO) throws {
        var achievements = try loadAchievements()
        
        // Remove existing achievement with same ID if exists
        achievements.removeAll { $0.id == achievement.id }
        
        // Add new/updated achievement
        achievements.append(achievement)
        
        // Sort by unlockedAt descending (newest first)
        achievements.sort { $0.unlockedAt > $1.unlockedAt }
        
        try saveAchievements(achievements)
    }
    
    // MARK: - Load Operations
    
    func loadAchievements() throws -> [AchievementDTO] {
        return try cacheManager.loadArray(AchievementDTO.self, forKey: .achievements)
    }
    
    // MARK: - Update Operations
    
    func markAsViewed(achievementId: UUID) throws {
        var achievements = try loadAchievements()
        
        if let index = achievements.firstIndex(where: { $0.id == achievementId }) {
            var updated = achievements[index]
            // Note: AchievementDTO is a struct, so we need to create a new one
            let updatedDTO = AchievementDTO(
                id: updated.id,
                deviceId: updated.deviceId,
                achievementKey: updated.achievementKey,
                achievementType: updated.achievementType,
                title: updated.title,
                description: updated.description,
                iconName: updated.iconName,
                flushFundsReward: updated.flushFundsReward,
                unlockedAt: updated.unlockedAt,
                isViewed: true
            )
            achievements[index] = updatedDTO
            try saveAchievements(achievements)
        }
    }
}

