---
name: keychain-storage
description: Expert at secure iOS Keychain storage for sensitive data. Use when implementing device identification, storing API tokens, or managing secure credentials. Specializes in Keychain Services API and security best practices.
---

# Keychain Storage

Expert skill for implementing secure data storage using iOS Keychain Services.

## When to Use This Skill

- Storing device ID securely
- Managing authentication tokens
- Saving API keys or secrets
- Implementing secure credential storage
- Debugging Keychain access issues
- Migrating data to/from Keychain

## Core Principles

### What Goes in Keychain

**ALWAYS store in Keychain:**
- Device ID (anonymous UUID)
- Authentication tokens
- API keys
- Encryption keys
- User credentials (if applicable)

**NEVER store in Keychain:**
- Non-sensitive app preferences
- UI state
- Cache data
- Public configuration

**NEVER store in UserDefaults:**
- Device ID
- Tokens
- API keys
- Any sensitive data

## Keychain Service Implementation

### KeychainService Protocol

```swift
// Core/Services/Keychain/KeychainServiceProtocol.swift
import Foundation

protocol KeychainServiceProtocol {
    func save(_ data: Data, for key: String) throws
    func load(for key: String) throws -> Data?
    func delete(for key: String) throws
    func exists(for key: String) -> Bool
}

enum KeychainError: Error, LocalizedError {
    case saveFailed(status: OSStatus)
    case loadFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    case dataConversionFailed
    case unexpectedData
    case itemNotFound

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to Keychain. Status: \(status)"
        case .loadFailed(let status):
            return "Failed to load from Keychain. Status: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from Keychain. Status: \(status)"
        case .dataConversionFailed:
            return "Failed to convert data"
        case .unexpectedData:
            return "Unexpected data format"
        case .itemNotFound:
            return "Item not found in Keychain"
        }
    }
}
```

### KeychainService Implementation

```swift
// Core/Services/Keychain/KeychainService.swift
import Foundation
import Security

class KeychainService: KeychainServiceProtocol {
    // MARK: - Properties
    private let service: String

    // MARK: - Initialization
    init(service: String = Bundle.main.bundleIdentifier ?? "com.poopypals") {
        self.service = service
    }

    // MARK: - Public Methods
    func save(_ data: Data, for key: String) throws {
        // Delete existing item if present
        try? delete(for: key)

        // Prepare query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Save to Keychain
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }

    func load(for key: String) throws -> Data? {
        // Prepare query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        // Load from Keychain
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        // Handle not found
        if status == errSecItemNotFound {
            return nil
        }

        // Handle errors
        guard status == errSecSuccess else {
            throw KeychainError.loadFailed(status: status)
        }

        // Return data
        guard let data = result as? Data else {
            throw KeychainError.unexpectedData
        }

        return data
    }

    func delete(for key: String) throws {
        // Prepare query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        // Delete from Keychain
        let status = SecItemDelete(query as CFDictionary)

        // Ignore not found errors
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }

    func exists(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}
```

### String & UUID Extensions

```swift
// Core/Services/Keychain/KeychainService+Extensions.swift
extension KeychainService {
    // MARK: - String Helpers
    func saveString(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.dataConversionFailed
        }
        try save(data, for: key)
    }

    func loadString(for key: String) throws -> String? {
        guard let data = try load(for: key) else {
            return nil
        }

        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.dataConversionFailed
        }

        return string
    }

    // MARK: - UUID Helpers
    func saveUUID(_ uuid: UUID, for key: String) throws {
        try saveString(uuid.uuidString, for: key)
    }

    func loadUUID(for key: String) throws -> UUID? {
        guard let uuidString = try loadString(for: key) else {
            return nil
        }

        guard let uuid = UUID(uuidString: uuidString) else {
            throw KeychainError.dataConversionFailed
        }

        return uuid
    }

    // MARK: - Codable Helpers
    func saveCodable<T: Encodable>(_ value: T, for key: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        try save(data, for: key)
    }

    func loadCodable<T: Decodable>(for key: String) throws -> T? {
        guard let data = try load(for: key) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
```

## Device ID Service

### Implementation

