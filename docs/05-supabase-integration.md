# PoopyPals iOS - Supabase Integration Guide

## 🚀 Overview

PoopyPals uses **Supabase** for cloud-based data storage and sync. This guide covers setup, authentication strategy (device-based), and integration patterns.

## 📦 Installation

### Swift Package Manager

Add Supabase Swift SDK to your Xcode project:

```
File > Add Package Dependencies
https://github.com/supabase/supabase-swift
```

Or add to `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
]
```

## ⚙️ Configuration

### 1. Supabase Project Setup

Create a Supabase project at [supabase.com](https://supabase.com):
1. Create new project
2. Note your **Project URL** and **Anon Key**
3. Set up database schema (see `03-database-schema.md`)

### 2. iOS Configuration

Create `SupabaseConfig.swift`:

```swift
import Foundation
import Supabase

struct SupabaseConfig {
    static let shared = SupabaseConfig()

    let projectURL: URL
    let anonKey: String

    private init() {
        // Load from environment or plist
        guard let url = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? Config.supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }

        guard let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? Config.supabaseAnonKey else {
            fatalError("Missing Supabase Anon Key")
        }

        self.projectURL = url
        self.anonKey = key
    }
}

// Store in Config.plist or environment variables
private struct Config {
    static let supabaseURL = "https://your-project.supabase.co"
    static let anonKey = "your-anon-key"
}
```

### 3. Create Supabase Service

```swift
import Supabase
import Foundation

@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    let client: SupabaseClient
    private let deviceIDService: DeviceIDService

    private init() {
        let config = SupabaseConfig.shared

        self.client = SupabaseClient(
            supabaseURL: config.projectURL,
            supabaseKey: config.anonKey,
            options: SupabaseClientOptions(
                db: SupabaseClientOptions.DatabaseOptions(
                    schema: "public"
                ),
                auth: SupabaseClientOptions.AuthOptions(
                    autoRefreshToken: false,  // No auth system
                    persistSession: false     // No session persistence
                )
            )
        )

        self.deviceIDService = DeviceIDService.shared
    }

    // MARK: - Device Context Setup
    /// Set device context for RLS (Row Level Security)
    func setDeviceContext() async throws {
        let deviceID = deviceIDService.getDeviceID()

        // Call Supabase RPC to set device_id context
        try await client.rpc(
            "set_device_context",
            params: ["device_id": deviceID]
        ).execute()
    }

    // MARK: - Health Check
    func isConnected() async -> Bool {
        do {
            _ = try await client.from("devices").select("id").limit(1).execute()
            return true
        } catch {
            print("Supabase connection failed: \(error)")
            return false
        }
    }
}
```

## 🔐 Device-Based Authentication (No User Accounts)

### Device Registration

When the app launches for the first time, register the device:

```swift
extension SupabaseService {
    func registerDevice() async throws -> Device {
        let deviceID = deviceIDService.getDeviceID()

        // Check if device already exists
        let existing = try await client
            .from("devices")
            .select()
            .eq("device_id", value: deviceID)
            .limit(1)
            .execute()

        if let deviceData = existing.data.first {
            // Device exists, update last_seen_at
            return try await updateDeviceLastSeen(deviceID: deviceID)
        } else {
            // New device, create entry
            return try await createDevice(deviceID: deviceID)
        }
    }

    private func createDevice(deviceID: String) async throws -> Device {
        let deviceInfo = UIDevice.current

        let newDevice = DeviceDTO(
            deviceId: deviceID,
            platform: "ios",
            appVersion: Bundle.main.appVersion,
            osVersion: deviceInfo.systemVersion,
            deviceModel: deviceInfo.modelName
        )

        let response = try await client
            .from("devices")
            .insert(newDevice)
            .select()
            .single()
            .execute()

        return try JSONDecoder().decode(Device.self, from: response.data)
    }

    private func updateDeviceLastSeen(deviceID: String) async throws -> Device {
        let response = try await client
            .from("devices")
            .update(["last_seen_at": Date()])
            .eq("device_id", value: deviceID)
            .select()
            .single()
            .execute()

        return try JSONDecoder().decode(Device.self, from: response.data)
    }
}
```

## 📊 Data Operations

### DTO Models (Data Transfer Objects)

Create lightweight models for Supabase communication:

```swift
// SupabaseModels.swift

struct DeviceDTO: Codable {
    let deviceId: String
    let platform: String
    let appVersion: String?
    let osVersion: String?
    let deviceModel: String?

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case platform
        case appVersion = "app_version"
        case osVersion = "os_version"
        case deviceModel = "device_model"
    }
}

struct PoopLogDTO: Codable {
    let id: UUID?
    let deviceId: UUID
    let loggedAt: Date
    let durationSeconds: Int
    let rating: String
    let consistency: Int
    let notes: String?
    let flushFundsEarned: Int
    let localId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case deviceId = "device_id"
        case loggedAt = "logged_at"
        case durationSeconds = "duration_seconds"
        case rating
        case consistency
        case notes
        case flushFundsEarned = "flush_funds_earned"
        case localId = "local_id"
    }
}

// Extension to convert Domain Entity to DTO
extension PoopLog {
    func toDTO(deviceID: UUID) -> PoopLogDTO {
        PoopLogDTO(
            id: self.id,
            deviceId: deviceID,
            loggedAt: self.loggedAt,
            durationSeconds: self.durationSeconds,
            rating: self.rating.rawValue,
            consistency: self.consistency,
            notes: self.notes,
            flushFundsEarned: self.flushFundsEarned,
            localId: self.localId
        )
    }
}

// Extension to convert DTO to Domain Entity
extension PoopLogDTO {
    func toDomain() -> PoopLog {
        PoopLog(
            id: self.id ?? UUID(),
            loggedAt: self.loggedAt,
            durationSeconds: self.durationSeconds,
            rating: PoopLog.Rating(rawValue: self.rating) ?? .okay,
            consistency: self.consistency,
            notes: self.notes,
            flushFundsEarned: self.flushFundsEarned,
            localId: self.localId
        )
    }
}
```

### Data Source Implementation

```swift
// RemotePoopLogDataSource.swift

protocol RemotePoopLogDataSource {
    func fetchLogs(deviceID: UUID, limit: Int, offset: Int) async throws -> [PoopLog]
    func fetchLog(id: UUID) async throws -> PoopLog
    func createLog(_ log: PoopLog, deviceID: UUID) async throws -> PoopLog
    func updateLog(_ log: PoopLog) async throws -> PoopLog
    func deleteLog(id: UUID) async throws
}

class SupabasePoopLogDataSource: RemotePoopLogDataSource {
    private let supabase: SupabaseService

    init(supabase: SupabaseService) {
        self.supabase = supabase
    }

    func fetchLogs(deviceID: UUID, limit: Int = 30, offset: Int = 0) async throws -> [PoopLog] {
        let response = try await supabase.client
            .from("poop_logs")
            .select()
            .eq("device_id", value: deviceID.uuidString)
            .eq("is_deleted", value: false)
            .order("logged_at", ascending: false)
            .limit(limit)
            .range(from: offset, to: offset + limit - 1)
            .execute()

        let dtos = try JSONDecoder().decode([PoopLogDTO].self, from: response.data)
        return dtos.map { $0.toDomain() }
    }

    func createLog(_ log: PoopLog, deviceID: UUID) async throws -> PoopLog {
        let dto = log.toDTO(deviceID: deviceID)

        let response = try await supabase.client
            .from("poop_logs")
            .insert(dto)
            .select()
            .single()
            .execute()

        let createdDTO = try JSONDecoder().decode(PoopLogDTO.self, from: response.data)
        return createdDTO.toDomain()
    }

    func updateLog(_ log: PoopLog) async throws -> PoopLog {
        guard let id = log.id else {
            throw SupabaseError.invalidID
        }

        let dto = log.toDTO(deviceID: UUID())  // deviceID not needed for update

        let response = try await supabase.client
            .from("poop_logs")
            .update([
                "duration_seconds": dto.durationSeconds,
                "rating": dto.rating,
                "consistency": dto.consistency,
                "notes": dto.notes as Any
            ])
            .eq("id", value: id.uuidString)
            .select()
            .single()
            .execute()

        let updatedDTO = try JSONDecoder().decode(PoopLogDTO.self, from: response.data)
        return updatedDTO.toDomain()
    }

    func deleteLog(id: UUID) async throws {
        // Soft delete
        _ = try await supabase.client
            .from("poop_logs")
            .update(["is_deleted": true])
            .eq("id", value: id.uuidString)
            .execute()
    }

    func fetchLog(id: UUID) async throws -> PoopLog {
        let response = try await supabase.client
            .from("poop_logs")
            .select()
            .eq("id", value: id.uuidString)
            .eq("is_deleted", value: false)
            .single()
            .execute()

        let dto = try JSONDecoder().decode(PoopLogDTO.self, from: response.data)
        return dto.toDomain()
    }
}
```

## 🔄 Sync Strategy

### Background Sync Service

```swift
import Foundation

@MainActor
class SyncService: ObservableObject {
    static let shared = SyncService()

    @Published var isSyncing = false
    @Published var lastSyncDate: Date?

    private let supabase: SupabaseService
    private let deviceIDService: DeviceIDService

    private init() {
        self.supabase = SupabaseService.shared
        self.deviceIDService = DeviceIDService.shared
    }

    // MARK: - Manual Sync
    func syncNow() async throws {
        guard !isSyncing else { return }

        isSyncing = true
        defer { isSyncing = false }

        // 1. Upload local changes
        try await uploadLocalChanges()

        // 2. Download remote changes
        try await downloadRemoteChanges()

        // 3. Update last sync timestamp
        lastSyncDate = Date()
        UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")
    }

    // MARK: - Upload Local Changes
    private func uploadLocalChanges() async throws {
        // Get local logs that haven't been synced
        // This would integrate with your local cache/database
        // For now, placeholder logic:

        // let unsyncedLogs = await localCache.getUnsyncedLogs()
        // for log in unsyncedLogs {
        //     try await remoteDataSource.createLog(log, deviceID: deviceID)
        // }
    }

    // MARK: - Download Remote Changes
    private func downloadRemoteChanges() async throws {
        let lastSync = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date ?? .distantPast

        // Fetch logs modified since last sync
        // This requires a custom RPC or filter on Supabase
        // For now, fetch recent logs:

        let deviceID = UUID(uuidString: deviceIDService.getDeviceID()) ?? UUID()
        let remoteDataSource = SupabasePoopLogDataSource(supabase: supabase)
        let logs = try await remoteDataSource.fetchLogs(deviceID: deviceID, limit: 100, offset: 0)

        // Merge with local cache (conflict resolution)
        // await localCache.merge(logs)
    }

    // MARK: - Automatic Sync
    func startAutoSync() {
        // Sync every 5 minutes when app is active
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                try? await self?.syncNow()
            }
        }
    }
}
```

### Conflict Resolution Strategy

**Last Write Wins** based on `updated_at` timestamp:

```swift
func resolveConflict(local: PoopLog, remote: PoopLog) -> PoopLog {
    // Compare updated_at timestamps
    if local.updatedAt > remote.updatedAt {
        return local  // Keep local version
    } else {
        return remote  // Use remote version
    }
}
```

## 📱 Realtime Subscriptions (Optional Future Feature)

For live updates across devices:

```swift
extension SupabaseService {
    func subscribeToLogChanges(deviceID: UUID, onChange: @escaping (PoopLog) -> Void) async throws {
        let channel = await client.channel("poop_logs_changes")

        await channel
            .on("postgres_changes", filter: "device_id=eq.\(deviceID.uuidString)") { payload in
                if let log = try? JSONDecoder().decode(PoopLogDTO.self, from: payload.new) {
                    onChange(log.toDomain())
                }
            }
            .subscribe()
    }
}
```

## 🧪 Testing with Supabase

### Mock Supabase Service

```swift
class MockSupabaseService: SupabaseService {
    var mockLogs: [PoopLog] = []

    override func fetchLogs(deviceID: UUID, limit: Int, offset: Int) async throws -> [PoopLog] {
        return Array(mockLogs.prefix(limit))
    }

    override func createLog(_ log: PoopLog, deviceID: UUID) async throws -> PoopLog {
        mockLogs.append(log)
        return log
    }
}
```

### Test Environment

Use separate Supabase project for testing:

```swift
#if DEBUG
let supabaseURL = "https://test-project.supabase.co"
#else
let supabaseURL = "https://prod-project.supabase.co"
#endif
```

## ⚠️ Error Handling

```swift
enum SupabaseError: LocalizedError {
    case invalidID
    case networkError(Error)
    case decodingError(Error)
    case unauthorized
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidID:
            return "Invalid record ID"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to decode response"
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Record not found"
        }
    }
}
```

## 📊 Performance Optimization

### Batch Operations

```swift
func batchCreateLogs(_ logs: [PoopLog], deviceID: UUID) async throws -> [PoopLog] {
    let dtos = logs.map { $0.toDTO(deviceID: deviceID) }

    let response = try await supabase.client
        .from("poop_logs")
        .insert(dtos)
        .select()
        .execute()

    let createdDTOs = try JSONDecoder().decode([PoopLogDTO].self, from: response.data)
    return createdDTOs.map { $0.toDomain() }
}
```

### Caching

Implement local caching to reduce API calls:
- Cache recent logs (last 30 days)
- Invalidate cache on sync
- Use UserDefaults for small data, CoreData/SQLite for large datasets

## 🔒 Security Best Practices

1. **Never commit API keys** - Use environment variables or Config.plist (gitignored)
2. **Use RLS policies** - Ensure devices can only access their own data
3. **Validate data** - Server-side validation via Supabase functions
4. **Rate limiting** - Implement client-side throttling for API calls

## 📚 Related Documentation

- [Database Schema](./03-database-schema.md)
- [Device Identification](./06-device-identification.md)
- [Error Handling](./07-error-handling.md)

---

**Last Updated:** 2025-11-11
**Version:** 1.0.0
