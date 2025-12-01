# 🏗️ Backend Mimari Tasarımı - PoopyPals

## 📊 Mevcut Durum Analizi

### Entity'ler
1. **PoopLog** - Tuvalet ziyareti kayıtları
   - CRUD işlemleri gerekli
   - Sync mekanizması gerekli
   - Offline-first yaklaşım

2. **Achievement** - Başarımlar
   - Fetch (unlocked achievements)
   - Create (yeni achievement unlock)
   - isViewed update

3. **Device Stats** - Cihaz istatistikleri
   - streakCount
   - totalFlushFunds
   - totalLogs

### Mevcut ViewModel İhtiyaçları
- `HomeViewModel`:
  - `loadData()` → Logs fetch
  - `quickLog()` → Log create
  - `calculateStreak()` → Streak hesaplama
  - `checkForAchievements()` → Achievement kontrolü

## ✅ Kararlar

1. **Local Storage:** UserDefaults (basit, hızlı)
2. **Sync Strategy:** Offline-first
3. **Conflict Resolution:** Last-write-wins (updated_at'e göre)
4. **Error Handling:** 3 retry, exponential backoff
5. **UseCase Pattern:** Kullanılacak

## 🎯 Backend Mimari Tasarımı

### 1. UseCase Pattern (Domain Layer)

```
Domain/UseCases/
├── PoopLog/
│   ├── FetchPoopLogsUseCase.swift
│   ├── FetchTodayLogsUseCase.swift
│   ├── CreatePoopLogUseCase.swift
│   ├── UpdatePoopLogUseCase.swift
│   └── DeletePoopLogUseCase.swift
├── Achievement/
│   ├── FetchUnlockedAchievementsUseCase.swift
│   ├── UnlockAchievementUseCase.swift
│   └── MarkAchievementViewedUseCase.swift
├── Streak/
│   ├── CalculateStreakUseCase.swift
│   └── UpdateStreakUseCase.swift
└── DeviceStats/
    ├── FetchDeviceStatsUseCase.swift
    └── UpdateFlushFundsUseCase.swift
```

**UseCase Pattern Avantajları:**
- Her business operation tek bir use case
- Test edilebilir
- ViewModel'den business logic ayrılır
- Reusable

### 2. Repository Pattern (Domain Layer)

```
Domain/Repositories/
├── PoopLogRepositoryProtocol.swift
├── AchievementRepositoryProtocol.swift
└── DeviceStatsRepositoryProtocol.swift
```

**PoopLogRepositoryProtocol:**
```swift
protocol PoopLogRepositoryProtocol {
    func fetchLogs(limit: Int, offset: Int) async throws -> [PoopLog]
    func fetchTodayLogs() async throws -> [PoopLog]
    func fetchLog(id: UUID) async throws -> PoopLog
    func createLog(_ log: PoopLog) async throws -> PoopLog
    func updateLog(_ log: PoopLog) async throws -> PoopLog
    func deleteLog(id: UUID) async throws
}
```

**AchievementRepositoryProtocol:**
```swift
protocol AchievementRepositoryProtocol {
    func fetchUnlockedAchievements() async throws -> [Achievement]
    func unlockAchievement(_ achievement: Achievement) async throws
    func markAsViewed(achievementId: UUID) async throws
}
```

**DeviceStatsRepositoryProtocol:**
```swift
protocol DeviceStatsRepositoryProtocol {
    func fetchStats() async throws -> DeviceStats
    func updateStreak(_ count: Int) async throws
    func addFlushFunds(_ amount: Int) async throws
}
```

### 2. Data Sources (Data Layer)

```
Data/DataSources/
├── Remote/
│   ├── SupabasePoopLogDataSource.swift
│   ├── SupabaseAchievementDataSource.swift
│   └── SupabaseDeviceStatsDataSource.swift
└── Local/
    ├── LocalPoopLogDataSource.swift (UserDefaults/CoreData)
    └── LocalCacheDataSource.swift
```

**SupabasePoopLogDataSource:**
- Supabase client kullanır
- DTO conversion yapar
- Error handling

**LocalPoopLogDataSource:**
- Offline-first için
- **UserDefaults** kullanılacak (karar verildi)
- Sync queue yönetimi
- JSON encoding/decoding

### 3. Repository Implementations

```
Data/Repositories/
├── PoopLogRepository.swift
├── AchievementRepository.swift
└── DeviceStatsRepository.swift
```

**PoopLogRepository:**
- Remote + Local data source'ları kullanır
- Conflict resolution yapar
- Sync queue yönetir

### 4. DTOs (Data Transfer Objects)

```
Data/DTOs/
├── PoopLogDTO.swift
├── AchievementDTO.swift
└── DeviceStatsDTO.swift
```

**PoopLogDTO:**
- snake_case (PostgreSQL convention)
- Domain entity'ye convert eder

### 5. Sync Service

```
Data/Services/Sync/
└── SyncService.swift
```

**SyncService:**
- **Offline-first** yaklaşım (karar verildi)
- Background sync (5 dakikada bir)
- **Conflict resolution: Last-write-wins** (updated_at'e göre) (karar verildi)
- **Retry logic: 3 retry, exponential backoff** (karar verildi)
- Queue management
- UserDefaults'tan sync queue okur/yazar

## 🔄 Data Flow (UseCase Pattern ile)

```
ViewModel
    ↓
UseCase (Domain Layer)
    ↓
Repository (Protocol - Domain Layer)
    ↓
Repository Implementation (Data Layer)
    ↓
    ├─→ RemoteDataSource (Supabase) → SupabaseService
    └─→ LocalDataSource (UserDefaults) → SyncQueue
```

**Örnek Flow:**
```
HomeViewModel.quickLog()
    ↓
CreatePoopLogUseCase.execute()
    ↓
PoopLogRepository.createLog()
    ↓
    ├─→ LocalPoopLogDataSource.save() → UserDefaults (immediate)
    └─→ SyncService.enqueue() → Background sync
```

**Offline-First Stratejisi:**
1. Write → Önce Local (UserDefaults) → UI güncellenir
2. Background → SyncService → Remote (Supabase)
3. Read → Önce Local → Sonra Remote (background refresh)

## 📡 API Endpoints (Supabase)

### Tables
- `devices` - Device registration
- `poop_logs` - Log storage
- `achievements` - Achievement unlocks

### RPC Functions
- `calculate_streak(device_id)` - Streak hesaplama
- `update_device_stats(device_id)` - Stats güncelleme
- `check_and_award_achievement(...)` - Achievement kontrolü

## 🎨 Implementasyon Sırası

1. **DTOs** (En basit, bağımlılık yok)
   - PoopLogDTO
   - AchievementDTO
   - DeviceStatsDTO

2. **Local Data Sources** (UserDefaults)
   - LocalPoopLogDataSource
   - LocalAchievementDataSource
   - LocalCacheManager (UserDefaults wrapper)

3. **Remote Data Sources** (Supabase)
   - SupabasePoopLogDataSource
   - SupabaseAchievementDataSource
   - SupabaseDeviceStatsDataSource

4. **Repository Protocols** (Domain layer)
   - PoopLogRepositoryProtocol
   - AchievementRepositoryProtocol
   - DeviceStatsRepositoryProtocol

5. **Repository Implementations** (Data layer)
   - PoopLogRepository (Local + Remote)
   - AchievementRepository
   - DeviceStatsRepository

6. **UseCases** (Domain layer)
   - PoopLog use cases
   - Achievement use cases
   - Streak use cases
   - DeviceStats use cases

7. **Sync Service** (En karmaşık)
   - SyncService
   - SyncQueue (UserDefaults)
   - Conflict resolution logic
   - Retry mechanism (3 retry, exponential backoff)

## 📋 Detaylı Planlama

### Phase 1: Foundation (DTOs + Local Storage)
- DTOs oluştur
- UserDefaults wrapper (LocalCacheManager)
- Local data sources implement et

### Phase 2: Remote Integration
- Supabase data sources
- Error handling
- DTO ↔ Entity conversion

### Phase 3: Repository Layer
- Repository protocols
- Repository implementations
- Local + Remote orchestration

### Phase 4: UseCase Layer
- UseCase protocols
- UseCase implementations
- Business logic encapsulation

### Phase 5: Sync & Polish
- SyncService
- Conflict resolution
- Retry logic
- Background sync

## 🔧 Teknik Detaylar

### UserDefaults Storage Structure
```swift
// Keys
"poop_logs" → [PoopLogDTO] (JSON)
"achievements" → [AchievementDTO] (JSON)
"device_stats" → DeviceStatsDTO (JSON)
"sync_queue" → [SyncItem] (JSON)
"last_sync_date" → Date
```

### Retry Logic
```swift
func retry<T>(_ operation: () async throws -> T, maxRetries: Int = 3) async throws -> T {
    var lastError: Error?
    for attempt in 0..<maxRetries {
        do {
            return try await operation()
        } catch {
            lastError = error
            if attempt < maxRetries - 1 {
                let delay = pow(2.0, Double(attempt)) // Exponential backoff
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
    throw lastError!
}
```

### Conflict Resolution
```swift
func resolveConflict(local: PoopLog, remote: PoopLog) -> PoopLog {
    return local.updatedAt > remote.updatedAt ? local : remote
}
```

---

**Planlama tamamlandı. Implementasyona geçilebilir.**

