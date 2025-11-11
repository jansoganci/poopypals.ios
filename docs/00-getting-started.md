# PoopyPals iOS - Getting Started Guide

## 🚀 Quick Start

This guide will get you up and running with the PoopyPals iOS project in minutes.

## 📋 Prerequisites

### Required Tools
- **macOS** 13.0 (Ventura) or later
- **Xcode** 15.0 or later
- **Swift** 5.9+
- **Git**

### Accounts Needed
- **Apple Developer Account** (for device testing)
- **Supabase Account** (free tier is fine)

## 🛠️ Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/poopypals-ios.git
cd poopypals-ios
```

### 2. Install Dependencies

The project uses **Swift Package Manager** (SPM) which is built into Xcode.

Dependencies will be automatically resolved when you open the project:
- **Supabase Swift SDK** (~2.0.0)

### 3. Configure Supabase

#### Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note your **Project URL** and **Anon Key** from Settings > API

#### Set Up Database

Run the SQL migrations from `docs/ios/supabase-migrations/`:

```sql
-- 01_create_devices_table.sql
-- 02_create_poop_logs_table.sql
-- 03_create_avatar_tables.sql
-- 04_create_challenges_tables.sql
-- 05_setup_rls_policies.sql
```

Execute these in Supabase SQL Editor in order.

#### Configure iOS App

Create `Config.plist` in the project root:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>SupabaseURL</key>
    <string>https://your-project.supabase.co</string>
    <key>SupabaseAnonKey</key>
    <string>your-anon-key-here</string>
</dict>
</plist>
```

**⚠️ Important:** Add `Config.plist` to `.gitignore` to avoid committing secrets.

### 4. Open Project in Xcode

```bash
open PoopyPals.xcodeproj
```

Or double-click `PoopyPals.xcodeproj` in Finder.

### 5. Configure Signing

1. Select **PoopyPals** target
2. Go to **Signing & Capabilities**
3. Select your **Team** (Apple Developer Account)
4. Change **Bundle Identifier** to something unique:
   - e.g., `com.yourname.poopypals`

### 6. Build and Run

1. Select a simulator or connected device
2. Press **Cmd + R** or click ▶️ Run
3. App should launch successfully!

## 📁 Project Structure Overview

```
PoopyPals/
├── App/                      # App entry point and coordinator
├── Core/                     # Design system, utilities, config
│   ├── DesignSystem/
│   ├── Extensions/
│   ├── Utilities/
│   └── Configuration/
├── Domain/                   # Business logic and entities
│   ├── Entities/
│   ├── UseCases/
│   └── RepositoryProtocols/
├── Data/                     # Data access and services
│   ├── Repositories/
│   ├── Services/
│   └── DataSources/
├── Features/                 # Feature modules (MVVM)
│   ├── Home/
│   ├── PoopLog/
│   ├── History/
│   ├── Avatar/
│   └── Profile/
├── Resources/                # Assets, localization
└── Tests/                    # Unit and UI tests
```

See [Architecture Documentation](./02-architecture.md) for details.

## 🎨 Design System

The design system lives in `Core/DesignSystem/`:

```swift
// Colors
Color.ppPrimary          // Brand primary color
Color.ppBackground       // Background color
Color.ppTextPrimary      // Primary text

// Typography
Font.ppTitle1           // Large title
Font.ppBody             // Body text
Font.ppCaption          // Small text

// Spacing
PPSpacing.md            // 16pt (default)
PPSpacing.lg            // 24pt
PPSpacing.xs            // 8pt

// Components
PPButton(title: "Log Poop") { /* action */ }
PPCard { /* content */ }
PPTextField(placeholder: "Notes", text: $notes)
```

See [Design System Documentation](./04-design-system.md) for complete reference.

## 🗄️ Database & Supabase

### Device Registration

On first launch, the app:
1. Generates a unique device ID (stored in Keychain)
2. Registers with Supabase `devices` table
3. Syncs data in background

No user authentication required!

### Data Models

Core entities:
- **PoopLog** - Bathroom visit records
- **Achievement** - Unlocked milestones
- **Avatar** - User avatar configuration
- **Challenge** - Daily/weekly challenges

See [Database Schema](./03-database-schema.md) for complete schema.

## 🔄 Data Flow (MVVM)

