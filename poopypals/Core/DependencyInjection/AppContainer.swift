//
//  AppContainer.swift
//  PoopyPals
//
//  Dependency Injection Container
//

import Foundation

@MainActor
class AppContainer: ObservableObject {
    static let shared = AppContainer()
    
    // MARK: - Services (Singletons)
    
    lazy var deviceService: DeviceIdentificationService = {
        DeviceIdentificationService()
    }()
    
    lazy var supabaseService: SupabaseService = {
        SupabaseService.shared
    }()
    
    lazy var syncService: SyncService = {
        SyncService.shared
    }()
    
    // MARK: - Data Sources
    
    lazy var localPoopLogDataSource: LocalPoopLogDataSourceProtocol = {
        LocalPoopLogDataSource()
    }()
    
    lazy var localAchievementDataSource: LocalAchievementDataSourceProtocol = {
        LocalAchievementDataSource()
    }()
    
    lazy var localDeviceStatsDataSource: LocalDeviceStatsDataSourceProtocol = {
        LocalDeviceStatsDataSource()
    }()
    
    lazy var remotePoopLogDataSource: RemotePoopLogDataSourceProtocol = {
        SupabasePoopLogDataSource(
            supabaseService: supabaseService,
            deviceService: deviceService
        )
    }()
    
    lazy var remoteAchievementDataSource: RemoteAchievementDataSourceProtocol = {
        SupabaseAchievementDataSource(
            supabaseService: supabaseService,
            deviceService: deviceService
        )
    }()
    
    lazy var remoteDeviceStatsDataSource: RemoteDeviceStatsDataSourceProtocol = {
        SupabaseDeviceStatsDataSource(
            supabaseService: supabaseService,
            deviceService: deviceService
        )
    }()
    
    lazy var remoteLeaderboardDataSource: RemoteLeaderboardDataSourceProtocol = {
        SupabaseLeaderboardDataSource(
            supabaseService: supabaseService,
            deviceService: deviceService
        )
    }()
    
    // MARK: - Repositories
    
    lazy var poopLogRepository: PoopLogRepositoryProtocol = {
        PoopLogRepository(
            localDataSource: localPoopLogDataSource,
            remoteDataSource: remotePoopLogDataSource,
            deviceService: deviceService,
            syncService: syncService
        )
    }()
    
    lazy var achievementRepository: AchievementRepositoryProtocol = {
        AchievementRepository(
            localDataSource: localAchievementDataSource,
            remoteDataSource: remoteAchievementDataSource,
            deviceService: deviceService,
            syncService: syncService
        )
    }()
    
    lazy var deviceStatsRepository: DeviceStatsRepositoryProtocol = {
        DeviceStatsRepository(
            localDataSource: localDeviceStatsDataSource,
            remoteDataSource: remoteDeviceStatsDataSource,
            deviceService: deviceService
        )
    }()
    
    lazy var leaderboardRepository: LeaderboardRepositoryProtocol = {
        LeaderboardRepository(
            remoteDataSource: remoteLeaderboardDataSource,
            deviceService: deviceService
        )
    }()
    
    // MARK: - Use Cases
    
    lazy var fetchPoopLogsUseCase: FetchPoopLogsUseCaseProtocol = {
        FetchPoopLogsUseCase(repository: poopLogRepository)
    }()
    
    lazy var fetchTodayLogsUseCase: FetchTodayLogsUseCaseProtocol = {
        FetchTodayLogsUseCase(repository: poopLogRepository)
    }()
    
    lazy var createPoopLogUseCase: CreatePoopLogUseCaseProtocol = {
        CreatePoopLogUseCase(repository: poopLogRepository)
    }()
    
    lazy var updatePoopLogUseCase: UpdatePoopLogUseCaseProtocol = {
        UpdatePoopLogUseCase(repository: poopLogRepository)
    }()
    
    lazy var deletePoopLogUseCase: DeletePoopLogUseCaseProtocol = {
        DeletePoopLogUseCase(repository: poopLogRepository)
    }()
    
    lazy var fetchUnlockedAchievementsUseCase: FetchUnlockedAchievementsUseCaseProtocol = {
        FetchUnlockedAchievementsUseCase(repository: achievementRepository)
    }()
    
    lazy var unlockAchievementUseCase: UnlockAchievementUseCaseProtocol = {
        UnlockAchievementUseCase(repository: achievementRepository)
    }()
    
    lazy var markAchievementViewedUseCase: MarkAchievementViewedUseCaseProtocol = {
        MarkAchievementViewedUseCase(repository: achievementRepository)
    }()
    
    lazy var calculateStreakUseCase: CalculateStreakUseCaseProtocol = {
        CalculateStreakUseCase(repository: poopLogRepository)
    }()
    
    lazy var updateStreakUseCase: UpdateStreakUseCaseProtocol = {
        UpdateStreakUseCase(repository: deviceStatsRepository)
    }()
    
    lazy var fetchDeviceStatsUseCase: FetchDeviceStatsUseCaseProtocol = {
        FetchDeviceStatsUseCase(repository: deviceStatsRepository)
    }()
    
    lazy var updateFlushFundsUseCase: UpdateFlushFundsUseCaseProtocol = {
        UpdateFlushFundsUseCase(repository: deviceStatsRepository)
    }()
    
    lazy var fetchLeaderboardUseCase: FetchLeaderboardUseCaseProtocol = {
        FetchLeaderboardUseCase(repository: leaderboardRepository)
    }()
    
    lazy var fetchUserRankUseCase: FetchUserRankUseCaseProtocol = {
        FetchUserRankUseCase(repository: leaderboardRepository)
    }()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - App Lifecycle
    
    func initialize() async {
        // Test backend connection
        await BackendTester.shared.testConnection()
        
        // Register device
        do {
            _ = try await supabaseService.registerDevice()
        } catch {
            print("Device registration failed: \(error)")
        }
        
        // Check connection
        await supabaseService.checkConnection()
        
        // Start background sync
        syncService.startBackgroundSync()
    }
}

