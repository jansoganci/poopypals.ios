# PoopyPals iOS - Claude Development Rules

## Project Overview

PoopyPals is a gamified bathroom habit tracking iOS app that helps users monitor digestive health in a fun, engaging way. The app features streak tracking, avatar customization, achievements, and a virtual currency system called "Flush Funds."

**Key Features:**
- Zero-friction onboarding (no authentication required)
- Device-based identification via Keychain
- Offline-first with Supabase sync
- Gamification (streaks, achievements, currency)
- Avatar customization shop
- Bristol Stool Scale consistency tracking

## Tech Stack

- **Platform:** iOS 17.0+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Architecture:** MVVM + Clean Architecture
- **Backend:** Supabase (PostgreSQL)
- **Dependencies:** Swift Package Manager
- **Concurrency:** async/await, @MainActor
- **Storage:** Keychain (device ID), Supabase (cloud data)

## Architecture Principles

### Clean Architecture Layers

1. **Presentation Layer** (`Features/`)
   - Views (SwiftUI) - Pure UI, no business logic
   - ViewModels (ObservableObject) - Presentation logic, state management
   - Coordinators - Navigation flow management

2. **Domain Layer** (`Domain/`)
   - Entities - Business models (PoopLog, Achievement, Avatar)
   - UseCases - Business operations (CreatePoopLogUseCase, UpdateStreakUseCase)
   - Repository Protocols - Data access abstractions

3. **Data Layer** (`Data/`)
   - Repositories - Implement repository protocols
   - Services - Supabase, sync, device ID management
   - Data Sources - Remote (Supabase) and Local (UserDefaults)

### MVVM Pattern Rules

- **Views**: Pure declarative UI, bind to ViewModel via @StateObject/@ObservedObject
- **ViewModels**: Always annotated with @MainActor, use @Published for state
- **Models**: Immutable structs in Domain/Entities
- **Navigation**: Handled by Coordinators, not Views

## File Structure Conventions

### Feature Module Structure
```
Features/
  YourFeature/
    Views/
      YourFeatureView.swift
      YourFeatureDetailView.swift
    ViewModels/
      YourFeatureViewModel.swift
    Coordinators/
      YourFeatureCoordinator.swift
```

### Naming Conventions

- **Protocols:** Suffix with `Protocol` (e.g., `PoopLogRepositoryProtocol`)
- **Use Cases:** Descriptive verbs (e.g., `CreatePoopLogUseCase`)
- **ViewModels:** Feature + `ViewModel` (e.g., `HomeViewModel`)
- **Views:** Feature + `View` (e.g., `HomeView`)
- **Design System:** Prefix with `PP` (e.g., `PPButton`, `PPCard`, `PPColors`)
- **One type per file** - Keep files focused and under 300 lines

## Design System Usage

### Always Use Design Tokens

**Colors:**
```swift
// ✅ GOOD
Color.ppPrimary
Color.ppBackground
Color.ppTextPrimary

// ❌ BAD
Color.blue
Color(hex: "#6366F1")
```

**Typography:**
```swift
// ✅ GOOD
.font(.ppBody)
.font(.ppTitle1)

// ❌ BAD
.font(.system(size: 16))
```

**Spacing:**
```swift
// ✅ GOOD
.padding(PPSpacing.md)
.padding(.vertical, PPSpacing.lg)

// ❌ BAD
.padding(16)
.padding(.vertical, 24)
```

**Components:**
```swift
// ✅ GOOD - Use design system components
PPButton(title: "Save") { /* action */ }
PPCard { Text("Content") }
PPTextField(placeholder: "Notes", text: $notes)

// ❌ BAD - Don't create custom buttons without reason
Button(action: {}) {
    Text("Save")
        .padding()
        .background(Color.blue)
}
```

## Coding Standards

### SwiftUI Best Practices

1. **Extract subviews for clarity:**
```swift
// ✅ GOOD
var body: some View {
    VStack {
        headerSection
        contentSection
        footerSection
    }
}

private var headerSection: some View {
    // Header implementation
}

// ❌ BAD - Everything in body
var body: some View {
    VStack {
        // 100 lines of UI code...
    }
}
```

2. **Use @StateObject for ownership, @ObservedObject for passing:**
```swift
// ✅ GOOD
struct ParentView: View {
    @StateObject private var viewModel = HomeViewModel()
}

struct ChildView: View {
    @ObservedObject var viewModel: HomeViewModel
}
```

