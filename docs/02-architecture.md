# PoopyPals iOS - Architecture & Folder Structure

## 🏛️ Architecture Overview

PoopyPals follows **Clean Architecture** principles with **MVVM** pattern, ensuring:
- Clear separation of concerns
- Testability at every layer
- Independence from frameworks
- Flexibility for future changes

## 📐 Architecture Layers

```
┌─────────────────────────────────────────┐
│           Presentation Layer             │
│  (Views, ViewModels, Coordinators)      │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│            Domain Layer                  │
│     (Entities, Use Cases, Protocols)     │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│             Data Layer                   │
│  (Repositories, Services, Data Sources)  │
└─────────────────────────────────────────┘
```

### Presentation Layer
**Responsibility:** UI and user interaction handling

- **Views (SwiftUI):** Pure UI components, no business logic
- **ViewModels:** Presentation logic, state management, user actions
- **Coordinators:** Navigation and flow management

### Domain Layer
**Responsibility:** Core business logic and rules

- **Entities:** Business models (PoopLog, Achievement, Avatar)
- **Use Cases:** Business operations (LogPoopUseCase, UpdateStreakUseCase)
- **Repository Protocols:** Data access abstractions

### Data Layer
**Responsibility:** Data persistence and external services

- **Repositories:** Implement repository protocols
- **Services:** Supabase, device storage, sync logic
- **Data Sources:** Remote (Supabase) and Local (UserDefaults)

## 📁 Folder Structure

