## PoopyPals iOS

### 🚽 Overview
PoopyPals is a playful, privacy-first bathroom habit companion that helps people build healthier routines through logging, streaks, and avatar rewards. The app is built with SwiftUI and keeps every flow modular so features stay easy to evolve.

### ✨ Core Features
- Log bathroom visits with duration, rating, consistency, and notes
- Track daily streaks and weekly trends at a glance
- Earn “Flush Funds” to personalize a friendly avatar
- Browse your history with calendar and list views
- Sync safely through Supabase using an anonymous device ID

### 🧱 Architecture & Stack
- SwiftUI + MVVM + Coordinator pattern
- Async/await plus Combine for reactive flows
- Supabase (PostgreSQL) for cloud sync, UserDefaults for local storage
- Keychain-backed device identification (no personal accounts)

### 🛠 Prerequisites
- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+
- Supabase project (free tier works great)

### 🚀 Getting Started
1. **Clone**
   ```bash
   git clone https://github.com/your-org/poopypals-ios.git
   cd poopypals-ios
   ```
2. **Open** `PoopyPals.xcodeproj` in Xcode (SPM pulls dependencies automatically).
3. **Create** a `Config.plist` in the repo root:
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
   Add this file to `.gitignore`.
4. **Run** the SQL migrations in `docs/ios/supabase-migrations/` inside the Supabase SQL editor to provision tables and RLS policies.
5. **Update signing** in Xcode (`Team` + unique bundle ID), pick a simulator or device, then `Cmd + R`.

### 🗂 Project Structure
```
PoopyPals/
├── App/                # App entry + coordinators
├── Core/               # Design system, utilities, configuration
├── Domain/             # Entities, use cases, repository protocols
├── Data/               # Services, repositories, data sources
├── Features/           # Feature modules (Home, Log, History, Avatar, Profile)
├── Resources/          # Assets, localization
└── Tests/              # Unit + UI tests
```

### 🧪 Testing
- In Xcode: `Cmd + U`
- CLI example:
  ```bash
  xcodebuild test \
    -scheme PoopyPals \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
  ```

### 📚 Documentation
Comprehensive documentation is available in the [`docs/`](./docs/) folder:

**Quick Links:**
- **[📖 Full Documentation Index](./docs/README.md)** – Complete documentation guide
- **[🚀 Getting Started](./docs/00-getting-started.md)** – Onboarding & environment setup
- **[🏗️ Architecture](./docs/02-architecture.md)** – MVVM + Clean Architecture patterns
- **[🎨 Design System](./docs/04-design-system.md)** – Typography, colors, reusable components
- **[⚙️ Setup Guides](./docs/setup/)** – Backend setup, config, testing
- **[🐛 Troubleshooting](./docs/troubleshooting/)** – Common issues and fixes

### 🤝 Contributing
1. Create a feature branch: `git checkout -b feature/short-description`
2. Keep modules isolated and reuse components from `Core/DesignSystem`
3. Add tests for new business logic or view models
4. Open a pull request with screenshots or videos when UI changes

### 🛡 Privacy & Security
- No personal accounts or PII collection
- Keychain-stored device UUID powers sync
- Offline-first; sync happens opportunistically when online

### 📝 License
MIT (or update to your preferred license)

---
💩 Built with care for better bathroom habits.