3. **Mark ViewModels with @MainActor:**
```swift
// ✅ GOOD
@MainActor
class HomeViewModel: ObservableObject {
    @Published var logs: [PoopLog] = []
}
```

### Async/Await Patterns

1. **Always use async/await for asynchronous operations:**
```swift
// ✅ GOOD
func fetchLogs() async {
    do {
        logs = try await fetchLogsUseCase.execute(for: Date())
    } catch {
        handleError(error)
    }
}

// ❌ BAD - Don't use completion handlers
func fetchLogs(completion: @escaping ([PoopLog]) -> Void) {
    // ...
}
```

2. **Use Task for calling async from sync context:**
```swift
// ✅ GOOD
Button("Refresh") {
    Task {
        await viewModel.fetchLogs()
    }
}
```

### Dependency Injection

1. **Use protocol-based injection:**
```swift
// ✅ GOOD
class HomeViewModel: ObservableObject {
    private let fetchLogsUseCase: FetchPoopLogsUseCase

    init(fetchLogsUseCase: FetchPoopLogsUseCase) {
        self.fetchLogsUseCase = fetchLogsUseCase
    }
}

// ❌ BAD - Direct instantiation
class HomeViewModel: ObservableObject {
    private let fetchLogsUseCase = DefaultFetchPoopLogsUseCase()
}
```

2. **Use AppDependencyContainer for dependency management**

## Data Flow Rules

### Standard MVVM Flow
```
User Action (View)
    ↓
ViewModel receives action
    ↓
ViewModel calls UseCase
    ↓
UseCase executes business logic
    ↓
UseCase calls Repository
    ↓
Repository calls Data Source
    ↓
Data Source calls Supabase API
    ↓
Data flows back up
    ↓
ViewModel updates @Published properties
    ↓
View automatically re-renders
```

### Error Handling

1. **Use domain-specific error types:**
```swift
// ✅ GOOD
enum NetworkError: PPError {
    case noConnection
    case timeout
    case serverError(statusCode: Int)

    var title: String { /* ... */ }
    var message: String { /* ... */ }
    var recoveryAction: RecoveryAction? { /* ... */ }
}
```

2. **Always provide user-friendly error messages:**
```swift
// ✅ GOOD
@Published var errorAlert: ErrorAlert?

func fetchLogs() async {
    do {
        logs = try await fetchLogsUseCase.execute()
    } catch let error as PPError {
        errorAlert = ErrorAlert(error: error)
    } catch {
        errorAlert = ErrorAlert(error: SupabaseError.unknownError(error))
    }
}
```

3. **Provide recovery actions when possible**

## Supabase Integration Rules

### DTO Pattern

1. **Always use DTOs for Supabase communication:**
```swift
// Domain Entity (camelCase)
struct PoopLog {
    let id: UUID
    let loggedAt: Date
    let durationSeconds: Int
}

// DTO (snake_case for Supabase)
struct PoopLogDTO: Codable {
    let id: UUID?
    let loggedAt: Date
    let durationSeconds: Int

    enum CodingKeys: String, CodingKey {
        case id
        case loggedAt = "logged_at"
        case durationSeconds = "duration_seconds"
    }
}

// Conversion extensions
extension PoopLog {
    func toDTO(deviceID: UUID) -> PoopLogDTO { /* ... */ }
}

extension PoopLogDTO {
    func toDomain() -> PoopLog { /* ... */ }
}
```

2. **Always set device context before queries:**
```swift
// ✅ GOOD
func performSecureRequest() async throws {
    try await supabaseService.setDeviceContext()
    // Now make your query
    let logs = try await supabase.client.from("poop_logs").select()
}
```

### Data Source Pattern

1. **Create protocol for data source:**
```swift
protocol RemotePoopLogDataSource {
    func fetchLogs(deviceID: UUID) async throws -> [PoopLog]
    func createLog(_ log: PoopLog, deviceID: UUID) async throws -> PoopLog
}
```

