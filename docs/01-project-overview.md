# PoopyPals iOS - Project Overview

## 🚽 What is PoopyPals?

PoopyPals is a fun, gamified bathroom habit tracking app that helps users monitor their digestive health while making the experience engaging and rewarding.

## 🎯 Core Value Proposition

- **Track bathroom habits** with detailed metrics (duration, rating, consistency)
- **Build healthy streaks** to encourage regular bathroom routines
- **Earn rewards** ("Flush Funds") to customize your avatar
- **Complete challenges** and unlock achievements
- **Monitor health patterns** over time with visual analytics

## 👥 Target Audience

- Health-conscious individuals (18-45)
- People tracking digestive health
- Users who enjoy gamification and progress tracking
- Anyone interested in personal wellness data

## 🏗️ Architecture Philosophy

PoopyPals iOS follows Apple's best practices and modern iOS development patterns:

- **MVVM Architecture** with clean separation of concerns
- **Protocol-Oriented Design** for testability and flexibility
- **SwiftUI-First** for modern, declarative UI
- **Async/Await** for modern concurrency
- **Combine Framework** for reactive data flow
- **Repository Pattern** for data abstraction
- **Coordinator Pattern** for navigation

## 📱 Technical Stack

### Platform
- **iOS 17.0+** minimum deployment target
- **Swift 5.9+**
- **SwiftUI** for UI layer
- **Combine** for reactive programming

### Backend & Database
- **Supabase** (PostgreSQL) for cloud sync
- **UserDefaults** for local preferences
- **Keychain** for secure device ID storage

### Dependencies
- **Supabase Swift SDK** - Backend integration
- **Swift Package Manager** - Dependency management

## 🎨 Design Principles

1. **Playful but Professional** - Fun without being childish
2. **Privacy-First** - No authentication required, device-based sync
3. **Offline-First** - Full functionality without internet
4. **Accessible** - VoiceOver support, Dynamic Type, High Contrast
5. **Performance** - Smooth 60fps animations, instant interactions

## 📊 MVP Feature Set

### Core Features (Phase 1)
- ✅ Poop logging with metrics (duration, rating, consistency, notes)
- ✅ Daily streak tracking
- ✅ Flush Funds currency system
- ✅ History view with calendar
- ✅ Basic avatar customization
- ✅ Device-based sync (no auth)

### Enhanced Features (Phase 2)
- 🔄 Challenges and achievements
- 🔄 Advanced analytics and insights
- 🔄 Reminders and notifications
- 🔄 Avatar shop with unlockables

### Future Features (Phase 3)
- 🔮 Health app integration
- 🔮 Widgets
- 🔮 Siri shortcuts
- 🔮 iPad optimization
- 🔮 Apple Watch companion

## 🗂️ Core Modules

### 1. Home Module
- Quick log entry
- Current streak display
- Today's stats
- Quick actions

### 2. Log Module
- Detailed poop log creation
- Timer for duration tracking
- Rating selector (emoji-based)
- Consistency slider
- Notes field

### 3. History Module
- Calendar view
- List of past logs
- Filter and search
- Analytics charts

### 4. Avatar Module
- Avatar preview
- Component customization (head, eyes, mouth, accessories)
- Shop for new components
- Unlock tracking

### 5. Profile Module
- Total stats display
- Achievement showcase
- Flush Funds balance
- Settings and preferences

## 🔐 Privacy & Security

- **No personal authentication** - Users open and start using immediately
- **Device-based identification** - Unique device ID for sync (stored in Keychain)
- **Local-first data** - All data works offline, syncs in background
- **No PII collection** - No names, emails, or personal identifiers
- **Secure sync** - Device ID only used for cloud sync association

## 🎯 Success Metrics

- **Daily Active Users** - Users logging at least once per day
- **Streak Retention** - % of users maintaining 7+ day streaks
- **Feature Engagement** - Usage of avatar customization
- **Flush Funds Economy** - Balance of earning vs. spending

## 📅 Development Roadmap

### Week 1-2: Foundation
- Project setup and architecture
- Design system implementation
- Core data models
- Supabase integration

### Week 3-4: Core Features
- Home screen
- Log creation flow
- History view
- Basic sync

### Week 5-6: Gamification
- Avatar system
- Achievements
- Challenges
- Flush Funds

### Week 7-8: Polish
- Animations
- Error handling
- Testing
- App Store preparation

## 🤝 Development Philosophy

- **Test-Driven** - Write tests for business logic
- **Incremental** - Ship small, working features
- **User-Focused** - Prioritize UX over technical perfection
- **Maintainable** - Write code others can understand
- **Documented** - Keep docs up-to-date with code

## 📚 Related Documentation

- [Architecture & Folder Structure](./02-architecture.md)
- [Database Schema](./03-database-schema.md)
- [Design System](./04-design-system.md)
- [Supabase Integration](./05-supabase-integration.md)
- [Device Identification](./06-device-identification.md)
- [Error Handling](./07-error-handling.md)

---

**Last Updated:** 2025-11-11
**Version:** 1.0.0
**Author:** PoopyPals iOS Team
