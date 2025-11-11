//
//  HomeViewModel.swift
//  PoopyPals
//
//  Home Screen - ViewModel
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var logs: [PoopLog] = []
    @Published var streakCount: Int = 0
    @Published var totalFlushFunds: Int = 0
    @Published var todayLogs: [PoopLog] = []
    @Published var isLoading: Bool = false
    @Published var showShareSheet: Bool = false
    @Published var shareItems: [Any] = []

    // Recent achievement (for showing unlock)
    @Published var recentAchievement: Achievement?
    @Published var showAchievementUnlock: Bool = false

    // MARK: - Initialization

    init() {
        // Load initial data
        loadData()
    }

    // MARK: - Data Loading

    func loadData() {
        isLoading = true

        // TODO: Replace with actual repository calls
        // For now, use mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.logs = PoopLog.samples
            self.todayLogs = self.getTodayLogs()
            self.streakCount = self.calculateStreak()
            self.totalFlushFunds = self.calculateFlushFunds()
            self.isLoading = false
        }
    }

    // MARK: - Quick Log (VIRAL FEATURE - Fast onboarding)

    func quickLog(rating: PoopLog.Rating, durationSeconds: Int = 120, consistency: Int = 4) {
        let newLog = PoopLog(
            durationSeconds: durationSeconds,
            rating: rating,
            consistency: consistency,
            flushFundsEarned: 10
        )

        logs.insert(newLog, at: 0)
        todayLogs = getTodayLogs()
        totalFlushFunds += newLog.flushFundsEarned

        // Update streak
        streakCount = calculateStreak()

        // Check for achievements
        checkForAchievements()
    }

    // MARK: - Streak Calculation

    private func calculateStreak() -> Int {
        guard !logs.isEmpty else { return 0 }

        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())

        while true {
            let hasLogForDay = logs.contains { log in
                Calendar.current.isDate(log.loggedAt, inSameDayAs: currentDate)
            }

            if hasLogForDay {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Helper Functions

    private func getTodayLogs() -> [PoopLog] {
        return logs.filter { log in
            Calendar.current.isDateInToday(log.loggedAt)
        }
    }

    private func calculateFlushFunds() -> Int {
        return logs.reduce(0) { $0 + $1.flushFundsEarned }
    }

    // MARK: - Achievement System

    private func checkForAchievements() {
        // Check if first log
        if logs.count == 1 {
            unlockAchievement(Achievement.allAchievements.first(where: { $0.achievementKey == "first_log" })!)
        }

        // Check streak achievements
        if streakCount == 3 {
            unlockAchievement(Achievement.allAchievements.first(where: { $0.achievementKey == "streak_3" })!)
        } else if streakCount == 7 {
            unlockAchievement(Achievement.allAchievements.first(where: { $0.achievementKey == "streak_7" })!)
        } else if streakCount == 30 {
            unlockAchievement(Achievement.allAchievements.first(where: { $0.achievementKey == "streak_30" })!)
        }

        // Check log count milestones
        if logs.count == 10 {
            unlockAchievement(Achievement.allAchievements.first(where: { $0.achievementKey == "logs_10" })!)
        } else if logs.count == 50 {
            unlockAchievement(Achievement.allAchievements.first(where: { $0.achievementKey == "logs_50" })!)
        } else if logs.count == 100 {
            unlockAchievement(Achievement.allAchievements.first(where: { $0.achievementKey == "logs_100" })!)
        }
    }

    private func unlockAchievement(_ achievement: Achievement) {
        recentAchievement = achievement
        totalFlushFunds += achievement.flushFundsReward
        showAchievementUnlock = true
    }

    // MARK: - Sharing (VIRAL FEATURE!)

    func shareAchievement(_ achievement: Achievement) {
        shareItems = ShareHelper.shareAchievement(achievement, streakCount: streakCount)
        showShareSheet = true
    }
}
