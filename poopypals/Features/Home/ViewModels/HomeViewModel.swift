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
    @Published var errorAlert: ErrorAlert?

    // Recent achievement (for showing unlock)
    @Published var recentAchievement: Achievement?
    @Published var showAchievementUnlock: Bool = false

    // MARK: - Dependencies
    
    private var fetchPoopLogsUseCase: FetchPoopLogsUseCaseProtocol!
    private var fetchTodayLogsUseCase: FetchTodayLogsUseCaseProtocol!
    private var createPoopLogUseCase: CreatePoopLogUseCaseProtocol!
    private var calculateStreakUseCase: CalculateStreakUseCaseProtocol!
    private var fetchDeviceStatsUseCase: FetchDeviceStatsUseCaseProtocol!
    private var updateFlushFundsUseCase: UpdateFlushFundsUseCaseProtocol!
    private var fetchUnlockedAchievementsUseCase: FetchUnlockedAchievementsUseCaseProtocol!
    private var unlockAchievementUseCase: UnlockAchievementUseCaseProtocol!

    // MARK: - Initialization

    init(
        fetchPoopLogsUseCase: FetchPoopLogsUseCaseProtocol? = nil,
        fetchTodayLogsUseCase: FetchTodayLogsUseCaseProtocol? = nil,
        createPoopLogUseCase: CreatePoopLogUseCaseProtocol? = nil,
        calculateStreakUseCase: CalculateStreakUseCaseProtocol? = nil,
        fetchDeviceStatsUseCase: FetchDeviceStatsUseCaseProtocol? = nil,
        updateFlushFundsUseCase: UpdateFlushFundsUseCaseProtocol? = nil,
        fetchUnlockedAchievementsUseCase: FetchUnlockedAchievementsUseCaseProtocol? = nil,
        unlockAchievementUseCase: UnlockAchievementUseCaseProtocol? = nil
    ) {
        // Get container on main actor
        let container = AppContainer.shared
        self.fetchPoopLogsUseCase = fetchPoopLogsUseCase ?? container.fetchPoopLogsUseCase
        self.fetchTodayLogsUseCase = fetchTodayLogsUseCase ?? container.fetchTodayLogsUseCase
        self.createPoopLogUseCase = createPoopLogUseCase ?? container.createPoopLogUseCase
        self.calculateStreakUseCase = calculateStreakUseCase ?? container.calculateStreakUseCase
        self.fetchDeviceStatsUseCase = fetchDeviceStatsUseCase ?? container.fetchDeviceStatsUseCase
        self.updateFlushFundsUseCase = updateFlushFundsUseCase ?? container.updateFlushFundsUseCase
        self.fetchUnlockedAchievementsUseCase = fetchUnlockedAchievementsUseCase ?? container.fetchUnlockedAchievementsUseCase
        self.unlockAchievementUseCase = unlockAchievementUseCase ?? container.unlockAchievementUseCase
        
        // Load initial data
        Task {
            await loadData()
        }
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch logs
            logs = try await fetchPoopLogsUseCase.execute(limit: 100, offset: 0)
            
            // Fetch today's logs
            todayLogs = try await fetchTodayLogsUseCase.execute()
            
            // Calculate streak
            streakCount = try await calculateStreakUseCase.execute()
            
            // Fetch device stats
            let stats = try await fetchDeviceStatsUseCase.execute()
            totalFlushFunds = stats.totalFlushFunds
        } catch {
            errorAlert = ErrorAlert(
                title: "Error",
                message: error.localizedDescription
            )
        }
    }

    // MARK: - Quick Log (VIRAL FEATURE - Fast onboarding)

    func quickLog(rating: PoopLog.Rating, durationSeconds: Int = 120, consistency: Int = 4) {
        Task {
            do {
                let newLog = PoopLog(
                    durationSeconds: durationSeconds,
                    rating: rating,
                    consistency: consistency,
                    flushFundsEarned: 10
                )

                // Create log via UseCase
                let createdLog = try await createPoopLogUseCase.execute(newLog)
                
                // Update local state
                logs.insert(createdLog, at: 0)
                todayLogs = try await fetchTodayLogsUseCase.execute()
                
                // Update flush funds
                try await updateFlushFundsUseCase.execute(amount: createdLog.flushFundsEarned)
                let stats = try await fetchDeviceStatsUseCase.execute()
                totalFlushFunds = stats.totalFlushFunds

                // Update streak
                streakCount = try await calculateStreakUseCase.execute()

                // Check for achievements
                await checkForAchievements()
            } catch {
                errorAlert = ErrorAlert(
                    title: "Error",
                    message: error.localizedDescription
                )
            }
        }
    }

    // MARK: - Helper Functions

    // Removed - now using UseCases

    // MARK: - Achievement System

    private func checkForAchievements() async {
        do {
            let unlocked = try await fetchUnlockedAchievementsUseCase.execute()
            let unlockedKeys = Set(unlocked.map { $0.achievementKey })
            
            // Check if first log
            if logs.count == 1 && !unlockedKeys.contains("first_log") {
                if let achievement = Achievement.allAchievements.first(where: { $0.achievementKey == "first_log" }) {
                    await unlockAchievement(achievement)
                }
            }

            // Check streak achievements
            if streakCount == 3 && !unlockedKeys.contains("streak_3") {
                if let achievement = Achievement.allAchievements.first(where: { $0.achievementKey == "streak_3" }) {
                    await unlockAchievement(achievement)
                }
            } else if streakCount == 7 && !unlockedKeys.contains("streak_7") {
                if let achievement = Achievement.allAchievements.first(where: { $0.achievementKey == "streak_7" }) {
                    await unlockAchievement(achievement)
                }
            } else if streakCount == 30 && !unlockedKeys.contains("streak_30") {
                if let achievement = Achievement.allAchievements.first(where: { $0.achievementKey == "streak_30" }) {
                    await unlockAchievement(achievement)
                }
            }

            // Check log count milestones
            if logs.count == 10 && !unlockedKeys.contains("logs_10") {
                if let achievement = Achievement.allAchievements.first(where: { $0.achievementKey == "logs_10" }) {
                    await unlockAchievement(achievement)
                }
            } else if logs.count == 50 && !unlockedKeys.contains("logs_50") {
                if let achievement = Achievement.allAchievements.first(where: { $0.achievementKey == "logs_50" }) {
                    await unlockAchievement(achievement)
                }
            } else if logs.count == 100 && !unlockedKeys.contains("logs_100") {
                if let achievement = Achievement.allAchievements.first(where: { $0.achievementKey == "logs_100" }) {
                    await unlockAchievement(achievement)
                }
            }
        } catch {
            print("Failed to check achievements: \(error)")
        }
    }

    private func unlockAchievement(_ achievement: Achievement) async {
        do {
            let unlocked = try await unlockAchievementUseCase.execute(achievement)
            recentAchievement = unlocked
            
            // Update flush funds
            try await updateFlushFundsUseCase.execute(amount: unlocked.flushFundsReward)
            let stats = try await fetchDeviceStatsUseCase.execute()
            totalFlushFunds = stats.totalFlushFunds
            
            showAchievementUnlock = true
        } catch {
            print("Failed to unlock achievement: \(error)")
        }
    }

    // MARK: - Computed Properties
    
    var todayFlushFunds: Int {
        todayLogs.reduce(0) { $0 + $1.flushFundsEarned }
    }

    // MARK: - Sharing (VIRAL FEATURE!)

    func shareAchievement(_ achievement: Achievement) {
        shareItems = ShareHelper.shareAchievement(achievement, streakCount: streakCount)
        showShareSheet = true
    }
}
