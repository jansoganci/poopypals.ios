# PoopyPals iOS - Device Identification Strategy

## 🎯 Overview

PoopyPals uses **device-based identification** instead of traditional user authentication. Users can open the app and start using it immediately without creating an account. Their data syncs across the same device and can be optionally migrated to new devices.

## 🔑 Why Device-Based Identification?

### Benefits
- ✅ **Zero friction onboarding** - No sign-up required
- ✅ **Privacy-first** - No email, password, or personal info
- ✅ **Immediate value** - Start logging instantly
- ✅ **Simple UX** - No forgotten passwords or account recovery

### Trade-offs
- ⚠️ **Single device by default** - Data tied to one device
- ⚠️ **Manual migration** - Requires user action to move data
- ⚠️ **No cross-device sync** - (unless device ID is transferred)

## 🔐 Implementation

### 1. Device ID Generation

Generate a **UUID** on first launch and store securely in **Keychain**.

```swift
import Foundation
import Security

class DeviceIDService {
    static let shared = DeviceIDService()

    private let keychainService: KeychainService
    private let deviceIDKey = "com.poopypals.deviceID"

    private init() {
        self.keychainService = KeychainService()
    }

    // MARK: - Get or Create Device ID
    func getDeviceID() -> String {
        // Try to retrieve existing device ID from Keychain
        if let existingID = keychainService.getString(forKey: deviceIDKey) {
            return existingID
        }

        // Generate new device ID if none exists
        let newDeviceID = UUID().uuidString
        keychainService.setString(newDeviceID, forKey: deviceIDKey)

        print("📱 New device ID generated: \(newDeviceID)")
        return newDeviceID
    }

    // MARK: - Reset Device ID (for testing or migration)
    func resetDeviceID() {
        keychainService.delete(key: deviceIDKey)
        print("🗑️ Device ID reset")
    }

    // MARK: - Import Device ID (for migration)
    func importDeviceID(_ deviceID: String) -> Bool {
        guard UUID(uuidString: deviceID) != nil else {
            print("❌ Invalid device ID format")
            return false
        }

        keychainService.setString(deviceID, forKey: deviceIDKey)
        print("📥 Device ID imported: \(deviceID)")
        return true
    }

    // MARK: - Export Device ID (for migration)
    func exportDeviceID() -> String {
        return getDeviceID()
    }
}
```

### 2. Keychain Service

Securely store device ID in iOS Keychain:

```swift
import Foundation
import Security

class KeychainService {

    // MARK: - Save String
    func setString(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }

        // Delete any existing value
        delete(key: key)

        // Add new value
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            print("❌ Keychain save failed: \(status)")
        }
    }

    // MARK: - Get String
    func getString(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    // MARK: - Delete
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Clear All (for testing)
    func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        SecItemDelete(query as CFDictionary)
    }
}
```

### 3. Device Registration Flow

Register device with Supabase on first launch:

```swift
// In AppCoordinator or SceneDelegate

@MainActor
class AppCoordinator: ObservableObject {
    private let supabaseService: SupabaseService
    private let deviceIDService: DeviceIDService

    func start() async {
        // 1. Get or create device ID
        let deviceID = deviceIDService.getDeviceID()

        // 2. Register device with Supabase
        do {
            try await supabaseService.registerDevice()
            print("✅ Device registered successfully")
        } catch {
            print("❌ Device registration failed: \(error)")
            // Handle error (retry, show offline mode, etc.)
        }

        // 3. Initial sync
        do {
            try await SyncService.shared.syncNow()
        } catch {
            print("⚠️ Initial sync failed, continuing offline")
        }
    }
}
```

## 📱 Device Information Collection

Collect minimal device info for debugging and analytics:

```swift
extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return identifier
    }

    var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}
```

## 🔄 Device Migration

### Export Flow (Old Device)

Allow users to export their device ID to migrate to a new device:

```swift
class MigrationViewModel: ObservableObject {
    @Published var deviceID: String = ""
    @Published var showingQRCode = false

    private let deviceIDService = DeviceIDService.shared

    func exportDeviceID() {
        deviceID = deviceIDService.exportDeviceID()
        showingQRCode = true
    }

    func generateQRCode() -> UIImage? {
        let data = deviceID.data(using: .utf8)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")

        if let outputImage = filter?.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)

            let context = CIContext()
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return nil
    }
}
```

### Import Flow (New Device)

```swift
extension MigrationViewModel {
    func importDeviceID(_ scannedID: String) async -> Bool {
        // 1. Validate format
        guard deviceIDService.importDeviceID(scannedID) else {
            return false
        }

        // 2. Sync data from cloud
        do {
            try await SyncService.shared.syncNow()
            return true
        } catch {
            print("❌ Migration sync failed: \(error)")
            return false
        }
    }

    func manuallyEnterDeviceID(_ deviceID: String) async -> Bool {
        await importDeviceID(deviceID)
    }
}
```

### Migration UI Flow

