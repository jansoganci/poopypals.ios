# StableID Integration Plan

## 1. Overview
**Goal:** Fix the issue where `DeviceIdentificationService` generates a new Device ID on every launch, causing `deviceNotRegistered` errors and data inconsistency in Supabase.
**Solution:** Integrate the `StableID` library to ensure the Device ID persists across app launches and re-installations.

---

## 2. Current State Analysis
- **Problem:** `DeviceIdentificationService.getDeviceId()` creates a `UUID()` every time it's called if not cached in memory.
- **Impact:**
  1. Supabase sees a new device every session.
  2. `fetchLogs` fails because the current session ID doesn't match the registered ID in the database.
  3. Background sync fails with `deviceNotRegistered`.
- **Status:** `StableID` package is already added to the Xcode project but not implemented in code.

---

## 3. Implementation Plan

### Phase 1: Core Service Update
**File:** `poopypals/Core/Utilities/DeviceIdentificationService.swift`

1.  **Import Library:**
    - Add `import StableID`.

2.  **Initialize StableID:**
    - Create a private property for the StableID instance.

3.  **Implement UUID Conversion Strategy:**
    - StableID returns a `String`. Supabase requires a `UUID`.
    - We must strictly ensure the String -> UUID conversion is **deterministic**.
    - **Logic:**
      ```swift
      if let uuid = UUID(uuidString: stableId) {
          return uuid
      } else {
          // Fallback: Create UUID from hash of StableID string to ensure it never changes
          return UUID(fromHashOf: stableId)
      }
      ```

4.  **Refactor `getDeviceId()` (Async):**
    - Check memory cache (`cachedDeviceId`).
    - If missing, retrieve ID from `StableID`.
    - Convert to UUID.
    - Update cache.
    - Return UUID.

5.  **Refactor `getDeviceIdSync()` (Sync):**
    - Check memory cache.
    - If missing, attempt synchronous retrieval from StableID (if supported) or throw an error indicating the service must be initialized asynchronously first.

### Phase 2: Error Handling
**File:** `poopypals/Core/Utilities/DeviceIdentificationService.swift`

- Define `DeviceError` enum:
  - `invalidStableID`: If conversion fails.
  - `initializationFailed`: If StableID cannot access Keychain.

### Phase 3: Verification & Testing

1.  **Launch Consistency Test:**
    - Launch App -> Log Device ID (A).
    - Kill App -> Launch App -> Log Device ID (B).
    - **Success Criteria:** A == B.

2.  **Reinstall Consistency Test:**
    - Delete App -> Reinstall -> Launch -> Log Device ID (C).
    - **Success Criteria:** A == C (StableID persists via Keychain).

3.  **Supabase Connection Test:**
    - Run `BackendTester`.
    - Verify `fetchLogs` no longer returns `deviceNotRegistered`.

---

## 4. Proposed Code Structure

### `DeviceIdentificationService.swift`

```swift
import Foundation
import StableID

class DeviceIdentificationService {
    // MARK: - Properties
    private var cachedDeviceId: UUID?
    
    // MARK: - Public Methods
    
    func getDeviceId() async throws -> UUID {
        // 1. Return cached
        if let cached = cachedDeviceId { return cached }
        
        // 2. Get Stable ID
        let stableId = StableID.shared.id // assuming usage
        
        // 3. Convert to UUID
        let uuid = try convertToUUID(stableId)
        
        // 4. Cache and return
        cachedDeviceId = uuid
        return uuid
    }
    
    // ... helper methods ...
}
```

## 5. Execution Steps
1. Modify `DeviceIdentificationService.swift`.
2. Run `BackendTester` to verify ID persistence.
3. Verify Supabase logs to ensure `PGRST116` and `deviceNotRegistered` errors are resolved.


