---
name: supabase-integration
description: Expert at Supabase backend integration for PoopyPals. Use when working with database queries, RLS policies, DTOs, device authentication, or data synchronization. Specializes in PostgreSQL schema and Swift-Supabase SDK.
---

# Supabase Integration

Expert skill for implementing Supabase backend integration following PoopyPals data architecture and security patterns.

## When to Use This Skill

- Implementing data sources that communicate with Supabase
- Creating or modifying database schema and migrations
- Setting up Row-Level Security (RLS) policies
- Building DTO (Data Transfer Object) models
- Implementing device-based authentication
- Debugging sync issues or query problems
- Optimizing database queries

## Core Principles

### 1. Device-Based Authentication
- No user accounts or passwords
- Anonymous device identification via UUID
- Device ID stored securely in Keychain
- All queries scoped to device_id via RLS

### 2. DTO Pattern (Required)
- Domain entities use camelCase (Swift conventions)
- DTOs use snake_case (PostgreSQL conventions)
- Always convert between DTO ↔ Domain
- Never expose DTOs outside Data layer

### 3. Row-Level Security (RLS)
- Every table must have RLS enabled
- Set device context before queries
- All queries automatically scoped to device_id
- No cross-device data access

## DTO Pattern Implementation

### Step 1: Define Domain Entity

```swift
// Domain/Entities/PoopLog.swift
struct PoopLog: Identifiable, Codable {
    let id: UUID
    let loggedAt: Date
    let durationSeconds: Int
    let rating: Rating
    let consistency: Int?
    let notes: String?
    let flushFundsEarned: Int

    enum Rating: String, Codable {
        case great, good, okay, bad, terrible
    }
}
```

### Step 2: Create DTO

```swift
// Data/DTOs/PoopLogDTO.swift
struct PoopLogDTO: Codable {
    let id: UUID?
    let deviceId: UUID?
    let loggedAt: Date
    let durationSeconds: Int
    let rating: String
    let consistency: Int?
    let notes: String?
    let flushFundsEarned: Int
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case deviceId = "device_id"
        case loggedAt = "logged_at"
        case durationSeconds = "duration_seconds"
        case rating
        case consistency
        case notes
        case flushFundsEarned = "flush_funds_earned"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
```

### Step 3: Add Conversion Extensions

```swift
// Data/DTOs/PoopLogDTO+Extensions.swift
extension PoopLog {
    func toDTO(deviceId: UUID) -> PoopLogDTO {
        PoopLogDTO(
            id: id,
            deviceId: deviceId,
            loggedAt: loggedAt,
            durationSeconds: durationSeconds,
            rating: rating.rawValue,
            consistency: consistency,
            notes: notes,
            flushFundsEarned: flushFundsEarned,
            createdAt: nil,
            updatedAt: nil,
            deletedAt: nil
        )
    }
}

extension PoopLogDTO {
    func toDomain() throws -> PoopLog {
        guard let rating = PoopLog.Rating(rawValue: rating) else {
            throw DataError.invalidRating(rating)
        }

        return PoopLog(
            id: id ?? UUID(),
            loggedAt: loggedAt,
            durationSeconds: durationSeconds,
            rating: rating,
            consistency: consistency,
            notes: notes,
            flushFundsEarned: flushFundsEarned
        )
    }
}
```

## Data Source Pattern

### Protocol Definition

```swift
// Data/DataSources/PoopLogDataSourceProtocol.swift
protocol PoopLogDataSourceProtocol {
    func fetchLogs(for deviceId: UUID, limit: Int, offset: Int) async throws -> [PoopLog]
    func createLog(_ log: PoopLog, deviceId: UUID) async throws -> PoopLog
    func updateLog(_ log: PoopLog, deviceId: UUID) async throws -> PoopLog
    func deleteLog(id: UUID, deviceId: UUID) async throws
    func fetchLog(id: UUID, deviceId: UUID) async throws -> PoopLog?
}
```

### Supabase Implementation

