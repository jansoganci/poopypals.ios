# CLAUDE.md - AI Assistant Guide for PoopyPals iOS

> **Last Updated:** 2025-11-15
> **Project:** PoopyPals - Gamified Digestive Health Tracker
> **Platform:** iOS 17.0+ | Swift 5.9+ | SwiftUI

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Project Overview](#project-overview)
3. [Architecture & Patterns](#architecture--patterns)
4. [Codebase Structure](#codebase-structure)
5. [Design System](#design-system)
6. [Development Conventions](#development-conventions)
7. [Common Tasks](#common-tasks)
8. [Testing Strategy](#testing-strategy)
9. [Database & Backend](#database--backend)
10. [Key Files Reference](#key-files-reference)
11. [Important Rules](#important-rules)

---

## 🚀 Quick Start

### Project Context
**PoopyPals** is a privacy-first, gamified iOS app for tracking bathroom habits. Users earn "Flush Funds" currency, unlock achievements, maintain streaks, and customize avatars - all without creating an account.

### Technology Stack
- **Platform:** iOS 17.0+, SwiftUI-first
- **Architecture:** MVVM + Clean Architecture
- **Backend:** Supabase (PostgreSQL) with device-based auth
- **State Management:** Combine + async/await
- **Dependencies:** Swift Package Manager (SPM)
- **Security:** Keychain for device IDs, RLS policies

### Development Status
- ✅ **Complete:** Core architecture, design system, UI components, mock data flows
- 🔄 **In Progress:** Supabase integration, device identification, data persistence
- ⏳ **Planned:** Unit tests, avatar system, challenges, history features

---

## 📖 Project Overview

### Core Features (MVP)
1. **Quick Log** - One-tap bathroom visit logging
2. **Streak Tracking** - Daily consistency gamification
3. **Achievements** - Milestone unlocks with shareability
4. **Flush Funds** - Virtual currency system
5. **Avatar Customization** - Cosmetic rewards (planned)

### Key Principles
- **Privacy-First:** No authentication, device-based identification only
- **Offline-First:** Full functionality without network
- **Zero-Friction:** Quick logging in <3 seconds
- **Gamification:** Streaks, achievements, rewards drive engagement
- **No PII:** Never collect names, emails, or personal data

### User Flow
```
Launch App → Quick Log Button → Select Rating (great/good/okay/bad/terrible)
→ Optional Details (duration, consistency, notes) → Save & Earn Flush Funds
→ Check Achievements → View Streak → Customize Avatar
```

---

## 🏗️ Architecture & Patterns

### MVVM + Clean Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Presentation                      │
│  (Views + ViewModels)                              │
│  - HomeView.swift                                   │
│  - HomeViewModel.swift (@MainActor)                 │
└──────────────────┬──────────────────────────────────┘
                   │ Observes @Published properties
┌──────────────────▼──────────────────────────────────┐
│                    Domain                           │
│  (Entities + Use Cases)                            │
│  - PoopLog.swift, Achievement.swift                 │
│  - CreatePoopLogUseCase, CalculateStreakUseCase     │
└──────────────────┬──────────────────────────────────┘
                   │ Calls repository protocols
┌──────────────────▼──────────────────────────────────┐
│                     Data                            │
│  (Repositories + Data Sources)                     │
│  - PoopLogRepository.swift                          │
│  - SupabaseDataSource.swift, LocalDataSource.swift │
└─────────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Purpose | Examples |
|-------|---------|----------|
| **Presentation** | UI rendering, user interaction | `HomeView`, `HomeViewModel` |
| **Domain** | Business logic, entities | `PoopLog`, `Achievement`, use cases |
| **Data** | Data access, persistence | Repositories, Supabase client, Keychain |

### Key Patterns

#### 1. ViewModel Pattern
```swift
@MainActor
class HomeViewModel: ObservableObject {
    // Published state for UI binding
    @Published var logs: [PoopLog] = []
    @Published var streakCount: Int = 0
    @Published var errorAlert: ErrorAlert?

    // Dependency injection
    private let fetchLogsUseCase: FetchLogsUseCase

    init(fetchLogsUseCase: FetchLogsUseCase) {
        self.fetchLogsUseCase = fetchLogsUseCase
    }

    // Async methods for data fetching
    func loadData() async {
        do {
            logs = try await fetchLogsUseCase.execute()
        } catch {
            handleError(error)
        }
    }
}
```

#### 2. Protocol-Oriented Design
```swift
// Define contract
protocol PoopLogRepositoryProtocol {
    func fetchLogs(for deviceId: String) async throws -> [PoopLog]
    func createLog(_ log: PoopLog) async throws
}

// Concrete implementation
class PoopLogRepository: PoopLogRepositoryProtocol {
    private let remoteDataSource: SupabaseDataSource
    private let localDataSource: LocalDataSource
    // Implementation...
}
```

#### 3. View Composition
```swift
var body: some View {
    VStack {
        headerSection
        contentSection
        footerSection
    }
}

// Extract subviews for readability
private var headerSection: some View {
    HStack {
        Text("Welcome")
            .font(.ppTitle1)
    }
}
```

---

## 📁 Codebase Structure

```
poopypals.ios/
├── poopypals/                      # Main app source
│   ├── poopypalsApp.swift          # @main entry point
│   ├── ContentView.swift           # Root view placeholder
│   │
│   ├── Core/                       # Shared infrastructure
│   │   ├── DesignSystem/           # Reusable UI components
│   │   │   ├── Colors/
│   │   │   │   └── PPColors.swift              # Color palette
│   │   │   ├── Typography/
│   │   │   │   └── PPTypography.swift          # Font styles
│   │   │   ├── Spacing/
│   │   │   │   └── PPSpacing.swift             # 8pt grid system
│   │   │   ├── Components/
│   │   │   │   ├── BounceButton.swift          # Animated button
│   │   │   │   ├── GlossyCard.swift            # 3D card component
│   │   │   │   ├── AnimatedNumber.swift        # Number counter
│   │   │   │   ├── AnimatedFlame.swift         # Streak flame
│   │   │   │   ├── ConfettiView.swift          # Celebration effect
│   │   │   │   └── ShareableAchievementCard.swift
│   │   │   └── Extensions/
│   │   │       └── View+Animations.swift
│   │   └── Utilities/
│   │       └── HapticManager.swift             # Haptic feedback
│   │
│   ├── Domain/                     # Business logic layer
│   │   └── Entities/
│   │       ├── PoopLog.swift                   # Core data model
│   │       └── Achievement.swift               # Achievement system
│   │
│   ├── Features/                   # Feature modules (MVVM)
│   │   ├── Home/
│   │   │   ├── Views/
│   │   │   │   ├── HomeView.swift
│   │   │   │   ├── NewHomeView.swift           # Current home screen
│   │   │   │   ├── GradientBackground.swift
│   │   │   │   ├── QuickLogSection.swift
│   │   │   │   └── StatsGridSection.swift
│   │   │   └── ViewModels/
│   │   │       └── HomeViewModel.swift         # Home screen logic
│   │   └── Streak/
│   │       └── Views/
│   │           ├── StreakScreen.swift
│   │           └── StreakCard.swift
│   │
│   └── Assets.xcassets/            # Images, colors, app icon
│
├── docs/                           # Comprehensive documentation
│   ├── README.md                   # Documentation index
│   ├── 00-getting-started.md       # Setup guide
│   ├── 01-project-overview.md      # Product vision
│   ├── 02-architecture.md          # Architecture deep dive
│   ├── 03-database-schema.md       # PostgreSQL schema
│   ├── 04-design-system.md         # Design guidelines
│   ├── 05-supabase-integration.md  # Backend integration
│   ├── 06-device-identification.md # Anonymous auth
│   ├── 07-error-handling.md        # Error strategy
│   └── supabase-migrations/        # SQL migration files
│
├── .claude                         # Claude AI development rules
├── .gitignore                      # Ignored files (Config.plist, etc.)
├── README.md                       # Project README
└── poopypals.xcodeproj/            # Xcode project config
```

### File Organization Principles
1. **One type per file** - Keep files under 300 lines
2. **Group by feature** - All related code in one module
3. **Extract components** - Reusable UI in `Core/DesignSystem/Components/`
4. **Prefix design system** - All design tokens start with `PP`

---

## 🎨 Design System

### Color Palette

**Core Colors**
```swift
// Primary palette
PPColors.ppPrimary      // #6366F1 (Indigo) - Main brand color
PPColors.ppSecondary    // #10B981 (Green) - Success, streaks
PPColors.ppAccent       // #F59E0B (Amber) - Highlights, CTAs
PPColors.ppDanger       // #EF4444 (Red) - Errors, alerts

// Text colors (adaptive)
PPColors.ppTextPrimary     // System label
PPColors.ppTextSecondary   // Secondary label
PPColors.ppTextTertiary    // Tertiary label

// Rating colors
PPColors.ppRatingGreat      // #10B981 (Green)
PPColors.ppRatingGood       // #3B82F6 (Blue)
PPColors.ppRatingOkay       // #F59E0B (Amber)
PPColors.ppRatingBad        // #F97316 (Orange)
PPColors.ppRatingTerrible   // #EF4444 (Red)
```

**Hex Color Support**
```swift
Color(hex: "#6366F1")  // Custom hex initializer
```

### Typography

```swift
// Display styles
.font(.ppDisplayLarge)   // 34pt Bold - Large headings
.font(.ppDisplayMedium)  // 28pt Bold - Medium headings

// Title styles
.font(.ppTitle1)         // 28pt Semibold - Main titles
.font(.ppTitle2)         // 22pt Semibold - Section titles

// Body styles
.font(.ppBody)           // 15pt Regular - Body text
.font(.ppLabel)          // 13pt Medium - Labels

// Specialized
.font(.ppNumberMedium)   // 32pt Bold - Stat numbers
```

### Spacing (8pt Grid)

```swift
// Spacing tokens
PPSpacing.xs     // 8pt  - Tiny gaps
PPSpacing.sm     // 12pt - Compact spacing
PPSpacing.md     // 16pt - Default padding ⭐ Most common
PPSpacing.lg     // 24pt - Section spacing
PPSpacing.xl     // 32pt - Large spacing
PPSpacing.xxl    // 48pt - Extra large spacing

// Corner radius
PPCornerRadius.sm    // 8pt  - Buttons, inputs
PPCornerRadius.md    // 12pt - Cards
PPCornerRadius.full  // 9999 - Circular

// Shadows
PPShadow.small   // Subtle elevation
PPShadow.medium  // Standard cards
PPShadow.large   // Prominent elements
```

### Design System Components

**Buttons**
```swift
BounceButton(action: { /* action */ }) {
    Text("Quick Log")
}
.buttonStyle(BounceButtonStyle())
```

**Cards**
```swift
GlossyCard(gradient: PPGradients.sunset) {
    VStack {
        Text("Content")
    }
}
```

**Animations**
```swift
AnimatedNumber(value: streakCount)      // Smooth number transition
AnimatedFlame(isActive: hasStreak)      // Animated flame icon
ConfettiView()                          // Celebration confetti
```

**Gradients**
```swift
PPGradients.sunset   // Orange → Pink
PPGradients.ocean    // Blue → Teal
PPGradients.fire     // Red → Orange
PPGradients.purple   // Purple → Pink
PPGradients.mint     // Green → Cyan
PPGradients.poopy    // Brown theme
```

---

## 📐 Development Conventions

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| **Protocols** | Suffix `Protocol` | `PoopLogRepositoryProtocol` |
| **Use Cases** | Verb + `UseCase` | `CreatePoopLogUseCase` |
| **ViewModels** | Feature + `ViewModel` | `HomeViewModel` |
| **Views** | Feature + `View` or descriptive | `HomeView`, `QuickLogSection` |
| **Design Tokens** | Prefix `PP` | `PPColors`, `PPButton`, `PPSpacing` |
| **Entities** | Noun (singular) | `PoopLog`, `Achievement` |
| **Enums** | PascalCase, singular | `Rating`, `AchievementType` |

### Code Organization Rules

#### 1. ViewModels
```swift
// ✅ GOOD
@MainActor  // Always annotate for thread safety
class HomeViewModel: ObservableObject {
    // MARK: - Published State
    @Published var logs: [PoopLog] = []
    @Published var isLoading = false

    // MARK: - Dependencies
    private let repository: PoopLogRepositoryProtocol

    // MARK: - Initialization
    init(repository: PoopLogRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods
    func loadData() async { }

    // MARK: - Private Methods
    private func calculateStreak() -> Int { }
}

// ❌ BAD - Missing @MainActor, no organization
class HomeViewModel: ObservableObject {
    @Published var logs: [PoopLog] = []
    func loadData() { }
    var helper: SomeType?
}
```

#### 2. SwiftUI Views
```swift
// ✅ GOOD - Extracted subviews
var body: some View {
    VStack(spacing: PPSpacing.md) {
        headerSection
        contentSection
        footerSection
    }
}

private var headerSection: some View {
    HStack {
        Text("Header")
            .font(.ppTitle1)
        Spacer()
    }
    .padding(.horizontal, PPSpacing.md)
}

// ❌ BAD - Everything inline
var body: some View {
    VStack {
        HStack {
            Text("Header")
            Spacer()
        }
        // 200 more lines...
    }
}
```

#### 3. Async/Await Pattern
```swift
// ✅ GOOD - Modern concurrency
func fetchLogs() async {
    isLoading = true
    defer { isLoading = false }

    do {
        logs = try await repository.fetchLogs()
    } catch {
        handleError(error)
    }
}

// ❌ BAD - Completion handlers (don't use)
func fetchLogs(completion: @escaping ([PoopLog]) -> Void) {
    // Don't do this
}
```

#### 4. Dependency Injection
```swift
// ✅ GOOD - Constructor injection
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(repository: PoopLogRepositoryProtocol = PoopLogRepository()) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
    }
}

// ❌ BAD - Hard-coded dependencies
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
}
```

### File Size Guidelines
- **Views:** Max 200 lines (extract subviews)
- **ViewModels:** Max 300 lines (split responsibilities)
- **Use Cases:** Max 100 lines (single responsibility)
- **Utilities:** Max 150 lines

### Code Style
```swift
// ✅ Prefer struct over class (value semantics)
struct PoopLog: Identifiable, Codable { }

// ✅ Use computed properties for derived state
var todayLogs: [PoopLog] {
    logs.filter { Calendar.current.isDateInToday($0.loggedAt) }
}

// ✅ Guard for early returns
func validate() throws {
    guard !logs.isEmpty else { throw ValidationError.noLogs }
}

// ✅ Trailing closures for readability
Button("Log") { quickLog() }

// ✅ Explicit self only when required (closures, escaping)
Task { await self.loadData() }
```

---

## 🛠️ Common Tasks

### Add a New Color
```swift
// 1. Open Core/DesignSystem/Colors/PPColors.swift
// 2. Add your color:
static let ppMyColor = Color(hex: "#123ABC")

// 3. Use in views:
Text("Hello")
    .foregroundColor(.ppMyColor)
```

### Create a New UI Component
```swift
// 1. Create file: Core/DesignSystem/Components/PPMyComponent.swift
import SwiftUI

struct PPMyComponent: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.ppBody)
                .foregroundColor(.ppTextPrimary)
                .padding(PPSpacing.md)
        }
    }
}

#Preview {
    PPMyComponent(title: "Test", action: {})
}
```

### Add a New Feature Module
```bash
# 1. Create folder structure
mkdir -p Features/MyFeature/{Views,ViewModels}

# 2. Create ViewModel: Features/MyFeature/ViewModels/MyFeatureViewModel.swift
@MainActor
class MyFeatureViewModel: ObservableObject {
    @Published var state: String = ""

    func performAction() async {
        // Logic
    }
}

# 3. Create View: Features/MyFeature/Views/MyFeatureView.swift
struct MyFeatureView: View {
    @StateObject private var viewModel = MyFeatureViewModel()

    var body: some View {
        VStack {
            Text(viewModel.state)
        }
    }
}
```

### Add a New Entity
```swift
// 1. Create file: Domain/Entities/MyEntity.swift
import Foundation

struct MyEntity: Identifiable, Codable {
    let id: UUID
    let name: String
    let createdAt: Date

    // Add custom methods
    var displayName: String {
        name.capitalized
    }
}
```

### Add Haptic Feedback
```swift
// Import utility
import HapticManager

// Trigger haptic
HapticManager.shared.light()           // Subtle feedback
HapticManager.shared.success()         // Success notification
HapticManager.shared.achievementUnlocked()  // Special pattern
```

### Run the App
```bash
# Option 1: Xcode
open poopypals.xcodeproj
# Press Cmd+R to run

# Option 2: Command line
xcodebuild -scheme poopypals -destination 'platform=iOS Simulator,name=iPhone 15 Pro' run
```

### Run Tests (when added)
```bash
xcodebuild test -scheme poopypals -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

## 🧪 Testing Strategy

### Testing Pyramid (Planned)

```
        /\
       /  \      UI Tests (10%) - Critical flows
      /    \
     /------\    Integration Tests (20%) - Feature modules
    /        \
   /----------\  Unit Tests (70%) - ViewModels, use cases, utilities
  /______________\
```

### Test File Organization (To Be Implemented)
```
Tests/
├── UnitTests/
│   ├── Domain/
│   │   ├── UseCases/
│   │   │   └── CreatePoopLogUseCaseTests.swift
│   │   └── Entities/
│   │       └── PoopLogTests.swift
│   ├── Presentation/
│   │   └── ViewModels/
│   │       └── HomeViewModelTests.swift
│   └── Data/
│       └── Repositories/
│           └── PoopLogRepositoryTests.swift
└── UITests/
    └── CriticalFlows/
        └── QuickLogFlowTests.swift
```

### Testing Guidelines (When Implementing)

```swift
// ViewModel testing pattern
@MainActor
final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockRepository: MockPoopLogRepository!

    override func setUp() async throws {
        mockRepository = MockPoopLogRepository()
        sut = HomeViewModel(repository: mockRepository)
    }

    func testLoadData_Success_UpdatesLogs() async {
        // Given
        let expectedLogs = [PoopLog.mock()]
        mockRepository.logsToReturn = expectedLogs

        // When
        await sut.loadData()

        // Then
        XCTAssertEqual(sut.logs, expectedLogs)
    }
}
```

---

## 💾 Database & Backend

### Supabase Architecture

**Tables:**
1. `devices` - Device registration and stats
2. `poop_logs` - Bathroom visit records
3. `achievements` - Achievement definitions and unlocks
4. `avatar_components` - Customization items catalog
5. `avatar_configs` - User avatar configurations
6. `challenges` - Daily/weekly challenges
7. `device_stats` - Denormalized performance data

### Key Schema Patterns

```sql
-- All tables have device_id for RLS
CREATE TABLE poop_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES devices(id),
    logged_at TIMESTAMPTZ NOT NULL,
    duration_seconds INTEGER,
    rating TEXT NOT NULL,
    consistency INTEGER,
    notes TEXT,
    flush_funds_earned INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ  -- Soft deletes for undo
);

-- Row-Level Security
ALTER TABLE poop_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their device's logs"
    ON poop_logs FOR ALL
    USING (device_id = auth.uid());
```

### Device Identification Flow

```
App Launch
    ↓
Check Keychain for device_id
    ↓
  Found? ──NO──→ Generate UUID → Save to Keychain → Register device in Supabase
    ↓ YES
Use cached device_id for all requests
```

### Data Sync Strategy (Planned)

```
Local First
    ↓
Write to local storage (immediate UI update)
    ↓
Sync to Supabase in background
    ↓
On conflict: Last-write-wins (using updated_at)
    ↓
Pull changes on app foreground
```

---

## 📚 Key Files Reference

### Must-Read Documentation
1. `/docs/02-architecture.md` - Architecture deep dive
2. `/docs/04-design-system.md` - Complete design guidelines
3. `/.claude` - Claude AI development rules

### Core Implementation Files

**Entry Point**
- `poopypals/poopypalsApp.swift` - App initialization

**Domain Layer**
- `poopypals/Domain/Entities/PoopLog.swift` - Core data model
- `poopypals/Domain/Entities/Achievement.swift` - Achievement system

**Feature Modules**
- `poopypals/Features/Home/ViewModels/HomeViewModel.swift` - Main screen logic
- `poopypals/Features/Home/Views/NewHomeView.swift` - Current home UI

**Design System**
- `poopypals/Core/DesignSystem/Colors/PPColors.swift` - Color palette
- `poopypals/Core/DesignSystem/Typography/PPTypography.swift` - Font styles
- `poopypals/Core/DesignSystem/Spacing/PPSpacing.swift` - Spacing tokens
- `poopypals/Core/DesignSystem/Components/` - Reusable components

**Utilities**
- `poopypals/Core/Utilities/HapticManager.swift` - Haptic feedback

### Configuration Files
- `poopypals.xcodeproj/project.pbxproj` - Xcode build settings
- `.gitignore` - Ignored files (Config.plist, .DS_Store, etc.)

---

## ⚠️ Important Rules

### DO ✅

1. **Always use the design system**
   - Colors from `PPColors`
   - Fonts from `PPTypography`
   - Spacing from `PPSpacing`
   - Components from `Core/DesignSystem/Components/`

2. **Follow MVVM strictly**
   - Views only render UI
   - ViewModels handle business logic
   - Use cases for complex operations
   - Repositories for data access

3. **Annotate ViewModels with @MainActor**
   ```swift
   @MainActor
   class MyViewModel: ObservableObject { }
   ```

4. **Use async/await for asynchronous operations**
   ```swift
   func loadData() async { }
   ```

5. **Inject dependencies via constructors**
   ```swift
   init(repository: PoopLogRepositoryProtocol) {
       self.repository = repository
   }
   ```

6. **Extract subviews for readability**
   - Keep `body` under 30 lines
   - Use computed properties for sections

7. **Add previews to all views**
   ```swift
   #Preview {
       MyView()
   }
   ```

8. **Use protocol-oriented design**
   - Define protocols for repositories
   - Enable testing with mocks

9. **Handle errors gracefully**
   ```swift
   do {
       try await operation()
   } catch {
       handleError(error)
   }
   ```

10. **Respect privacy**
    - Never collect PII
    - Device ID in Keychain only
    - No analytics without consent

### DON'T ❌

1. **Don't hard-code colors/fonts**
   ```swift
   // ❌ BAD
   .foregroundColor(.blue)
   .font(.system(size: 16))

   // ✅ GOOD
   .foregroundColor(.ppPrimary)
   .font(.ppBody)
   ```

2. **Don't create massive view files**
   - Extract components
   - Use computed properties
   - Create separate files for complex sections

3. **Don't use completion handlers**
   ```swift
   // ❌ BAD
   func fetch(completion: @escaping (Result<[Log], Error>) -> Void)

   // ✅ GOOD
   func fetch() async throws -> [Log]
   ```

4. **Don't skip @MainActor on ViewModels**
   - Prevents threading issues
   - Required for @Published updates

5. **Don't put business logic in Views**
   ```swift
   // ❌ BAD - Logic in view
   Button("Log") {
       let log = PoopLog(/* ... */)
       // Save logic here
   }

   // ✅ GOOD - Logic in ViewModel
   Button("Log") {
       viewModel.quickLog()
   }
   ```

6. **Don't use singletons (except utilities)**
   - `HapticManager.shared` is OK (stateless utility)
   - Inject everything else

7. **Don't commit sensitive data**
   - `Config.plist` is gitignored
   - Never commit API keys
   - Check `.gitignore` before adding files

8. **Don't create files outside feature folders**
   - Keep features self-contained
   - Share via `Core/` only

9. **Don't skip error handling**
   - Always wrap async throws in do/catch
   - Show user-friendly error messages

10. **Don't collect PII**
    - No names, emails, locations
    - Device ID only for data scoping

---

## 🎯 Current Priorities

### Immediate Next Steps (In Order)
1. ✅ **Complete Supabase integration**
   - Implement `SupabaseDataSource.swift`
   - Create repository implementations
   - Test sync flows

2. ✅ **Device identification service**
   - Keychain storage
   - UUID generation
   - Device registration

3. ✅ **Wire up real data**
   - Replace mock data in ViewModels
   - Test offline scenarios
   - Implement sync logic

4. ✅ **Add unit tests**
   - ViewModel tests (priority)
   - Use case tests
   - Repository tests

5. ✅ **History feature**
   - Calendar view
   - Log details
   - Edit/delete functionality

### Backlog
- Avatar customization UI
- Challenges system
- Share achievements
- Widget support
- App Store submission

---

## 📞 Questions & Help

### Finding Information

**For architecture questions:**
→ Read `/docs/02-architecture.md`

**For design guidelines:**
→ Read `/docs/04-design-system.md`

**For backend/database:**
→ Read `/docs/03-database-schema.md` and `/docs/05-supabase-integration.md`

**For project setup:**
→ Read `/docs/00-getting-started.md`

### Common Questions

**Q: Where do I add a new feature?**
A: Create a folder in `Features/YourFeature/` with `Views/` and `ViewModels/` subfolders.

**Q: How do I access the database?**
A: Through repositories. Never call Supabase directly from ViewModels.

**Q: Where do reusable components go?**
A: `Core/DesignSystem/Components/` for UI, `Core/Utilities/` for logic.

**Q: Can I use CocoaPods/Carthage?**
A: No, use Swift Package Manager (SPM) only.

**Q: How do I test on a device?**
A: Configure team signing in Xcode, connect device via USB, press Cmd+R.

**Q: Where are API keys stored?**
A: In `Config.plist` (gitignored). Never commit this file.

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-15 | Initial CLAUDE.md creation |

---

## 📄 License & Credits

**Project:** PoopyPals iOS
**Architecture:** MVVM + Clean Architecture
**Design System:** Custom SwiftUI components
**Backend:** Supabase (PostgreSQL)

**Key Technologies:**
- SwiftUI (iOS 17.0+)
- Swift Package Manager
- Combine + async/await
- Keychain Services

---

*This document is maintained for AI assistants working on PoopyPals. Keep it updated as the project evolves.*