```
PoopyPals/
├── App/
│   ├── PoopyPalsApp.swift                 # App entry point
│   ├── AppDelegate.swift                  # App lifecycle (if needed)
│   └── AppCoordinator.swift               # Root coordinator
│
├── Core/
│   ├── DesignSystem/
│   │   ├── Colors/
│   │   │   ├── PPColors.swift             # Color palette
│   │   │   └── ColorTokens.swift          # Semantic tokens
│   │   ├── Typography/
│   │   │   ├── PPTypography.swift         # Font styles
│   │   │   └── TextStyles.swift           # Text modifiers
│   │   ├── Spacing/
│   │   │   └── PPSpacing.swift            # Spacing constants
│   │   └── Components/
│   │       ├── Buttons/
│   │       │   ├── PPButton.swift         # Primary button
│   │       │   └── PPIconButton.swift     # Icon button
│   │       ├── Cards/
│   │       │   ├── PPCard.swift           # Base card
│   │       │   └── PPLogCard.swift        # Log entry card
│   │       ├── Inputs/
│   │       │   ├── PPTextField.swift      # Text input
│   │       │   ├── PPSlider.swift         # Custom slider
│   │       │   └── PPRatingPicker.swift   # Emoji rating
│   │       └── Indicators/
│   │           ├── PPProgressRing.swift   # Circular progress
│   │           └── PPStreakBadge.swift    # Streak indicator
│   │
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── String+Extensions.swift
│   │   ├── View+Extensions.swift
│   │   └── Color+Extensions.swift
│   │
│   ├── Utilities/
│   │   ├── DateFormatter+Shared.swift
│   │   ├── NumberFormatter+Shared.swift
│   │   ├── HapticManager.swift
│   │   └── Logger.swift
│   │
│   └── Configuration/
│       ├── AppConfig.swift                # App configuration
│       ├── Environment.swift              # Dev/Prod environments
│       └── FeatureFlags.swift             # Feature toggles
│
├── Domain/
│   ├── Entities/
│   │   ├── PoopLog.swift
│   │   ├── User.swift
│   │   ├── Achievement.swift
│   │   ├── Challenge.swift
│   │   ├── Avatar.swift
│   │   └── Notification.swift
│   │
│   ├── UseCases/
│   │   ├── PoopLog/
│   │   │   ├── CreatePoopLogUseCase.swift
│   │   │   ├── FetchPoopLogsUseCase.swift
│   │   │   └── DeletePoopLogUseCase.swift
│   │   ├── Streak/
│   │   │   ├── CalculateStreakUseCase.swift
│   │   │   └── UpdateStreakUseCase.swift
│   │   ├── Avatar/
│   │   │   ├── UnlockComponentUseCase.swift
│   │   │   └── UpdateAvatarUseCase.swift
│   │   └── Challenges/
│   │       ├── CheckChallengeProgressUseCase.swift
│   │       └── CompleteChallengeUseCase.swift
│   │
│   └── RepositoryProtocols/
│       ├── PoopLogRepositoryProtocol.swift
│       ├── UserRepositoryProtocol.swift
│       ├── AvatarRepositoryProtocol.swift
│       └── ChallengeRepositoryProtocol.swift
│
├── Data/
│   ├── Repositories/
│   │   ├── PoopLogRepository.swift        # Implements PoopLogRepositoryProtocol
│   │   ├── UserRepository.swift
│   │   ├── AvatarRepository.swift
│   │   └── ChallengeRepository.swift
│   │
│   ├── Services/
│   │   ├── Supabase/
│   │   │   ├── SupabaseService.swift      # Supabase client wrapper
│   │   │   ├── SupabaseConfig.swift       # API keys, URLs
│   │   │   └── SupabaseModels.swift       # DTO models
│   │   ├── Device/
│   │   │   ├── DeviceIDService.swift      # Device identification
│   │   │   └── KeychainService.swift      # Secure storage
│   │   ├── Sync/
│   │   │   ├── SyncService.swift          # Background sync
│   │   │   └── SyncStrategy.swift         # Sync logic
│   │   └── Analytics/
│   │       └── AnalyticsService.swift     # Local analytics (future)
│   │
│   └── DataSources/
│       ├── Remote/
│       │   ├── RemotePoopLogDataSource.swift
│       │   ├── RemoteUserDataSource.swift
│       │   └── RemoteAvatarDataSource.swift
│       └── Local/
│           ├── LocalPreferencesDataSource.swift
│           └── LocalCacheDataSource.swift
│
├── Features/
│   ├── Home/
│   │   ├── Views/
│   │   │   ├── HomeView.swift
│   │   │   ├── QuickLogButton.swift
│   │   │   └── StreakCardView.swift
│   │   ├── ViewModels/
│   │   │   └── HomeViewModel.swift
│   │   └── Coordinators/
│   │       └── HomeCoordinator.swift
│   │
│   ├── PoopLog/
│   │   ├── Views/
│   │   │   ├── CreateLogView.swift
│   │   │   ├── DurationTimerView.swift
│   │   │   ├── RatingPickerView.swift
│   │   │   └── ConsistencySliderView.swift
│   │   ├── ViewModels/
│   │   │   └── CreateLogViewModel.swift
│   │   └── Coordinators/
│   │       └── LogCoordinator.swift
│   │
│   ├── History/
│   │   ├── Views/
│   │   │   ├── HistoryView.swift
│   │   │   ├── CalendarView.swift
│   │   │   ├── LogListView.swift
│   │   │   └── LogDetailView.swift
│   │   ├── ViewModels/
│   │   │   ├── HistoryViewModel.swift
│   │   │   └── LogDetailViewModel.swift
│   │   └── Coordinators/
│   │       └── HistoryCoordinator.swift
│   │
│   ├── Avatar/
│   │   ├── Views/
│   │   │   ├── AvatarEditorView.swift
│   │   │   ├── AvatarPreviewView.swift
│   │   │   ├── ComponentShopView.swift
│   │   │   └── ComponentGridView.swift
│   │   ├── ViewModels/
│   │   │   ├── AvatarEditorViewModel.swift
│   │   │   └── ComponentShopViewModel.swift
│   │   └── Coordinators/
│   │       └── AvatarCoordinator.swift
│   │
│   ├── Profile/
│   │   ├── Views/
│   │   │   ├── ProfileView.swift
│   │   │   ├── StatsCardView.swift
│   │   │   ├── AchievementsView.swift
│   │   │   └── SettingsView.swift
│   │   ├── ViewModels/
│   │   │   ├── ProfileViewModel.swift
│   │   │   └── SettingsViewModel.swift
│   │   └── Coordinators/
│   │       └── ProfileCoordinator.swift
│   │
│   └── Onboarding/
│       ├── Views/
│       │   ├── OnboardingFlowView.swift
│       │   ├── WelcomeView.swift
│       │   └── PermissionsView.swift
│       ├── ViewModels/
│       │   └── OnboardingViewModel.swift
│       └── Coordinators/
│           └── OnboardingCoordinator.swift
│
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── Colors/
│   │   └── Images/
│   ├── Localizable.strings              # Localization (future)
│   └── Info.plist
│
└── Tests/
    ├── UnitTests/
    │   ├── Domain/
    │   │   ├── UseCases/
    │   │   └── Entities/
    │   ├── Data/
    │   │   ├── Repositories/
    │   │   └── Services/
    │   └── Presentation/
    │       └── ViewModels/
    │
    └── UITests/
        ├── HomeFlowTests.swift
        ├── LogCreationFlowTests.swift
        └── HistoryFlowTests.swift
```

## 🎯 MVVM Pattern in Detail