```swift
// Data/DataSources/SupabasePoopLogDataSource.swift
import Foundation
import Supabase

class SupabasePoopLogDataSource: PoopLogDataSourceProtocol {
    private let client: SupabaseClient
    private let deviceService: DeviceIdentificationService

    init(client: SupabaseClient, deviceService: DeviceIdentificationService) {
        self.client = client
        self.deviceService = deviceService
    }

    func fetchLogs(for deviceId: UUID, limit: Int = 30, offset: Int = 0) async throws -> [PoopLog] {
        // Set device context for RLS
        try await setDeviceContext()

        // Execute query
        let response = try await client
            .from("poop_logs")
            .select()
            .eq("device_id", value: deviceId.uuidString)
            .is("deleted_at", value: "null")
            .order("logged_at", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()

        // Decode DTOs
        let dtos = try JSONDecoder().decode([PoopLogDTO].self, from: response.data)

        // Convert to domain
        return try dtos.map { try $0.toDomain() }
    }

    func createLog(_ log: PoopLog, deviceId: UUID) async throws -> PoopLog {
        try await setDeviceContext()

        let dto = log.toDTO(deviceId: deviceId)

        let response = try await client
            .from("poop_logs")
            .insert(dto)
            .select()
            .single()
            .execute()

        let createdDTO = try JSONDecoder().decode(PoopLogDTO.self, from: response.data)
        return try createdDTO.toDomain()
    }

    func updateLog(_ log: PoopLog, deviceId: UUID) async throws -> PoopLog {
        try await setDeviceContext()

        let dto = log.toDTO(deviceId: deviceId)

        let response = try await client
            .from("poop_logs")
            .update(dto)
            .eq("id", value: log.id.uuidString)
            .eq("device_id", value: deviceId.uuidString)
            .select()
            .single()
            .execute()

        let updatedDTO = try JSONDecoder().decode(PoopLogDTO.self, from: response.data)
        return try updatedDTO.toDomain()
    }

    func deleteLog(id: UUID, deviceId: UUID) async throws {
        try await setDeviceContext()

        // Soft delete
        let now = Date()
        try await client
            .from("poop_logs")
            .update(["deleted_at": now])
            .eq("id", value: id.uuidString)
            .eq("device_id", value: deviceId.uuidString)
            .execute()
    }

    // MARK: - Private Helpers

    private func setDeviceContext() async throws {
        let deviceId = try await deviceService.getDeviceId()
        // Set JWT with device_id claim for RLS
        try await client.auth.setSession(/* device-based session */)
    }
}
```

## Database Schema Guidelines

### Table Structure Template

```sql
-- Migration file: docs/supabase-migrations/XX_create_table_name.sql

CREATE TABLE IF NOT EXISTS your_table (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,

    -- Your columns here (snake_case)
    your_column TEXT NOT NULL,
    another_column INTEGER,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ  -- For soft deletes
);

-- Indexes for performance
CREATE INDEX idx_your_table_device_id ON your_table(device_id);
CREATE INDEX idx_your_table_created_at ON your_table(created_at DESC);

-- Updated_at trigger
CREATE TRIGGER update_your_table_updated_at
    BEFORE UPDATE ON your_table
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row-Level Security
ALTER TABLE your_table ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their device's data"
    ON your_table
    FOR ALL
    USING (device_id = auth.uid());
```

### RLS Policy Patterns

**Read-only access:**
```sql
CREATE POLICY "Device can read own data"
    ON your_table
    FOR SELECT
    USING (device_id = auth.uid());
```

**Full access:**
```sql
CREATE POLICY "Device can manage own data"
    ON your_table
    FOR ALL
    USING (device_id = auth.uid());
```

**Insert-only:**
```sql
CREATE POLICY "Device can create own data"
    ON your_table
    FOR INSERT
    WITH CHECK (device_id = auth.uid());
```

## Common Queries

### Pagination