```swift
// Core/Services/DeviceIdentification/DeviceIdentificationService.swift
import Foundation

class DeviceIdentificationService {
    // MARK: - Properties
    private let keychain: KeychainServiceProtocol
    private let deviceIdKey = "com.poopypals.deviceId"

    // MARK: - Cached Value
    private var cachedDeviceId: UUID?

    // MARK: - Initialization
    init(keychain: KeychainServiceProtocol = KeychainService()) {
        self.keychain = keychain
    }

    // MARK: - Public Methods

    /// Gets the device ID, creating one if it doesn't exist
    func getDeviceId() async throws -> UUID {
        // Return cached value if available
        if let cached = cachedDeviceId {
            return cached
        }

        // Try loading from Keychain
        if let existingId = try keychain.loadUUID(for: deviceIdKey) {
            cachedDeviceId = existingId
            return existingId
        }

        // Generate new ID
        let newId = UUID()

        // Save to Keychain
        try keychain.saveUUID(newId, for: deviceIdKey)

        // Cache and return
        cachedDeviceId = newId
        return newId
    }

    /// Gets device ID synchronously (uses cached value)
    func getDeviceIdSync() throws -> UUID {
        if let cached = cachedDeviceId {
            return cached
        }

        if let existingId = try keychain.loadUUID(for: deviceIdKey) {
            cachedDeviceId = existingId
            return existingId
        }

        throw DeviceIdentificationError.deviceIdNotFound
    }

    /// Check if device is registered
    func hasDeviceId() -> Bool {
        keychain.exists(for: deviceIdKey)
    }

    /// Reset device ID (use with caution!)
    func resetDeviceId() throws {
        try keychain.delete(for: deviceIdKey)
        cachedDeviceId = nil
    }

    /// Import device ID from another device
    func importDeviceId(_ uuid: UUID) throws {
        try keychain.saveUUID(uuid, for: deviceIdKey)
        cachedDeviceId = uuid
    }

    /// Export device ID for backup
    func exportDeviceId() throws -> UUID {
        guard let deviceId = try keychain.loadUUID(for: deviceIdKey) else {
            throw DeviceIdentificationError.deviceIdNotFound
        }
        return deviceId
    }
}

enum DeviceIdentificationError: Error, LocalizedError {
    case deviceIdNotFound
    case invalidDeviceId

    var errorDescription: String? {
        switch self {
        case .deviceIdNotFound:
            return "Device ID not found. Please restart the app."
        case .invalidDeviceId:
            return "The provided device ID is invalid."
        }
    }
}
```

## Keychain Keys

### Centralized Key Management

```swift
// Core/Services/Keychain/KeychainKeys.swift
enum KeychainKeys {
    static let deviceId = "com.poopypals.deviceId"
    static let supabaseToken = "com.poopypals.supabaseToken"
    static let lastSyncDate = "com.poopypals.lastSyncDate"

    // NEVER use these keys:
    // ❌ "deviceId" - Too generic
    // ❌ "token" - Too generic
    // ✅ Use reverse domain notation
}
```

## Security Best Practices

### Accessibility Levels

```swift
// Choose appropriate accessibility
let query: [String: Any] = [
    // ...
    kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
]

// Options:
// - kSecAttrAccessibleWhenUnlocked (most secure, only when unlocked)
// - kSecAttrAccessibleAfterFirstUnlock (recommended for PoopyPals)
// - kSecAttrAccessibleAlways (least secure, avoid)
// - kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly (requires passcode)
```

### Data Protection

```swift
// For extra sensitive data
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: service,
    kSecAttrAccount as String: key,
    kSecValueData as String: data,
    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    // "ThisDeviceOnly" prevents iCloud backup
]
```

## Testing Keychain

### Mock Keychain Service

```swift
class MockKeychainService: KeychainServiceProtocol {
    private var storage: [String: Data] = [:]

    func save(_ data: Data, for key: String) throws {
        storage[key] = data
    }

    func load(for key: String) throws -> Data? {
        storage[key]
    }

    func delete(for key: String) throws {
        storage.removeValue(forKey: key)
    }

    func exists(for key: String) -> Bool {
        storage[key] != nil
    }

    func reset() {
        storage.removeAll()
    }
}
```

### Testing Device ID Service

```swift
final class DeviceIdentificationServiceTests: XCTestCase {
    var sut: DeviceIdentificationService!
    var mockKeychain: MockKeychainService!

    override func setUp() {
        mockKeychain = MockKeychainService()
        sut = DeviceIdentificationService(keychain: mockKeychain)
    }

    override func tearDown() {
        mockKeychain.reset()
        sut = nil
        mockKeychain = nil
    }

    func testGetDeviceId_FirstLaunch_GeneratesAndSavesId() async throws {
        // When
        let deviceId = try await sut.getDeviceId()

        // Then
        XCTAssertNotNil(deviceId)
        XCTAssertTrue(mockKeychain.exists(for: "com.poopypals.deviceId"))
    }

    func testGetDeviceId_SecondCall_ReturnsSameId() async throws {
        // Given
        let firstId = try await sut.getDeviceId()

        // When
        let secondId = try await sut.getDeviceId()

        // Then
        XCTAssertEqual(firstId, secondId)
    }

    func testImportDeviceId_SavesProvidedId() throws {
        // Given
        let importedId = UUID()

        // When
        try sut.importDeviceId(importedId)

        // Then
        let retrievedId = try sut.getDeviceIdSync()
        XCTAssertEqual(retrievedId, importedId)
    }
}
```

