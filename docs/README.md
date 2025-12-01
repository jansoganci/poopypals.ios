# 🚽 PoopyPals iOS - Documentation

Welcome to the **PoopyPals iOS** documentation! This guide will help you understand, build, and contribute to the iOS version of PoopyPals - a fun, gamified bathroom habit tracking app.

## 📖 Documentation Index

### Getting Started
Start here if you're new to the project:
- **[00 - Getting Started](./00-getting-started.md)** - Setup guide, installation, and first steps

### Architecture & Design
Core architectural decisions and patterns:
- **[01 - Project Overview](./01-project-overview.md)** - Product vision, features, and roadmap
- **[02 - Architecture](./02-architecture.md)** - MVVM + Clean Architecture, folder structure, patterns
- **[04 - Design System](./04-design-system.md)** - Colors, typography, spacing, components

### Backend & Data
Database and backend integration:
- **[03 - Database Schema](./03-database-schema.md)** - Supabase/PostgreSQL schema, tables, relationships
- **[05 - Supabase Integration](./05-supabase-integration.md)** - Backend setup, API calls, sync strategy

### Authentication & Security
Device-based auth without user accounts:
- **[06 - Device Identification](./06-device-identification.md)** - Anonymous device ID, migration, Keychain

### Error Handling
Robust error handling patterns:
- **[07 - Error Handling](./07-error-handling.md)** - Error types, presentation, validation, logging

### Setup & Configuration
Quick setup guides and configuration:
- **[Backend Quick Start](./setup/BACKEND_QUICKSTART.md)** - 5-minute backend setup
- **[Backend Test Guide](./setup/BACKEND_TEST_REHBERI.md)** - Testing backend connection
- **[Config.plist Setup](./setup/CONFIG_PLIST_EKLEME.md)** - Adding Config.plist to Xcode

### Development
Development guides and workflows:
- **[Xcode Log Guide](./development/XCODE_LOG_REHBERI.md)** - Understanding backend logs in Xcode

### Troubleshooting
Common issues and quick fixes:
- **[Quick Fixes](./troubleshooting/HIZLI_FIX.md)** - Common build and runtime issues

### Architecture Reports
Detailed architecture analysis:
- **[Architecture Report](./MIMARI_RAPOR.md)** - Supabase isolation and layer structure

## 🎯 Quick Reference

### Key Technologies
- **Platform:** iOS 17.0+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Architecture:** MVVM + Clean Architecture
- **Backend:** Supabase (PostgreSQL)
- **Dependencies:** Swift Package Manager
- **Auth:** Device-based (no user accounts)

### Core Features
- ✅ Poop logging with metrics (duration, rating, consistency)
- ✅ Streak tracking and gamification
- ✅ Flush Funds currency system
- ✅ Avatar customization
- ✅ Achievements and challenges
- ✅ Offline-first with cloud sync

### Project Structure

```
PoopyPals/
├── App/                    # Entry point, coordinator
├── Core/                   # Design system, utilities
│   ├── DesignSystem/      # Colors, typography, components
│   ├── Extensions/        # Swift extensions
│   └── Configuration/     # App config
├── Domain/                 # Business logic
│   ├── Entities/          # Business models
│   ├── UseCases/          # Business operations
│   └── RepositoryProtocols/
├── Data/                   # Data access
│   ├── Repositories/      # Repository implementations
│   ├── Services/          # Supabase, sync, device ID
│   └── DataSources/       # Remote/local data sources
├── Features/               # Feature modules
│   ├── Home/
│   ├── PoopLog/
│   ├── History/
│   ├── Avatar/
│   └── Profile/
└── Resources/              # Assets, strings
```

## 🚀 Common Tasks

### Creating a New Feature

```bash
# 1. Create feature folder structure
Features/
  YourFeature/
    Views/
    ViewModels/
    Coordinators/

# 2. Follow MVVM pattern
# 3. Use dependency injection
# 4. Write tests
# 5. Update documentation
```

### Adding a UI Component

```swift
// 1. Create component in Core/DesignSystem/Components/
struct PPYourComponent: View {
    var body: some View {
        // Use design tokens
        Text("Hello")
            .font(.ppBody)
            .foregroundColor(.ppTextPrimary)
            .padding(PPSpacing.md)
    }
}

// 2. Document usage
// 3. Add preview
// 4. Write tests
```

### Integrating Supabase API

```swift
// 1. Define DTO model
struct YourDTO: Codable {
    let id: UUID
    let name: String
    // Use snake_case for Supabase
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

// 2. Create data source
protocol YourDataSource {
    func fetch() async throws -> [YourEntity]
}

// 3. Implement with Supabase
class SupabaseYourDataSource: YourDataSource {
    func fetch() async throws -> [YourEntity] {
        let response = try await supabase.client
            .from("your_table")
            .select()
            .execute()
        // Map to domain entity
    }
}

// 4. Create repository
// 5. Create use case
// 6. Use in ViewModel
```

## 🎨 Design System Quick Reference

### Colors

```swift
// Brand
.ppPrimary              // Indigo (#6366F1)
.ppSecondary            // Green (#10B981)
.ppAccent               // Amber (#F59E0B)

// Backgrounds
.ppBackground           // System background
.ppBackgroundSecondary  // Cards
.ppBackgroundTertiary   // Inputs

// Text
.ppTextPrimary          // Primary text
.ppTextSecondary        // Secondary text
.ppTextTertiary         // Disabled text
```

### Typography