```swift
func fetchPaginated(page: Int, pageSize: Int = 30) async throws -> [PoopLog] {
    let offset = page * pageSize
    return try await fetchLogs(for: deviceId, limit: pageSize, offset: offset)
}
```

### Filtering by Date Range

```swift
func fetchLogs(from startDate: Date, to endDate: Date) async throws -> [PoopLog] {
    try await setDeviceContext()

    let response = try await client
        .from("poop_logs")
        .select()
        .eq("device_id", value: deviceId.uuidString)
        .gte("logged_at", value: startDate.iso8601)
        .lte("logged_at", value: endDate.iso8601)
        .is("deleted_at", value: "null")
        .order("logged_at", ascending: false)
        .execute()

    let dtos = try JSONDecoder().decode([PoopLogDTO].self, from: response.data)
    return try dtos.map { try $0.toDomain() }
}
```

### Aggregations

```swift
func getTotalLogs(for deviceId: UUID) async throws -> Int {
    try await setDeviceContext()

    let response = try await client
        .from("poop_logs")
        .select("id", head: false, count: .exact)
        .eq("device_id", value: deviceId.uuidString)
        .is("deleted_at", value: "null")
        .execute()

    return response.count ?? 0
}
```

## Error Handling

```swift
enum SupabaseError: PPError {
    case networkError(Error)
    case unauthorized
    case notFound
    case invalidData
    case deviceNotRegistered

    var title: String {
        switch self {
        case .networkError: return "Connection Error"
        case .unauthorized: return "Access Denied"
        case .notFound: return "Not Found"
        case .invalidData: return "Invalid Data"
        case .deviceNotRegistered: return "Device Not Registered"
        }
    }

    var message: String {
        switch self {
        case .networkError:
            return "Unable to connect to the server. Please check your internet connection."
        case .unauthorized:
            return "You don't have permission to access this data."
        case .notFound:
            return "The requested data could not be found."
        case .invalidData:
            return "The data received is invalid or corrupted."
        case .deviceNotRegistered:
            return "This device is not registered. Please restart the app."
        }
    }

    var recoveryAction: RecoveryAction? {
        switch self {
        case .networkError:
            return .retry
        case .deviceNotRegistered:
            return .custom("Restart App")
        default:
            return nil
        }
    }
}
```

## Testing Supabase Integration

### Mock Data Source

```swift
class MockPoopLogDataSource: PoopLogDataSourceProtocol {
    var logsToReturn: [PoopLog] = []
    var shouldThrowError = false

    func fetchLogs(for deviceId: UUID, limit: Int, offset: Int) async throws -> [PoopLog] {
        if shouldThrowError {
            throw SupabaseError.networkError(NSError(domain: "", code: -1))
        }
        return logsToReturn
    }

    // Implement other methods...
}
```

## Performance Optimization

### 1. Use Proper Indexes
```sql
CREATE INDEX idx_poop_logs_device_logged ON poop_logs(device_id, logged_at DESC);
```

### 2. Limit Query Results
```swift
// Always specify limits
.range(from: 0, to: 29)  // First 30 items
```

### 3. Select Specific Columns
```swift
// Only fetch needed columns
.select("id, logged_at, rating")
```

### 4. Use Connection Pooling
```swift
// Reuse SupabaseClient instance
// Don't create new clients for each request
```

## Checklist

Before completing Supabase integration work:

- [ ] DTO created with snake_case CodingKeys
- [ ] Domain entity uses camelCase
- [ ] Conversion extensions implemented (toDTO, toDomain)
- [ ] Data source protocol defined
- [ ] Supabase implementation created
- [ ] Device context set before queries
- [ ] RLS policies configured
- [ ] Soft delete implemented (deleted_at)
- [ ] Indexes created for performance
- [ ] Error handling implemented
- [ ] Migration file created
- [ ] Tests written for data source

## References

- Database schema: `docs/03-database-schema.md`
- Supabase integration guide: `docs/05-supabase-integration.md`
- Device identification: `docs/06-device-identification.md`
- Migration files: `docs/supabase-migrations/`
