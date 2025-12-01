# PoopyPals iOS - Leaderboard Implementation Plan

> **Last Updated:** 2025-11-25  
> **Status:** Planning Phase - Not Yet Implemented  
> **Priority:** High - Core Gamification Feature

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Requirements & Decisions](#requirements--decisions)
3. [Database Schema & Functions](#database-schema--functions)
4. [Domain Layer Design](#domain-layer-design)
5. [Data Layer Design](#data-layer-design)
6. [Presentation Layer Design](#presentation-layer-design)
7. [UI Components](#ui-components)
8. [Navigation Integration](#navigation-integration)
9. [Privacy & Security](#privacy--security)
10. [Performance Considerations](#performance-considerations)
11. [Implementation Checklist](#implementation-checklist)
12. [Testing Strategy](#testing-strategy)

---

## 🎯 Overview

### Purpose
Implement a competitive leaderboard system that shows user rankings based on different metrics (streak, total logs, flush funds) across multiple time periods (weekly, monthly, yearly). This feature enhances gamification and user engagement by fostering healthy competition.

### Key Features
- **Multiple Time Periods:** Weekly, Monthly, Yearly leaderboards
- **Multiple Metrics:** Streak count, Total logs, Flush funds earned
- **Top 3 Podium:** Special visual treatment for top performers
- **Current User Highlighting:** Always show user's position
- **Real-time Updates:** Pull-to-refresh and background sync
- **Privacy-First:** Anonymous display names, no PII

### Architecture Alignment
- ✅ Follows existing MVVM + Clean Architecture pattern
- ✅ Uses existing UseCase/Repository pattern
- ✅ Integrates with current Supabase backend
- ✅ Uses existing design system (PPGradients, GlossyCard, etc.)
- ✅ Respects device-based identification system

---

## 📝 Requirements & Decisions

### User Requirements (Confirmed)
1. **Visibility:** Everyone can see the leaderboards (public by default)
2. **Active Users Definition:** All users (not just "active ones" - we'll filter by activity window)
3. **Metrics:** Both streak and total logs are important (plus flush funds)
4. **Time Periods:** Weekly, Monthly, Yearly (not daily)
5. **Social Features:** Maybe yes, not sure - plan for future friend connections

### Active Users Definition
**Decision:** Users are considered "active" if:
- `is_active = true` in `devices` table
- `last_seen_at >= NOW() - INTERVAL '30 days'` (active in last 30 days)
- `total_logs > 0` (has at least 1 log)

This ensures leaderboards show engaged users while filtering out abandoned accounts.

### Privacy Model
- **Anonymous Display Names:** Generate names like "FlushMaster#A1B2" from device UUID
- **No PII:** Only show device IDs and stats, never names/emails
- **Public by Default:** All users visible unless they opt out (future feature)
- **Opt-Out Option:** Add `is_leaderboard_visible` boolean to `devices` table (future)

---

## 🗄️ Database Schema & Functions

### Existing Schema (Already in Place)
The `devices` table already contains all necessary data:
```sql
devices (
    id UUID PRIMARY KEY,
    device_id VARCHAR(255) UNIQUE NOT NULL,
    streak_count INTEGER DEFAULT 0,
    total_logs INTEGER DEFAULT 0,
    flush_funds INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    last_seen_at TIMESTAMPTZ,
    ...
)
```

### New SQL Functions (To Be Created)

#### 1. Weekly Leaderboard Function
```sql
CREATE OR REPLACE FUNCTION get_weekly_leaderboard(
    p_metric VARCHAR,  -- 'streak', 'total_logs', or 'flush_funds'
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    rank INTEGER,
    device_id UUID,
    streak_count INTEGER,
    total_logs INTEGER,
    flush_funds INTEGER,
    last_seen_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER (ORDER BY 
            CASE p_metric
                WHEN 'streak' THEN d.streak_count
                WHEN 'total_logs' THEN d.total_logs
                WHEN 'flush_funds' THEN d.flush_funds
                ELSE d.streak_count
            END DESC
        )::INTEGER as rank,
        d.id as device_id,
        d.streak_count,
        d.total_logs,
        d.flush_funds,
        d.last_seen_at
    FROM devices d
    WHERE 
        d.is_active = true
        AND d.last_seen_at >= NOW() - INTERVAL '30 days'
        AND (
            CASE p_metric
                WHEN 'streak' THEN d.streak_count > 0
                WHEN 'total_logs' THEN EXISTS (
                    SELECT 1 FROM poop_logs pl
                    WHERE pl.device_id = d.id
                    AND pl.logged_at >= NOW() - INTERVAL '7 days'
                    AND pl.is_deleted = false
                )
                WHEN 'flush_funds' THEN EXISTS (
                    SELECT 1 FROM poop_logs pl
                    WHERE pl.device_id = d.id
                    AND pl.logged_at >= NOW() - INTERVAL '7 days'
                    AND pl.is_deleted = false
                )
                ELSE true
            END
        )
    ORDER BY 
        CASE p_metric
            WHEN 'streak' THEN d.streak_count
            WHEN 'total_logs' THEN d.total_logs
            WHEN 'flush_funds' THEN d.flush_funds
            ELSE d.streak_count
        END DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
```

#### 2. Monthly Leaderboard Function
Similar to weekly, but change:
- `INTERVAL '7 days'` → `INTERVAL '30 days'`
- Function name: `get_monthly_leaderboard`

#### 3. Yearly Leaderboard Function
Similar to weekly, but change:
- `INTERVAL '7 days'` → `INTERVAL '365 days'`
- Function name: `get_yearly_leaderboard`

#### 4. User Rank Function
```sql
CREATE OR REPLACE FUNCTION get_user_rank(
    p_device_id UUID,
    p_period VARCHAR,  -- 'weekly', 'monthly', 'yearly'
    p_metric VARCHAR   -- 'streak', 'total_logs', 'flush_funds'
)
RETURNS TABLE (
    rank INTEGER,
    device_id UUID,
    streak_count INTEGER,
    total_logs INTEGER,
    flush_funds INTEGER,
    last_seen_at TIMESTAMPTZ
) AS $$
DECLARE
    v_interval INTERVAL;
BEGIN
    -- Determine time interval based on period
    CASE p_period
        WHEN 'weekly' THEN v_interval := INTERVAL '7 days';
        WHEN 'monthly' THEN v_interval := INTERVAL '30 days';
        WHEN 'yearly' THEN v_interval := INTERVAL '365 days';
        ELSE v_interval := INTERVAL '7 days';
    END CASE;
    
    RETURN QUERY
    WITH ranked_devices AS (
        SELECT
            d.id,
            d.streak_count,
            d.total_logs,
            d.flush_funds,
            d.last_seen_at,
            ROW_NUMBER() OVER (ORDER BY 
                CASE p_metric
                    WHEN 'streak' THEN d.streak_count
                    WHEN 'total_logs' THEN d.total_logs
                    WHEN 'flush_funds' THEN d.flush_funds
                    ELSE d.streak_count
                END DESC
            )::INTEGER as rank
        FROM devices d
        WHERE 
            d.is_active = true
            AND d.last_seen_at >= NOW() - INTERVAL '30 days'
            AND (
                CASE p_metric
                    WHEN 'streak' THEN d.streak_count > 0
                    WHEN 'total_logs' THEN EXISTS (
                        SELECT 1 FROM poop_logs pl
                        WHERE pl.device_id = d.id
                        AND pl.logged_at >= NOW() - v_interval
                        AND pl.is_deleted = false
                    )
                    WHEN 'flush_funds' THEN EXISTS (
                        SELECT 1 FROM poop_logs pl
                        WHERE pl.device_id = d.id
                        AND pl.logged_at >= NOW() - v_interval
                        AND pl.is_deleted = false
                    )
                    ELSE true
                END
            )
    )
    SELECT
        rd.rank,
        rd.id as device_id,
        rd.streak_count,
        rd.total_logs,
        rd.flush_funds,
        rd.last_seen_at
    FROM ranked_devices rd
    WHERE rd.id = p_device_id;
END;
$$ LANGUAGE plpgsql;
```

### Database Indexes (Performance)
Ensure these indexes exist:
```sql
-- Already exists in migrations
CREATE INDEX idx_devices_active ON devices(is_active) WHERE is_active = true;
CREATE INDEX idx_devices_last_seen ON devices(last_seen_at);
CREATE INDEX idx_poop_logs_device_date ON poop_logs(device_id, logged_at DESC) WHERE is_deleted = false;
```

---

## 🏗️ Domain Layer Design

### Entities

#### LeaderboardEntry
**File:** `poopypals/Domain/Entities/LeaderboardEntry.swift`

```swift
struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID  // device_id
    let rank: Int
    let streakCount: Int
    let totalLogs: Int
    let flushFunds: Int
    let lastSeenAt: Date
    
    // Computed properties
    var displayName: String {
        // Generate anonymous name from device UUID
        // Example: "FlushMaster#A1B2"
        let hash = id.uuidString.prefix(4).uppercased()
        return "FlushMaster#\(hash)"
    }
    
    var isCurrentUser: Bool = false  // Set by ViewModel
}
```

#### LeaderboardPeriod
**File:** `poopypals/Domain/Entities/LeaderboardPeriod.swift`

```swift
enum LeaderboardPeriod: String, CaseIterable, Codable {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .weekly: return "This Week"
        case .monthly: return "This Month"
        case .yearly: return "This Year"
        }
    }
    
    var interval: String {
        switch self {
        case .weekly: return "7 days"
        case .monthly: return "30 days"
        case .yearly: return "365 days"
        }
    }
}
```

#### LeaderboardMetric
**File:** `poopypals/Domain/Entities/LeaderboardMetric.swift`

```swift
enum LeaderboardMetric: String, CaseIterable, Codable {
    case streak = "streak"
    case totalLogs = "total_logs"
    case flushFunds = "flush_funds"
    
    var displayName: String {
        switch self {
        case .streak: return "Streak"
        case .totalLogs: return "Total Logs"
        case .flushFunds: return "Flush Funds"
        }
    }
    
    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .totalLogs: return "list.bullet.circle.fill"
        case .flushFunds: return "dollarsign.circle.fill"
        }
    }
}
```

### Repository Protocol

**File:** `poopypals/Domain/Repositories/LeaderboardRepositoryProtocol.swift`

```swift
protocol LeaderboardRepositoryProtocol {
    func fetchLeaderboard(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int
    ) async throws -> [LeaderboardEntry]
    
    func fetchCurrentUserRank(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry?
}
```

### Use Cases

#### FetchLeaderboardUseCase
**File:** `poopypals/Domain/UseCases/Leaderboard/FetchLeaderboardUseCase.swift`

```swift
protocol FetchLeaderboardUseCaseProtocol {
    func execute(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int
    ) async throws -> [LeaderboardEntry]
}

class FetchLeaderboardUseCase: FetchLeaderboardUseCaseProtocol {
    private let repository: LeaderboardRepositoryProtocol
    
    init(repository: LeaderboardRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int = 100
    ) async throws -> [LeaderboardEntry] {
        return try await repository.fetchLeaderboard(
            period: period,
            metric: metric,
            limit: limit
        )
    }
}
```

#### FetchUserRankUseCase
**File:** `poopypals/Domain/UseCases/Leaderboard/FetchUserRankUseCase.swift`

```swift
protocol FetchUserRankUseCaseProtocol {
    func execute(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry?
}

class FetchUserRankUseCase: FetchUserRankUseCaseProtocol {
    private let repository: LeaderboardRepositoryProtocol
    
    init(repository: LeaderboardRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry? {
        return try await repository.fetchCurrentUserRank(
            period: period,
            metric: metric
        )
    }
}
```

---

## 💾 Data Layer Design

### Data Source Protocol

**File:** `poopypals/Data/DataSources/Remote/RemoteLeaderboardDataSourceProtocol.swift`

```swift
protocol RemoteLeaderboardDataSourceProtocol {
    func fetchLeaderboard(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int,
        currentDeviceId: UUID
    ) async throws -> [LeaderboardEntry]
    
    func fetchUserRank(
        deviceId: UUID,
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry?
}
```

### Supabase Data Source Implementation

**File:** `poopypals/Data/DataSources/Remote/SupabaseLeaderboardDataSource.swift`

```swift
class SupabaseLeaderboardDataSource: RemoteLeaderboardDataSourceProtocol {
    private let client: SupabaseClient
    private let deviceService: DeviceIdentificationService
    
    init(
        client: SupabaseClient,
        deviceService: DeviceIdentificationService = DeviceIdentificationService()
    ) {
        self.client = client
        self.deviceService = deviceService
    }
    
    func fetchLeaderboard(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int,
        currentDeviceId: UUID
    ) async throws -> [LeaderboardEntry] {
        // Call appropriate Supabase RPC function
        let functionName = "get_\(period.rawValue)_leaderboard"
        
        let response = try await client.rpc(
            functionName,
            params: [
                "p_metric": metric.rawValue,
                "p_limit": limit
            ]
        ).execute()
        
        // Parse response into LeaderboardEntry array
        // Mark current user entries with isCurrentUser flag
        // Implementation details...
    }
    
    func fetchUserRank(
        deviceId: UUID,
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry? {
        let response = try await client.rpc(
            "get_user_rank",
            params: [
                "p_device_id": deviceId.uuidString,
                "p_period": period.rawValue,
                "p_metric": metric.rawValue
            ]
        ).execute()
        
        // Parse and return LeaderboardEntry
        // Implementation details...
    }
}
```

### Repository Implementation

**File:** `poopypals/Data/Repositories/LeaderboardRepository.swift`

```swift
class LeaderboardRepository: LeaderboardRepositoryProtocol {
    private let remoteDataSource: RemoteLeaderboardDataSourceProtocol
    private let deviceService: DeviceIdentificationService
    
    init(
        remoteDataSource: RemoteLeaderboardDataSourceProtocol,
        deviceService: DeviceIdentificationService = DeviceIdentificationService()
    ) {
        self.remoteDataSource = remoteDataSource
        self.deviceService = deviceService
    }
    
    func fetchLeaderboard(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int
    ) async throws -> [LeaderboardEntry] {
        let deviceId = try await deviceService.getDeviceId()
        return try await remoteDataSource.fetchLeaderboard(
            period: period,
            metric: metric,
            limit: limit,
            currentDeviceId: deviceId
        )
    }
    
    func fetchCurrentUserRank(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry? {
        let deviceId = try await deviceService.getDeviceId()
        return try await remoteDataSource.fetchUserRank(
            deviceId: deviceId,
            period: period,
            metric: metric
        )
    }
}
```

### Dependency Injection

**File:** `poopypals/Core/DependencyInjection/AppContainer.swift`

Add to `AppContainer`:
```swift
// Leaderboard dependencies
lazy var leaderboardRepository: LeaderboardRepositoryProtocol = {
    LeaderboardRepository(
        remoteDataSource: SupabaseLeaderboardDataSource(client: supabaseService.client),
        deviceService: deviceService
    )
}()

lazy var fetchLeaderboardUseCase: FetchLeaderboardUseCaseProtocol = {
    FetchLeaderboardUseCase(repository: leaderboardRepository)
}()

lazy var fetchUserRankUseCase: FetchUserRankUseCaseProtocol = {
    FetchUserRankUseCase(repository: leaderboardRepository)
}()
```

---

## 🎨 Presentation Layer Design

### ViewModel

**File:** `poopypals/Features/Leaderboard/ViewModels/LeaderboardViewModel.swift`

```swift
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
        fetchLeaderboardUseCase: FetchLeaderboardUseCaseProtocol,
        fetchUserRankUseCase: FetchUserRankUseCaseProtocol,
        deviceService: DeviceIdentificationService = DeviceIdentificationService()
    ) {
        self.fetchLeaderboardUseCase = fetchLeaderboardUseCase
        self.fetchUserRankUseCase = fetchUserRankUseCase
        self.deviceService = deviceService
    }
    
    // MARK: - Public Methods
    func loadLeaderboard() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch leaderboard entries
            entries = try await fetchLeaderboardUseCase.execute(
                period: selectedPeriod,
                metric: selectedMetric,
                limit: 100
            )
            
            // Mark current user
            let currentDeviceId = try await deviceService.getDeviceId()
            entries = entries.map { entry in
                var updated = entry
                updated.isCurrentUser = (entry.id == currentDeviceId)
                return updated
            }
            
            // Fetch user's rank if not in top 100
            if !entries.contains(where: { $0.isCurrentUser }) {
                currentUserRank = try await fetchUserRankUseCase.execute(
                    period: selectedPeriod,
                    metric: selectedMetric
                )
            } else {
                currentUserRank = nil
            }
        } catch {
            errorAlert = ErrorAlert(
                title: "Error Loading Leaderboard",
                message: error.localizedDescription
            )
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
```

### Main View

**File:** `poopypals/Features/Leaderboard/Views/LeaderboardView.swift`

```swift
struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: PPSpacing.xl) {
                // Period selector
                periodSelector
                
                // Metric selector
                metricSelector
                
                // Top 3 podium
                if viewModel.topThree.count >= 3 {
                    PodiumView(
                        entries: viewModel.topThree,
                        metric: viewModel.selectedMetric
                    )
                }
                
                // Leaderboard list (rank 4+)
                if !viewModel.remainingEntries.isEmpty {
                    leaderboardList
                }
                
                // Current user rank (if not in top 100)
                if let userRank = viewModel.currentUserRank {
                    CurrentUserRankCard(entry: userRank, metric: viewModel.selectedMetric)
                }
            }
            .padding(PPSpacing.lg)
        }
        .background(LinearGradient.ppGradient(PPGradients.lavenderPeach))
        .navigationTitle("Leaderboard")
        .task {
            await viewModel.loadLeaderboard()
        }
        .refreshable {
            await viewModel.loadLeaderboard()
        }
        .alert(item: $viewModel.errorAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Subviews
    private var periodSelector: some View {
        // Segmented control for Weekly/Monthly/Yearly
    }
    
    private var metricSelector: some View {
        // Segmented control for Streak/Total Logs/Flush Funds
    }
    
    private var leaderboardList: some View {
        VStack(spacing: PPSpacing.sm) {
            ForEach(viewModel.remainingEntries) { entry in
                LeaderboardRow(
                    entry: entry,
                    metric: viewModel.selectedMetric
                )
            }
        }
    }
}
```

---

## 🧩 UI Components

### Podium View (Top 3)

**File:** `poopypals/Features/Leaderboard/Views/PodiumView.swift`

```swift
struct PodiumView: View {
    let entries: [LeaderboardEntry]  // Top 3
    let metric: LeaderboardMetric
    
    var body: some View {
        HStack(alignment: .bottom, spacing: PPSpacing.md) {
            // 2nd place (left, medium height)
            if entries.count >= 2 {
                PodiumCard(
                    entry: entries[1],
                    rank: 2,
                    metric: metric,
                    gradient: PPGradients.mintLavender  // Silver theme
                )
            }
            
            // 1st place (center, tallest)
            PodiumCard(
                entry: entries[0],
                rank: 1,
                metric: metric,
                gradient: PPGradients.peachYellow  // Gold theme
            )
            
            // 3rd place (right, shortest)
            if entries.count >= 3 {
                PodiumCard(
                    entry: entries[2],
                    rank: 3,
                    metric: metric,
                    gradient: PPGradients.coralOrange  // Bronze theme
                )
            }
        }
        .padding(.vertical, PPSpacing.xl)
    }
}
```

### Podium Card Component

**File:** `poopypals/Features/Leaderboard/Views/PodiumCard.swift`

```swift
struct PodiumCard: View {
    let entry: LeaderboardEntry
    let rank: Int
    let metric: LeaderboardMetric
    let gradient: [Color]
    
    private var height: CGFloat {
        switch rank {
        case 1: return 200  // Tallest
        case 2: return 160   // Medium
        case 3: return 120  // Shortest
        default: return 100
        }
    }
    
    var body: some View {
        VStack(spacing: PPSpacing.sm) {
            // Rank badge
            Text("#\(rank)")
                .font(.ppNumberLarge)
                .foregroundColor(.ppTextPrimary)
            
            // Avatar placeholder
            Circle()
                .fill(LinearGradient.ppGradient(gradient))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(rankEmoji)
                        .font(.ppEmojiMedium)
                )
            
            // Display name
            Text(entry.displayName)
                .font(.ppBody)
                .foregroundColor(.ppTextPrimary)
                .lineLimit(1)
            
            // Metric value
            AnimatedNumber(
                value: metricValue,
                font: .ppNumberMedium,
                color: .ppAccent
            )
            
            // Metric label
            Text(metric.displayName)
                .font(.ppCaption)
                .foregroundColor(.ppTextSecondary)
        }
        .frame(width: 100, height: height)
        .padding(PPSpacing.md)
        .background(
            GlossyCard(gradient: gradient) {
                EmptyView()
            }
        )
    }
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏆"
        }
    }
    
    private var metricValue: Int {
        switch metric {
        case .streak: return entry.streakCount
        case .totalLogs: return entry.totalLogs
        case .flushFunds: return entry.flushFunds
        }
    }
}
```

### Leaderboard Row Component

**File:** `poopypals/Features/Leaderboard/Views/LeaderboardRow.swift`

```swift
struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let metric: LeaderboardMetric
    
    var body: some View {
        HStack(spacing: PPSpacing.md) {
            // Rank badge
            Text("#\(entry.rank)")
                .font(.ppNumberMedium)
                .foregroundColor(.ppTextPrimary)
                .frame(width: 50, alignment: .leading)
            
            // Avatar placeholder
            Circle()
                .fill(
                    LinearGradient.ppGradient(
                        entry.isCurrentUser ? PPGradients.mintLavender : PPGradients.peachPink
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text("💩")
                        .font(.ppEmojiSmall)
                )
            
            // User info
            VStack(alignment: .leading, spacing: PPSpacing.xxs) {
                HStack {
                    Text(entry.displayName)
                        .font(.ppBody)
                        .foregroundColor(.ppTextPrimary)
                    
                    if entry.isCurrentUser {
                        Text("(You)")
                            .font(.ppCaption)
                            .foregroundColor(.ppAccent)
                    }
                }
                
                Text("\(metricValue) \(metric.displayName)")
                    .font(.ppCaption)
                    .foregroundColor(.ppTextSecondary)
            }
            
            Spacer()
            
            // Metric value
            AnimatedNumber(
                value: metricValue,
                font: .ppNumberMedium,
                color: entry.isCurrentUser ? .ppAccent : .ppTextPrimary
            )
        }
        .padding(PPSpacing.md)
        .background(
            entry.isCurrentUser
                ? GlossyCard(gradient: PPGradients.mintLavender, shadowIntensity: 0.5) {
                    EmptyView()
                }
                : Color.ppSurfaceAlt
        )
        .cornerRadius(PPCornerRadius.md)
        .ppShadow(entry.isCurrentUser ? .md : .sm)
    }
    
    private var metricValue: Int {
        switch metric {
        case .streak: return entry.streakCount
        case .totalLogs: return entry.totalLogs
        case .flushFunds: return entry.flushFunds
        }
    }
}
```

### Current User Rank Card

**File:** `poopypals/Features/Leaderboard/Views/CurrentUserRankCard.swift`

```swift
struct CurrentUserRankCard: View {
    let entry: LeaderboardEntry
    let metric: LeaderboardMetric
    
    var body: some View {
        GlossyCard(gradient: PPGradients.mintLavender) {
            VStack(spacing: PPSpacing.md) {
                Text("Your Rank")
                    .font(.ppTitle3)
                    .foregroundColor(.ppTextPrimary)
                
                Text("#\(entry.rank)")
                    .font(.ppNumberLarge)
                    .foregroundColor(.ppAccent)
                
                HStack(spacing: PPSpacing.sm) {
                    Image(systemName: metric.icon)
                        .foregroundColor(.ppAccent)
                    
                    Text("\(metricValue) \(metric.displayName)")
                        .font(.ppBody)
                        .foregroundColor(.ppTextSecondary)
                }
            }
            .padding(PPSpacing.lg)
        }
        .padding(.horizontal, PPSpacing.lg)
    }
    
    private var metricValue: Int {
        switch metric {
        case .streak: return entry.streakCount
        case .totalLogs: return entry.totalLogs
        case .flushFunds: return entry.flushFunds
        }
    }
}
```

---

## 🧭 Navigation Integration

### Main Tab View

**File:** `poopypals/Features/Navigation/MainTabView.swift`

```swift
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NewHomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // History Tab (TODO: Create this)
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(1)
            
            // Leaderboard Tab
            NavigationView {
                LeaderboardView()
            }
            .tabItem {
                Label("Leaderboard", systemImage: "trophy.fill")
            }
            .tag(2)
            
            // Profile Tab (TODO: Create this)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.ppMain)
    }
}
```

### Update App Entry Point

**File:** `poopypals/poopypalsApp.swift`

Change from:
```swift
WindowGroup {
    NewHomeView()
}
```

To:
```swift
WindowGroup {
    MainTabView()
}
```

---

## 🔒 Privacy & Security

### Privacy Model
1. **Anonymous Display Names:** Generated from device UUID (e.g., "FlushMaster#A1B2")
2. **No PII:** Only device IDs and stats visible, never names/emails
3. **Public by Default:** All active users visible unless they opt out
4. **Future Opt-Out:** Add `is_leaderboard_visible` boolean to `devices` table

### Security Considerations
1. **RLS Policies:** Leaderboard functions should be publicly readable (no auth required)
2. **Rate Limiting:** Implement rate limiting on leaderboard queries (prevent abuse)
3. **Data Validation:** Validate all inputs to SQL functions
4. **Error Handling:** Don't expose sensitive error messages

### Future Privacy Features
- User can hide from leaderboard (`is_leaderboard_visible = false`)
- User can change display name (still anonymous, but customizable)
- Friend-only leaderboards (if social features added)

---

## ⚡ Performance Considerations

### Caching Strategy
1. **Local Cache:** Store leaderboard data in UserDefaults (refresh every 5 minutes)
2. **Background Refresh:** Update leaderboard when app foregrounds
3. **Optimistic Updates:** Show cached data immediately, refresh in background

### Query Optimization
1. **Indexes:** Ensure indexes exist on `devices.is_active`, `devices.last_seen_at`, `poop_logs.logged_at`
2. **Limit Results:** Only fetch top 100 by default
3. **Lazy Loading:** Load more entries on scroll if needed (future)

### Network Optimization
1. **Batch Requests:** Combine period/metric changes into single request
2. **Compression:** Enable gzip compression on Supabase responses
3. **Retry Logic:** Implement exponential backoff for failed requests

### UI Performance
1. **Lazy Loading:** Use `LazyVStack` for leaderboard list
2. **Image Caching:** Cache avatar images if we add them later
3. **Animation Performance:** Use efficient animations (avoid heavy computations)

---

## ✅ Implementation Checklist

### Phase 1: Database Setup
- [ ] Create `get_weekly_leaderboard` SQL function in Supabase
- [ ] Create `get_monthly_leaderboard` SQL function in Supabase
- [ ] Create `get_yearly_leaderboard` SQL function in Supabase
- [ ] Create `get_user_rank` SQL function in Supabase
- [ ] Test all functions in Supabase SQL editor
- [ ] Verify indexes exist for performance
- [ ] Document SQL functions in migration file

### Phase 2: Domain Layer
- [ ] Create `LeaderboardEntry` entity
- [ ] Create `LeaderboardPeriod` enum
- [ ] Create `LeaderboardMetric` enum
- [ ] Create `LeaderboardRepositoryProtocol`
- [ ] Create `FetchLeaderboardUseCase`
- [ ] Create `FetchUserRankUseCase`
- [ ] Add unit tests for entities and enums

### Phase 3: Data Layer
- [ ] Create `RemoteLeaderboardDataSourceProtocol`
- [ ] Create `SupabaseLeaderboardDataSource` implementation
- [ ] Create `LeaderboardRepository` implementation
- [ ] Add to `AppContainer` dependency injection
- [ ] Test data source with mock Supabase responses
- [ ] Add error handling for network failures

### Phase 4: Presentation Layer
- [ ] Create `LeaderboardViewModel`
- [ ] Create `LeaderboardView` (main screen)
- [ ] Create `PodiumView` component
- [ ] Create `PodiumCard` component
- [ ] Create `LeaderboardRow` component
- [ ] Create `CurrentUserRankCard` component
- [ ] Create period selector UI
- [ ] Create metric selector UI
- [ ] Add pull-to-refresh functionality
- [ ] Add loading states
- [ ] Add empty states
- [ ] Add error handling UI

### Phase 5: Navigation
- [ ] Create `MainTabView` with tab bar
- [ ] Update `poopypalsApp.swift` to use `MainTabView`
- [ ] Test navigation flow between tabs
- [ ] Ensure proper state management across tabs

### Phase 6: Polish & Testing
- [ ] Add animations (rank changes, loading)
- [ ] Add haptic feedback for interactions
- [ ] Test offline behavior (show cached data)
- [ ] Test with different data scenarios (empty, few users, many users)
- [ ] Test period switching performance
- [ ] Test metric switching performance
- [ ] Verify privacy (no PII exposed)
- [ ] Performance testing (scroll performance, load times)
- [ ] Accessibility testing (VoiceOver, Dynamic Type)

### Phase 7: Documentation
- [ ] Update `CLAUDE.md` with leaderboard feature
- [ ] Update `README.md` with leaderboard screenshots
- [ ] Document API endpoints in Supabase docs
- [ ] Create user guide for leaderboard feature

---

## 🧪 Testing Strategy

### Unit Tests
1. **Domain Layer:**
   - Test `LeaderboardEntry` computed properties
   - Test `LeaderboardPeriod` enum values
   - Test `LeaderboardMetric` enum values
   - Test `FetchLeaderboardUseCase` logic
   - Test `FetchUserRankUseCase` logic

2. **Data Layer:**
   - Test `SupabaseLeaderboardDataSource` parsing
   - Test `LeaderboardRepository` error handling
   - Test device ID matching logic

3. **Presentation Layer:**
   - Test `LeaderboardViewModel` state management
   - Test period/metric switching
   - Test current user highlighting

### Integration Tests
1. Test full flow: ViewModel → UseCase → Repository → DataSource
2. Test Supabase RPC function calls
3. Test error propagation through layers

### UI Tests
1. Test leaderboard view rendering
2. Test podium display for top 3
3. Test period/metric selector interactions
4. Test pull-to-refresh
5. Test empty states
6. Test error states

### Manual Testing Scenarios
1. **Empty Leaderboard:** No users in system
2. **Few Users:** Less than 10 users
3. **Many Users:** 100+ users
4. **Current User in Top 3:** User is #1, #2, or #3
5. **Current User in Top 100:** User is rank 4-100
6. **Current User Outside Top 100:** User is rank 101+
7. **Period Switching:** Switch between weekly/monthly/yearly
8. **Metric Switching:** Switch between streak/logs/funds
9. **Offline Mode:** Test with no network connection
10. **Slow Network:** Test with slow/throttled connection

---

## 📚 Related Documentation

- [Architecture Overview](./02-architecture.md)
- [Database Schema](./03-database-schema.md)
- [Design System](./04-design-system.md)
- [Supabase Integration](./05-supabase-integration.md)
- [Device Identification](./06-device-identification.md)

---

## 🎯 Success Metrics

### Engagement Metrics
- **Leaderboard Views:** Track how many users view leaderboard
- **Period Switching:** Track which periods are most popular
- **Metric Switching:** Track which metrics are most popular
- **Return Rate:** Do users come back to check leaderboard?

### Performance Metrics
- **Load Time:** Leaderboard should load in < 2 seconds
- **Query Performance:** SQL functions should execute in < 500ms
- **Cache Hit Rate:** Target 80%+ cache hits for leaderboard data

### User Satisfaction
- **Feature Usage:** % of active users who view leaderboard
- **Retention Impact:** Does leaderboard increase daily active users?
- **Competition Engagement:** Do users log more when they see leaderboard?

---

**Last Updated:** 2025-11-25  
**Status:** Planning Complete - Ready for Implementation  
**Next Steps:** Begin Phase 1 (Database Setup)