```swift
// Display
.ppDisplayLarge         // 34pt, bold
.ppDisplayMedium        // 28pt, bold

// Titles
.ppTitle1               // 28pt, semibold
.ppTitle2               // 22pt, semibold

// Body
.ppBody                 // 15pt, regular
.ppBodySmall            // 13pt, regular

// Labels
.ppLabel                // 13pt, medium
.ppCaption              // 12pt, regular
```

### Spacing

```swift
PPSpacing.xs            // 8pt
PPSpacing.sm            // 12pt
PPSpacing.md            // 16pt (default)
PPSpacing.lg            // 24pt
PPSpacing.xl            // 32pt
```

### Components

```swift
// Button
PPButton(title: "Save") { /* action */ }

// Card
PPCard {
    Text("Content")
}

// Input
PPTextField(placeholder: "Notes", text: $notes)

// Rating Picker
PPRatingPicker(selectedRating: $rating)

// Slider
PPConsistencySlider(consistency: $consistency)
```

## 🗄️ Database Quick Reference

### Key Tables

- **devices** - Device registry (device ID, stats)
- **poop_logs** - Bathroom logs (duration, rating, consistency)
- **achievements** - Unlocked achievements
- **avatar_components** - Available avatar parts
- **avatar_configs** - Current avatar setup
- **challenges** - Available challenges

See [Database Schema](./03-database-schema.md) for complete reference.

## 🔄 MVVM Data Flow

```
User Interaction (View)
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
Data flows back up the chain
        ↓
ViewModel updates @Published properties
        ↓
View automatically re-renders
```

## 🧪 Testing

### Unit Tests

```swift
import XCTest
@testable import PoopyPals

class YourViewModelTests: XCTestCase {
    var viewModel: YourViewModel!
    var mockUseCase: MockYourUseCase!

    override func setUp() {
        mockUseCase = MockYourUseCase()
        viewModel = YourViewModel(useCase: mockUseCase)
    }

    func testFetchData() async {
        await viewModel.fetchData()
        XCTAssertFalse(viewModel.data.isEmpty)
    }
}
```

### UI Tests

```swift
import XCTest

class YourUITests: XCTestCase {
    let app = XCUIApplication()

    func testLoginFlow() {
        app.launch()
        app.buttons["LogPoopButton"].tap()
        // Assert UI state
    }
}
```

## 🐛 Debugging Tips

### Common Issues

1. **Supabase connection fails**
   - Check `Config.plist` has correct URL and key
   - Verify device has internet connection
   - Check Supabase project is active

2. **RLS policy errors**
   - Ensure all SQL migrations ran
   - Check device context is being set
   - Verify device ID is valid UUID

3. **Build errors**
   - Clean build folder (Cmd + Shift + K)
   - Reset package cache
   - Update to latest packages

4. **Keychain errors**
   - Reset simulator if testing
   - Check keychain entitlements

### Logging

```swift
// Use print statements for debugging
print("🔍 Debug: \(value)")
print("✅ Success: \(message)")
print("❌ Error: \(error)")
print("⚠️ Warning: \(warning)")
```

## 📱 App Store Preparation

When ready to ship:

1. **Update version** in Xcode project settings
2. **Test on real devices** (multiple iOS versions)
3. **Run all tests** (Unit + UI)
4. **Check accessibility** (VoiceOver, Dynamic Type)
5. **Prepare screenshots** (all required sizes)
6. **Write App Store description**
7. **Set up App Store Connect** (metadata, pricing)
8. **Submit for review**

## 🤝 Contributing

### Before You Start

1. Read all core documentation
2. Set up local environment
3. Run tests to verify setup
4. Check existing issues/PRs

### Pull Request Process

1. Create feature branch from `main`
2. Follow coding standards
3. Write tests for new features
4. Update documentation
5. Submit PR with clear description
6. Respond to code review feedback

### Coding Standards

- Follow Swift API Design Guidelines
- Use SwiftLint for style consistency
- Write self-documenting code
- Add comments for complex logic
- Keep files under 300 lines
- One type per file

## 📚 Additional Resources

### Apple Documentation
- [Swift Programming Language](https://docs.swift.org/swift-book/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Supabase
- [Supabase Swift Docs](https://supabase.com/docs/reference/swift)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### Learning Resources
- [MVVM Pattern](https://www.swiftbysundell.com/basics/mvvm/)
- [Clean Architecture in iOS](https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3)
- [Protocol-Oriented Programming](https://www.wwdcnotes.com/notes/wwdc15/408/)

## 💬 Support

Need help?
- **Questions:** Open a GitHub discussion
- **Bugs:** Create an issue with reproduction steps
- **Features:** Submit a feature request
- **Security:** Email security@poopypals.com

## 📝 License

PoopyPals iOS is released under the MIT License.

---

## 📊 Documentation Status

| Document | Status | Last Updated |
|----------|--------|--------------|
| Getting Started | ✅ Complete | 2025-11-11 |
| Project Overview | ✅ Complete | 2025-11-11 |
| Architecture | ✅ Complete | 2025-11-11 |
| Database Schema | ✅ Complete | 2025-11-11 |
| Design System | ✅ Complete | 2025-11-11 |
| Supabase Integration | ✅ Complete | 2025-11-11 |
| Device Identification | ✅ Complete | 2025-11-11 |
| Error Handling | ✅ Complete | 2025-11-11 |

---

**Version:** 1.0.0
**Last Updated:** 2025-11-11
**Maintained by:** PoopyPals iOS Team

---

Happy coding! 💩✨