```swift
struct MigrationView: View {
    @StateObject private var viewModel = MigrationViewModel()
    @State private var showingScanner = false

    var body: some View {
        VStack(spacing: PPSpacing.lg) {
            Text("Transfer Your Data")
                .font(.ppTitle1)

            // Export Option
            VStack(spacing: PPSpacing.md) {
                Text("From This Device")
                    .font(.ppLabelLarge)

                if viewModel.showingQRCode, let qrCode = viewModel.generateQRCode() {
                    Image(uiImage: qrCode)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 200, height: 200)

                    Text(viewModel.deviceID)
                        .font(.ppCaptionSmall)
                        .textSelection(.enabled)
                }

                PPButton(title: "Show QR Code") {
                    viewModel.exportDeviceID()
                }
            }
            .padding(PPSpacing.lg)
            .background(Color.ppBackgroundSecondary)
            .cornerRadius(PPCornerRadius.md)

            Divider()

            // Import Option
            VStack(spacing: PPSpacing.md) {
                Text("To This Device")
                    .font(.ppLabelLarge)

                PPButton(title: "Scan QR Code") {
                    showingScanner = true
                }

                PPButton(title: "Enter Device ID Manually") {
                    // Show text input
                }
            }
            .padding(PPSpacing.lg)
            .background(Color.ppBackgroundSecondary)
            .cornerRadius(PPCornerRadius.md)
        }
        .padding(PPSpacing.lg)
        .sheet(isPresented: $showingScanner) {
            QRCodeScannerView { scannedID in
                Task {
                    let success = await viewModel.importDeviceID(scannedID)
                    if success {
                        showingScanner = false
                    }
                }
            }
        }
    }
}
```

## 🔒 Security Considerations

### Keychain Access
- Use `kSecAttrAccessibleAfterFirstUnlock` for device ID
- Device ID persists across app reinstalls
- Survives app updates

### Device ID as "Password"
- Treat device ID like a password
- Warn users to keep it secure
- Don't display in screenshots or share publicly

### Potential Attacks
- **Brute Force:** UUIDs are 128-bit, computationally infeasible to guess
- **Man-in-the-Middle:** Use HTTPS for all Supabase communication
- **Device Theft:** Consider optional PIN/FaceID for app access (future feature)

## 📊 Supabase RLS Configuration

Set up Row Level Security to ensure devices only access their own data:

```sql
-- Create function to get device_id from context
CREATE OR REPLACE FUNCTION get_current_device_id()
RETURNS UUID AS $$
BEGIN
    RETURN current_setting('app.device_id', TRUE)::UUID;
END;
$$ LANGUAGE plpgsql STABLE;

-- RLS Policy: Devices can only read their own data
CREATE POLICY "Devices can read own data" ON poop_logs
    FOR SELECT
    USING (device_id = get_current_device_id());

-- RLS Policy: Devices can only insert their own data
CREATE POLICY "Devices can insert own data" ON poop_logs
    FOR INSERT
    WITH CHECK (device_id = get_current_device_id());

-- RLS Policy: Devices can only update their own data
CREATE POLICY "Devices can update own data" ON poop_logs
    FOR UPDATE
    USING (device_id = get_current_device_id());

-- RLS Policy: Devices can only delete their own data
CREATE POLICY "Devices can delete own data" ON poop_logs
    FOR DELETE
    USING (device_id = get_current_device_id());
```

### Setting Device Context in iOS

```swift
extension SupabaseService {
    func setDeviceContext() async throws {
        let deviceID = deviceIDService.getDeviceID()

        // Call stored procedure to set session variable
        try await client.rpc(
            "set_config",
            params: [
                "setting": "app.device_id",
                "value": deviceID,
                "is_local": true
            ]
        ).execute()
    }
}

// Call before every request
func performSecureRequest() async throws {
    try await supabaseService.setDeviceContext()
    // Now make your query...
}
```

## 🧪 Testing Device ID

### Unit Tests

```swift
import XCTest
@testable import PoopyPals

class DeviceIDServiceTests: XCTestCase {

    var service: DeviceIDService!
    var keychainService: KeychainService!

    override func setUp() {
        super.setUp()
        keychainService = KeychainService()
        service = DeviceIDService.shared

        // Clear keychain before each test
        keychainService.clearAll()
    }

    func testDeviceIDGeneration() {
        let deviceID1 = service.getDeviceID()
        XCTAssertFalse(deviceID1.isEmpty)

        // Should return same ID on subsequent calls
        let deviceID2 = service.getDeviceID()
        XCTAssertEqual(deviceID1, deviceID2)
    }

    func testDeviceIDPersistence() {
        let deviceID = service.getDeviceID()

        // Simulate app restart by creating new service instance
        let newService = DeviceIDService.shared
        let retrievedID = newService.getDeviceID()

        XCTAssertEqual(deviceID, retrievedID)
    }

    func testDeviceIDReset() {
        let deviceID1 = service.getDeviceID()
        service.resetDeviceID()
        let deviceID2 = service.getDeviceID()

        XCTAssertNotEqual(deviceID1, deviceID2)
    }

    func testDeviceIDImport() {
        let validID = UUID().uuidString
        let success = service.importDeviceID(validID)

        XCTAssertTrue(success)
        XCTAssertEqual(service.getDeviceID(), validID)
    }

    func testInvalidDeviceIDImport() {
        let invalidID = "not-a-valid-uuid"
        let success = service.importDeviceID(invalidID)

        XCTAssertFalse(success)
    }
}
```

## 📱 App Clips Consideration (Future)

If implementing App Clips:
- Generate temporary device ID for clip
- Prompt to migrate to full app
- Transfer clip data to full app device ID

## 🎯 Best Practices

1. **Generate Once** - Create device ID on first launch only
2. **Store Securely** - Always use Keychain, never UserDefaults
3. **Validate Format** - Ensure UUIDs are valid before import
4. **Sync Immediately** - After migration, sync data right away
5. **User Education** - Explain migration process clearly
6. **Backup Warning** - Warn users to save device ID before wiping device

## 📚 Related Documentation

- [Supabase Integration](./05-supabase-integration.md)
- [Database Schema](./03-database-schema.md)
- [Error Handling](./07-error-handling.md)

---

**Last Updated:** 2025-11-11
**Version:** 1.0.0