```
View → ViewModel → UseCase → Repository → Data Source → Supabase
  ↑                                                          ↓
  └──────────────────── ObservableObject ←──────────────────┘
```

### Example: Fetching Logs

```swift
// 1. View
struct HistoryView: View {
    @StateObject var viewModel = HistoryViewModel()

    var body: some View {
        List(viewModel.logs) { log in
            PPLogCard(log: log)
        }
        .task {
            await viewModel.fetchLogs()
        }
    }
}

// 2. ViewModel
@MainActor
class HistoryViewModel: ObservableObject {
    @Published var logs: [PoopLog] = []

    private let fetchLogsUseCase: FetchPoopLogsUseCase

    func fetchLogs() async {
        do {
            logs = try await fetchLogsUseCase.execute(for: Date())
        } catch {
            // Handle error
        }
    }
}

// 3. UseCase
class DefaultFetchPoopLogsUseCase: FetchPoopLogsUseCase {
    private let repository: PoopLogRepositoryProtocol

    func execute(for date: Date) async throws -> [PoopLog] {
        return try await repository.fetchLogs(for: date)
    }
}

// 4. Repository
class PoopLogRepository: PoopLogRepositoryProtocol {
    private let remoteDataSource: RemotePoopLogDataSource

    func fetchLogs(for date: Date) async throws -> [PoopLog] {
        return try await remoteDataSource.fetchLogs(deviceID: deviceID)
    }
}
```

## 🧪 Running Tests

### Unit Tests

```bash
# Command line
xcodebuild test -scheme PoopyPals -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Or in Xcode: Cmd + U
```

### UI Tests

```bash
# In Xcode
Cmd + U (runs all tests including UI tests)

# Or run specific UI test scheme
```

Tests are located in:
- `Tests/UnitTests/` - Unit tests
- `Tests/UITests/` - UI tests

## 🐛 Common Issues & Solutions

### Issue: "No Supabase URL found"
**Solution:** Make sure `Config.plist` exists and has correct keys.

### Issue: Build errors with dependencies
**Solution:**
```
File > Packages > Reset Package Caches
File > Packages > Update to Latest Package Versions
```

### Issue: Keychain errors in simulator
**Solution:** Reset simulator:
```
Device > Erase All Content and Settings...
```

### Issue: RLS policy errors
**Solution:** Make sure you ran all SQL migrations in Supabase.

## 📱 Running on Physical Device

1. Connect iPhone/iPad via USB
2. Select device in Xcode
3. Ensure device is registered in Apple Developer Portal
4. Build and run (Cmd + R)

**Note:** Free Apple Developer accounts can deploy to personal devices.

## 🎯 Next Steps

Now that you're set up, explore:

1. **[Architecture Guide](./02-architecture.md)** - Understand the codebase structure
2. **[Design System](./04-design-system.md)** - Learn the UI components
3. **[Database Schema](./03-database-schema.md)** - Understand data models
4. **[Supabase Integration](./05-supabase-integration.md)** - Learn backend integration
5. **[Device Identification](./06-device-identification.md)** - Understand auth strategy
6. **[Error Handling](./07-error-handling.md)** - Handle errors gracefully

## 🤝 Development Workflow

### Feature Development

1. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Follow MVVM structure**
   - Create feature folder in `Features/`
   - Add Views, ViewModels, Coordinators

3. **Use design system components**
   - Reuse existing components from `Core/DesignSystem/`

4. **Write tests**
   - Unit tests for ViewModels and UseCases
   - UI tests for critical flows

5. **Submit PR**
   - Clear description
   - Screenshots/videos of changes
   - All tests passing

### Coding Standards

- **SwiftLint** - Follow Swift style guide
- **1 class per file** - Keep files focused
- **Protocol-oriented** - Use protocols for abstraction
- **Async/await** - Use modern concurrency
- **@MainActor** - Mark ViewModels appropriately

## 📚 Additional Resources

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Supabase Swift Docs](https://supabase.com/docs/reference/swift)
- [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/)

## 💬 Getting Help

- **Questions?** Open a GitHub issue
- **Bugs?** Create a bug report
- **Ideas?** Start a discussion

---

**Happy Coding!** 💩✨

---

**Last Updated:** 2025-11-11
**Version:** 1.0.0