## Common Patterns

### Lazy Device ID Loading

```swift
class MyViewModel: ObservableObject {
    private let deviceService: DeviceIdentificationService
    private var deviceId: UUID?

    func performAction() async {
        // Get device ID lazily
        if deviceId == nil {
            deviceId = try? await deviceService.getDeviceId()
        }

        guard let deviceId = deviceId else {
            handleError(DeviceIdentificationError.deviceIdNotFound)
            return
        }

        // Use deviceId...
    }
}
```

### Device Registration Flow

```swift
class AppCoordinator {
    func registerDeviceIfNeeded() async {
        let deviceService = DeviceIdentificationService()

        do {
            let deviceId = try await deviceService.getDeviceId()

            // Check if registered in backend
            let isRegistered = try await checkDeviceRegistration(deviceId)

            if !isRegistered {
                // Register device in Supabase
                try await registerDevice(deviceId)
            }
        } catch {
            // Handle error
        }
    }
}
```

## Migration from UserDefaults

### Safe Migration Pattern

```swift
class DeviceIdMigration {
    static func migrateFromUserDefaults() throws {
        let keychain = KeychainService()
        let userDefaults = UserDefaults.standard
        let oldKey = "deviceId"
        let keychainKey = "com.poopypals.deviceId"

        // Check if already migrated
        if keychain.exists(for: keychainKey) {
            // Clean up old value
            userDefaults.removeObject(forKey: oldKey)
            return
        }

        // Migrate if exists in UserDefaults
        if let uuidString = userDefaults.string(forKey: oldKey),
           let uuid = UUID(uuidString: uuidString) {
            // Save to Keychain
            try keychain.saveUUID(uuid, for: keychainKey)

            // Remove from UserDefaults
            userDefaults.removeObject(forKey: oldKey)

            print("✅ Migrated device ID to Keychain")
        }
    }
}
```

## Error Handling

```swift
func loadDeviceId() async {
    do {
        let deviceId = try await deviceService.getDeviceId()
        // Use deviceId
    } catch let error as KeychainError {
        handleKeychainError(error)
    } catch {
        handleGenericError(error)
    }
}

func handleKeychainError(_ error: KeychainError) {
    switch error {
    case .itemNotFound:
        // Generate new device ID
        Task {
            _ = try? await deviceService.getDeviceId()
        }
    case .saveFailed, .loadFailed:
        // Show error to user
        showError("Unable to access secure storage. Please restart the app.")
    default:
        showError("An unexpected error occurred.")
    }
}
```

## Checklist

- [ ] All sensitive data stored in Keychain
- [ ] Device ID never stored in UserDefaults
- [ ] Appropriate accessibility level set
- [ ] Error handling implemented
- [ ] Mock Keychain for testing
- [ ] Device ID cached for performance
- [ ] Migration from UserDefaults (if applicable)
- [ ] Keys use reverse domain notation
- [ ] Tests written for Keychain operations
- [ ] No hard-coded credentials

## Common Mistakes

### ❌ Storing Device ID in UserDefaults

```swift
// WRONG
UserDefaults.standard.set(deviceId.uuidString, forKey: "deviceId")

// CORRECT
try keychain.saveUUID(deviceId, for: KeychainKeys.deviceId)
```

### ❌ Not Handling Keychain Errors

```swift
// WRONG
let deviceId = try! keychain.loadUUID(for: key)

// CORRECT
do {
    if let deviceId = try keychain.loadUUID(for: key) {
        // Use deviceId
    } else {
        // Generate new
    }
} catch {
    handleError(error)
}
```

### ❌ Creating New Device ID on Every Launch

```swift
// WRONG
func getDeviceId() -> UUID {
    return UUID() // Creates new every time!
}

// CORRECT
func getDeviceId() async throws -> UUID {
    // Load from Keychain or generate once
    if let existing = try keychain.loadUUID(for: key) {
        return existing
    }
    let new = UUID()
    try keychain.saveUUID(new, for: key)
    return new
}
```

## References

- Device identification guide: `docs/06-device-identification.md`
- Apple Keychain Services: Developer Documentation
- Security best practices: Apple Security Guide
