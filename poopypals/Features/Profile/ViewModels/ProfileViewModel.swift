//
//  ProfileViewModel.swift
//  PoopyPals
//
//  Profile Screen - ViewModel
//

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published var totalLogs: Int = 0
    @Published var streakCount: Int = 0
    @Published var totalFlushFunds: Int = 0
    @Published var unlockedAchievements: [Achievement] = []
    @Published var isLoading = false
    @Published var errorAlert: ErrorAlert?
    
    // MARK: - Dependencies
    
    private let fetchDeviceStatsUseCase: FetchDeviceStatsUseCaseProtocol
    private let fetchUnlockedAchievementsUseCase: FetchUnlockedAchievementsUseCaseProtocol
    private let deviceService: DeviceIdentificationService
    
    // MARK: - Initialization
    
    init(
        fetchDeviceStatsUseCase: FetchDeviceStatsUseCaseProtocol? = nil,
        fetchUnlockedAchievementsUseCase: FetchUnlockedAchievementsUseCaseProtocol? = nil,
        deviceService: DeviceIdentificationService = DeviceIdentificationService()
    ) {
        let container = AppContainer.shared
        self.fetchDeviceStatsUseCase = fetchDeviceStatsUseCase ?? container.fetchDeviceStatsUseCase
        self.fetchUnlockedAchievementsUseCase = fetchUnlockedAchievementsUseCase ?? container.fetchUnlockedAchievementsUseCase
        self.deviceService = deviceService
        
        Task {
            await loadDeviceId()
            await loadData()
        }
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch device stats
            let stats = try await fetchDeviceStatsUseCase.execute()
            totalLogs = stats.totalLogs
            streakCount = stats.streakCount
            totalFlushFunds = stats.totalFlushFunds
            
            // Fetch achievements
            unlockedAchievements = try await fetchUnlockedAchievementsUseCase.execute()
        } catch {
            errorAlert = ErrorAlert(
                title: "Error Loading Profile",
                message: error.localizedDescription
            )
        }
    }
    
    // MARK: - Computed Properties
    
    @Published var deviceIdString: String = "Loading..."
    
    private func loadDeviceId() async {
        do {
            let id = try await deviceService.getDeviceId()
            deviceIdString = id.uuidString.prefix(8).uppercased()
        } catch {
            deviceIdString = "UNKNOWN"
        }
    }
}

