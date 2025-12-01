//
//  LeaderboardViewModel.swift
//  PoopyPals
//
//  Leaderboard Screen - ViewModel
//

import Foundation
import SwiftUI

@MainActor
class LeaderboardViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published var entries: [LeaderboardEntry] = []
    @Published var currentUserRank: LeaderboardEntry?
    @Published var selectedPeriod: LeaderboardPeriod = .weekly
    @Published var selectedMetric: LeaderboardMetric = .streak
    @Published var isLoading = false
    @Published var errorAlert: ErrorAlert?
    
    // MARK: - Dependencies
    
    private let fetchLeaderboardUseCase: FetchLeaderboardUseCaseProtocol
    private let fetchUserRankUseCase: FetchUserRankUseCaseProtocol
    private let deviceService: DeviceIdentificationService
    
    // MARK: - Initialization
    
    init(
        fetchLeaderboardUseCase: FetchLeaderboardUseCaseProtocol? = nil,
        fetchUserRankUseCase: FetchUserRankUseCaseProtocol? = nil,
        deviceService: DeviceIdentificationService = DeviceIdentificationService()
    ) {
        let container = AppContainer.shared
        self.fetchLeaderboardUseCase = fetchLeaderboardUseCase ?? container.fetchLeaderboardUseCase
        self.fetchUserRankUseCase = fetchUserRankUseCase ?? container.fetchUserRankUseCase
        self.deviceService = deviceService
    }
    
    // MARK: - Public Methods
    
    func loadLeaderboard() async {
        var transaction = Transaction(animation: nil)
        withTransaction(transaction) {
            isLoading = true
        }
        
        defer {
            withTransaction(transaction) {
                isLoading = false
            }
        }
        
        do {
            // Fetch leaderboard entries
            // Note: isCurrentUser is already set by data source using internal device ID
            let fetchedEntries = try await fetchLeaderboardUseCase.execute(
                period: selectedPeriod,
                metric: selectedMetric,
                limit: 100
            )
            
            // Fetch user's rank if not in top 100
            var fetchedUserRank: LeaderboardEntry? = nil
            if !fetchedEntries.contains(where: { $0.isCurrentUser }) {
                fetchedUserRank = try await fetchUserRankUseCase.execute(
                    period: selectedPeriod,
                    metric: selectedMetric
                )
            }
            
            // Update state without animation
            withTransaction(transaction) {
                entries = fetchedEntries
                currentUserRank = fetchedUserRank
            }
        } catch {
            withTransaction(transaction) {
                errorAlert = ErrorAlert(
                    title: "Error Loading Leaderboard",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    func changePeriod(_ period: LeaderboardPeriod) {
        selectedPeriod = period
        Task {
            await loadLeaderboard()
        }
    }
    
    func changeMetric(_ metric: LeaderboardMetric) {
        selectedMetric = metric
        Task {
            await loadLeaderboard()
        }
    }
    
    // MARK: - Computed Properties
    
    var topThree: [LeaderboardEntry] {
        Array(entries.prefix(3))
    }
    
    var remainingEntries: [LeaderboardEntry] {
        Array(entries.dropFirst(3))
    }
}