2. **Implement with Supabase:**
```swift
class SupabasePoopLogDataSource: RemotePoopLogDataSource {
    private let supabase: SupabaseService

    func fetchLogs(deviceID: UUID) async throws -> [PoopLog] {
        let response = try await supabase.client
            .from("poop_logs")
            .select()
            .eq("device_id", value: deviceID.uuidString)
            .eq("is_deleted", value: false)
            .order("logged_at", ascending: false)
            .execute()

        let dtos = try JSONDecoder().decode([PoopLogDTO].self, from: response.data)
        return dtos.map { $0.toDomain() }
    }
}
```

## Device Identification Rules

1. **Never expose device ID in UI without user consent**
2. **Always use Keychain for device ID storage (never UserDefaults)**
3. **Generate device ID only once on first launch**
4. **Validate UUID format before importing device ID**

## Testing Guidelines

### Unit Tests

1. **Test ViewModels with mock dependencies:**
```swift
class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var mockUseCase: MockFetchLogsUseCase!

    override func setUp() {
        mockUseCase = MockFetchLogsUseCase()
        viewModel = HomeViewModel(fetchLogsUseCase: mockUseCase)
    }

    func testFetchLogs() async {
        await viewModel.fetchLogs()
        XCTAssertFalse(viewModel.logs.isEmpty)
    }
}
```

2. **Test UseCases in isolation**
3. **Test validation logic thoroughly**

### UI Tests

1. **Test critical user flows**
2. **Test accessibility (VoiceOver, Dynamic Type)**

## Common Tasks

### Creating a New Feature

1. Create folder structure in `Features/YourFeature/`
2. Create Views, ViewModels, Coordinators
3. Follow MVVM pattern
4. Use design system components
5. Implement dependency injection
6. Write unit tests
7. Update documentation if needed

### Adding a Supabase Table

1. Create SQL migration in `docs/supabase-migrations/`
2. Define DTO model in `Data/Services/Supabase/SupabaseModels.swift`
3. Create domain entity in `Domain/Entities/`
4. Add conversion extensions (toDTO, toDomain)
5. Create data source protocol
6. Implement data source with Supabase
7. Create repository
8. Create use cases
9. Set up RLS policies

### Adding a UI Component

1. Create component in `Core/DesignSystem/Components/`
2. Use design tokens (colors, spacing, typography)
3. Add accessibility labels
4. Support Dynamic Type
5. Add SwiftUI previews
6. Document usage in code comments

## Important Constraints

### DO NOT:
- ❌ Use hardcoded colors, fonts, or spacing values
- ❌ Create custom UI components without using design tokens
- ❌ Put business logic in Views
- ❌ Use UserDefaults for sensitive data (use Keychain)
- ❌ Commit `Config.plist` with real API keys
- ❌ Create user authentication (this is device-based)
- ❌ Use completion handlers (use async/await)
- ❌ Forget @MainActor on ViewModels
- ❌ Skip error handling

### ALWAYS:
- ✅ Use design system components and tokens
- ✅ Follow MVVM + Clean Architecture pattern
- ✅ Use protocol-oriented design
- ✅ Implement proper error handling with PPError
- ✅ Use async/await for asynchronous operations
- ✅ Add @MainActor to ViewModels
- ✅ Use dependency injection
- ✅ Convert between DTOs and domain entities
- ✅ Set device context before Supabase queries
- ✅ Validate user input before saving
- ✅ Handle offline mode gracefully
- ✅ Write tests for business logic

## Privacy & Security

1. **No PII (Personally Identifiable Information):**
   - No names, emails, phone numbers
   - No location tracking
   - Device ID is anonymous UUID

2. **Secure Storage:**
   - Device ID in Keychain
   - API keys in Config.plist (gitignored)

3. **Row-Level Security:**
   - All Supabase queries scoped to device_id
   - Set device context before every query

## Performance Considerations

1. **Pagination:** Fetch logs in chunks (30 items per page)
2. **Lazy Loading:** Load data only when needed
3. **Background Sync:** Sync in background task, not blocking UI
4. **Image Caching:** Cache avatar components
5. **Memory Management:** Use weak references in closures when capturing self

## Documentation

- All major features should be documented in `docs/`
- Complex algorithms should have inline comments
- Public APIs should have doc comments
- Update README when adding new features

## Git Workflow

1. Create feature branch: `feature/your-feature-name`
2. Follow naming conventions
3. Write clean commit messages
4. Ensure all tests pass
5. Update documentation if needed
6. Submit PR with clear description

---

**When working on this project, always refer to these rules and the comprehensive documentation in `docs/` for detailed guidance.**