### View (SwiftUI)
```swift
struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        // Pure declarative UI
        // No business logic
        // Binds to ViewModel
    }
}
```

### ViewModel (ObservableObject)
```swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var streakCount: Int = 0
    @Published var todayLogs: [PoopLog] = []
    @Published var isLoading: Bool = false

    private let fetchLogsUseCase: FetchPoopLogsUseCase
    private let updateStreakUseCase: UpdateStreakUseCase

    // Handle user actions
    // Coordinate use cases
    // Manage presentation state
}
```

### Use Case (Business Logic)
```swift
protocol FetchPoopLogsUseCase {
    func execute(for date: Date) async throws -> [PoopLog]
}

class DefaultFetchPoopLogsUseCase: FetchPoopLogsUseCase {
    private let repository: PoopLogRepositoryProtocol

    func execute(for date: Date) async throws -> [PoopLog] {
        // Pure business logic
        // Independent of UI
        // Testable
    }
}
```

### Repository (Data Access)
```swift
protocol PoopLogRepositoryProtocol {
    func fetchLogs(for date: Date) async throws -> [PoopLog]
    func createLog(_ log: PoopLog) async throws -> PoopLog
}

class PoopLogRepository: PoopLogRepositoryProtocol {
    private let remoteDataSource: RemotePoopLogDataSource

    // Implements data access
    // Handles caching, sync
    // Abstracts data source details
}
```

## 🔄 Data Flow

```
User Action (View)
        ↓
ViewModel receives action
        ↓
ViewModel calls Use Case
        ↓
Use Case executes business logic
        ↓
Use Case calls Repository
        ↓
Repository fetches/stores data (Supabase)
        ↓
Repository returns domain entities
        ↓
Use Case returns result to ViewModel
        ↓
ViewModel updates @Published properties
        ↓
View automatically re-renders
```

## 🧩 Dependency Injection

### Container Pattern
```swift
class AppDependencyContainer {
    // Services (Singletons)
    lazy var supabaseService: SupabaseService = {
        SupabaseService(config: SupabaseConfig.shared)
    }()

    lazy var deviceIDService: DeviceIDService = {
        DeviceIDService(keychainService: KeychainService())
    }()

    // Repositories
    func makePoopLogRepository() -> PoopLogRepositoryProtocol {
        PoopLogRepository(
            remoteDataSource: RemotePoopLogDataSource(supabase: supabaseService),
            deviceIDService: deviceIDService
        )
    }

    // Use Cases
    func makeFetchLogsUseCase() -> FetchPoopLogsUseCase {
        DefaultFetchPoopLogsUseCase(
            repository: makePoopLogRepository()
        )
    }

    // ViewModels
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchLogsUseCase: makeFetchLogsUseCase(),
            updateStreakUseCase: makeUpdateStreakUseCase()
        )
    }
}
```

## 🧪 Testing Strategy

### Unit Tests
- **Domain Layer:** Test use cases in isolation
- **ViewModels:** Test state changes and user actions
- **Repositories:** Test with mock data sources

### Integration Tests
- **Supabase Integration:** Test real API calls (test environment)
- **Sync Logic:** Test conflict resolution

### UI Tests
- **User Flows:** Test complete user journeys
- **Accessibility:** Test VoiceOver navigation

## 📋 Coding Conventions

### Naming
- **Protocols:** Suffix with `Protocol` (e.g., `PoopLogRepositoryProtocol`)
- **Use Cases:** Descriptive verbs (e.g., `CreatePoopLogUseCase`)
- **ViewModels:** Feature + `ViewModel` (e.g., `HomeViewModel`)
- **Views:** Feature + `View` (e.g., `HomeView`)

### File Organization
- One type per file
- Group related files in folders
- Keep files under 300 lines

### SwiftUI Best Practices
- Extract subviews for clarity
- Use `@StateObject` for ownership, `@ObservedObject` for passing
- Prefer `@Published` over `@State` in ViewModels
- Use view extensions for reusability

### Async/Await
- Use `async/await` for all async operations
- Mark ViewModels with `@MainActor` for UI safety
- Handle errors with `do-catch` blocks

## 🚀 Performance Considerations

- **Lazy Loading:** Load data only when needed
- **Pagination:** Fetch logs in chunks (30 items)
- **Image Caching:** Cache avatar components
- **Background Sync:** Sync in background task
- **Memory Management:** Use weak references in closures

## 📚 Related Documentation

- [Database Schema](./03-database-schema.md)
- [Design System](./04-design-system.md)
- [Supabase Integration](./05-supabase-integration.md)

---

**Last Updated:** 2025-11-11
**Version:** 1.0.0
