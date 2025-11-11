# PoopyPals iOS - Error Handling Guide

## 🎯 Error Handling Philosophy

PoopyPals follows these principles for error handling:

1. **User-Friendly** - Show clear, actionable error messages
2. **Graceful Degradation** - App works offline when backend is unavailable
3. **Transparent** - Don't hide errors, but don't panic users
4. **Recoverable** - Provide recovery actions when possible
5. **Logged** - Track errors for debugging (without PII)

## 🏗️ Error Architecture

### Error Type Hierarchy

```swift
// Base error protocol
protocol PPError: LocalizedError {
    var title: String { get }
    var message: String { get }
    var recoveryAction: RecoveryAction? { get }
}

enum RecoveryAction {
    case retry
    case goOffline
    case contactSupport
    case dismiss
    case custom(title: String, action: () -> Void)
}
```

### Domain-Specific Errors

```swift
// MARK: - Network Errors
enum NetworkError: PPError {
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse

    var title: String {
        switch self {
        case .noConnection: return "No Internet Connection"
        case .timeout: return "Request Timeout"
        case .serverError: return "Server Error"
        case .invalidResponse: return "Invalid Response"
        }
    }

    var message: String {
        switch self {
        case .noConnection:
            return "Please check your internet connection and try again."
        case .timeout:
            return "The request took too long. Please try again."
        case .serverError(let code):
            return "The server returned an error (code: \(code)). Please try again later."
        case .invalidResponse:
            return "The server response was invalid. Please try again."
        }
    }

    var recoveryAction: RecoveryAction? {
        switch self {
        case .noConnection:
            return .goOffline
        case .timeout, .serverError, .invalidResponse:
            return .retry
        }
    }

    var errorDescription: String? { message }
}

// MARK: - Data Errors
enum DataError: PPError {
    case notFound
    case invalidFormat
    case corruptedData
    case saveFailed

    var title: String {
        switch self {
        case .notFound: return "Not Found"
        case .invalidFormat: return "Invalid Format"
        case .corruptedData: return "Corrupted Data"
        case .saveFailed: return "Save Failed"
        }
    }

    var message: String {
        switch self {
        case .notFound:
            return "The requested item could not be found."
        case .invalidFormat:
            return "The data format is invalid."
        case .corruptedData:
            return "The data appears to be corrupted. Please try resyncing."
        case .saveFailed:
            return "Failed to save your data. Please try again."
        }
    }

    var recoveryAction: RecoveryAction? {
        switch self {
        case .notFound:
            return .dismiss
        case .invalidFormat, .corruptedData:
            return .contactSupport
        case .saveFailed:
            return .retry
        }
    }

    var errorDescription: String? { message }
}

// MARK: - Validation Errors
enum ValidationError: PPError {
    case invalidDuration
    case invalidConsistency
    case missingRequiredField(field: String)
    case dateTooFarInFuture

    var title: String { "Invalid Input" }

    var message: String {
        switch self {
        case .invalidDuration:
            return "Duration must be between 1 second and 2 hours."
        case .invalidConsistency:
            return "Please select a consistency level between 1 and 7."
        case .missingRequiredField(let field):
            return "The field '\(field)' is required."
        case .dateTooFarInFuture:
            return "Log date cannot be in the future."
        }
    }

    var recoveryAction: RecoveryAction? {
        return .dismiss
    }

    var errorDescription: String? { message }
}

// MARK: - Sync Errors
enum SyncError: PPError {
    case conflictDetected
    case deviceNotRegistered
    case syncInProgress
    case partialSyncFailure(successCount: Int, failureCount: Int)

    var title: String {
        switch self {
        case .conflictDetected: return "Sync Conflict"
        case .deviceNotRegistered: return "Device Not Registered"
        case .syncInProgress: return "Sync in Progress"
        case .partialSyncFailure: return "Partial Sync Failure"
        }
    }

    var message: String {
        switch self {
        case .conflictDetected:
            return "A conflict was detected while syncing. Your local changes will be preserved."
        case .deviceNotRegistered:
            return "Your device is not registered. Please restart the app."
        case .syncInProgress:
            return "A sync is already in progress. Please wait."
        case .partialSyncFailure(let success, let failure):
            return "Synced \(success) items successfully, but \(failure) items failed. Please try again."
        }
    }

    var recoveryAction: RecoveryAction? {
        switch self {
        case .conflictDetected:
            return .dismiss
        case .deviceNotRegistered:
            return .custom(title: "Restart App") {
                // Handle restart
            }
        case .syncInProgress:
            return .dismiss
        case .partialSyncFailure:
            return .retry
        }
    }

    var errorDescription: String? { message }
}

// MARK: - Supabase Errors
enum SupabaseError: PPError {
    case invalidConfiguration
    case unauthorized
    case rateLimited
    case unknownError(Error)

    var title: String {
        switch self {
        case .invalidConfiguration: return "Configuration Error"
        case .unauthorized: return "Unauthorized"
        case .rateLimited: return "Rate Limited"
        case .unknownError: return "Unknown Error"
        }
    }

    var message: String {
        switch self {
        case .invalidConfiguration:
            return "The app is not configured correctly. Please reinstall."
        case .unauthorized:
            return "Your device is not authorized. Please restart the app."
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .unknownError(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    var recoveryAction: RecoveryAction? {
        switch self {
        case .invalidConfiguration:
            return .contactSupport
        case .unauthorized:
            return .retry
        case .rateLimited:
            return .custom(title: "Wait and Retry") {
                // Wait then retry
            }
        case .unknownError:
            return .retry
        }
    }

    var errorDescription: String? { message }
}
```

## 🎨 Error Presentation

### Error Alert View

```swift
struct ErrorAlert: Identifiable {
    let id = UUID()
    let error: PPError

    var alert: Alert {
        Alert(
            title: Text(error.title),
            message: Text(error.message),
            dismissButton: .default(Text("OK"))
        )
    }

    var alertWithRecovery: Alert {
        guard let recovery = error.recoveryAction else {
            return alert
        }

        switch recovery {
        case .retry:
            return Alert(
                title: Text(error.title),
                message: Text(error.message),
                primaryButton: .default(Text("Retry")) {
                    // Handle retry
                },
                secondaryButton: .cancel()
            )

        case .goOffline:
            return Alert(
                title: Text(error.title),
                message: Text(error.message),
                primaryButton: .default(Text("Continue Offline")) {
                    // Switch to offline mode
                },
                secondaryButton: .cancel()
            )

        case .contactSupport:
            return Alert(
                title: Text(error.title),
                message: Text(error.message),
                primaryButton: .default(Text("Contact Support")) {
                    // Open support email
                },
                secondaryButton: .cancel()
            )

        case .dismiss:
            return alert

        case .custom(let title, let action):
            return Alert(
                title: Text(error.title),
                message: Text(error.message),
                primaryButton: .default(Text(title)) {
                    action()
                },
                secondaryButton: .cancel()
            )
        }
    }
}
```

### Error Toast/Banner

```swift
struct ErrorBanner: View {
    let error: PPError
    @Binding var isShowing: Bool

    var body: some View {
        HStack(spacing: PPSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.ppError)

            VStack(alignment: .leading, spacing: PPSpacing.xxs) {
                Text(error.title)
                    .font(.ppLabelLarge)
                    .foregroundColor(.ppTextPrimary)

                Text(error.message)
                    .font(.ppCaption)
                    .foregroundColor(.ppTextSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: { isShowing = false }) {
                Image(systemName: "xmark")
                    .foregroundColor(.ppTextTertiary)
            }
        }
        .padding(PPSpacing.md)
        .background(Color.ppError.opacity(0.1))
        .cornerRadius(PPCornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: PPCornerRadius.sm)
                .stroke(Color.ppError, lineWidth: 1)
        )
        .padding(.horizontal, PPSpacing.md)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
```

### Error State View (Empty State)

```swift
struct ErrorStateView: View {
    let error: PPError
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: PPSpacing.lg) {
            Image(systemName: errorIcon)
                .font(.system(size: 60))
                .foregroundColor(.ppTextTertiary)

            VStack(spacing: PPSpacing.xs) {
                Text(error.title)
                    .font(.ppTitle2)
                    .foregroundColor(.ppTextPrimary)

                Text(error.message)
                    .font(.ppBody)
                    .foregroundColor(.ppTextSecondary)
                    .multilineTextAlignment(.center)
            }

            if let retryAction = retryAction {
                PPButton(title: "Try Again", action: retryAction)
                    .frame(width: 200)
            }
        }
        .padding(PPSpacing.xxl)
    }

    private var errorIcon: String {
        if error is NetworkError {
            return "wifi.slash"
        } else if error is DataError {
            return "exclamationmark.triangle"
        } else {
            return "xmark.circle"
        }
    }
}
```

## 🔄 Error Handling in ViewModels

### Standard Pattern

```swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var logs: [PoopLog] = []
    @Published var isLoading = false
    @Published var errorAlert: ErrorAlert?  // For alerts
    @Published var errorBanner: PPError?    // For banners

    private let fetchLogsUseCase: FetchPoopLogsUseCase

    func fetchLogs() async {
        isLoading = true
        defer { isLoading = false }

        do {
            logs = try await fetchLogsUseCase.execute(for: Date())
        } catch let error as PPError {
            handleError(error)
        } catch {
            handleError(SupabaseError.unknownError(error))
        }
    }

    private func handleError(_ error: PPError) {
        // Critical errors show as alerts
        if error is SyncError || error is SupabaseError {
            errorAlert = ErrorAlert(error: error)
        } else {
            // Minor errors show as banners
            errorBanner = error
        }

        // Log error for debugging
        logError(error)
    }

    private func logError(_ error: PPError) {
        print("❌ Error: \(error.title) - \(error.message)")
        // Send to analytics service (without PII)
    }
}
```

### Retry Logic

```swift
extension HomeViewModel {
    func retryLastAction() async {
        await fetchLogs()
    }

    func fetchLogsWithRetry(maxRetries: Int = 3) async {
        var attempts = 0

        while attempts < maxRetries {
            do {
                logs = try await fetchLogsUseCase.execute(for: Date())
                return  // Success
            } catch {
                attempts += 1

                if attempts >= maxRetries {
                    handleError(error as? PPError ?? SupabaseError.unknownError(error))
                } else {
                    // Exponential backoff
                    try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempts)) * 1_000_000_000))
                }
            }
        }
    }
}
```

## 🌐 Network Reachability

Monitor network status to provide better error handling:

```swift
import Network

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
```

### Usage in ViewModels

```swift
@MainActor
class HomeViewModel: ObservableObject {
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    func fetchLogs() async {
        guard networkMonitor.isConnected else {
            handleError(NetworkError.noConnection)
            return
        }

        // Proceed with network request
        // ...
    }
}
```

## 📝 Validation

### Input Validation

```swift
struct PoopLogValidator {
    static func validate(log: PoopLog) throws {
        // Validate duration
        guard log.durationSeconds > 0 && log.durationSeconds <= 7200 else {
            throw ValidationError.invalidDuration
        }

        // Validate consistency
        guard (1...7).contains(log.consistency) else {
            throw ValidationError.invalidConsistency
        }

        // Validate date
        guard log.loggedAt <= Date() else {
            throw ValidationError.dateTooFarInFuture
        }
    }

    static func validateRating(_ rating: String) -> Bool {
        ["great", "good", "okay", "bad", "terrible"].contains(rating)
    }
}
```

### Form Validation in ViewModels

```swift
@MainActor
class CreateLogViewModel: ObservableObject {
    @Published var durationSeconds: Int = 0
    @Published var selectedRating: Rating = .okay
    @Published var consistency: Int = 4
    @Published var notes: String = ""

    @Published var validationError: ValidationError?

    func validateForm() -> Bool {
        do {
            let log = PoopLog(
                id: UUID(),
                loggedAt: Date(),
                durationSeconds: durationSeconds,
                rating: selectedRating,
                consistency: consistency,
                notes: notes.isEmpty ? nil : notes
            )

            try PoopLogValidator.validate(log: log)
            validationError = nil
            return true

        } catch let error as ValidationError {
            validationError = error
            return false
        } catch {
            return false
        }
    }

    func saveLog() async {
        guard validateForm() else {
            return
        }

        // Proceed with save
    }
}
```

## 🧪 Error Testing

### Unit Tests

```swift
import XCTest
@testable import PoopyPals

class ErrorHandlingTests: XCTestCase {

    func testValidationError() {
        let error = ValidationError.invalidDuration

        XCTAssertEqual(error.title, "Invalid Input")
        XCTAssertFalse(error.message.isEmpty)
        XCTAssertNotNil(error.recoveryAction)
    }

    func testNetworkErrorRecovery() {
        let error = NetworkError.noConnection

        guard case .goOffline = error.recoveryAction else {
            XCTFail("Expected goOffline recovery action")
            return
        }
    }

    func testLogValidation() {
        let invalidLog = PoopLog(
            id: UUID(),
            loggedAt: Date().addingTimeInterval(3600),  // Future date
            durationSeconds: 120,
            rating: .okay,
            consistency: 4,
            notes: nil
        )

        XCTAssertThrowsError(try PoopLogValidator.validate(log: invalidLog)) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }
}
```

## 📊 Error Logging & Analytics

### Local Error Logger

```swift
class ErrorLogger {
    static let shared = ErrorLogger()

    private var errorLog: [ErrorEntry] = []

    struct ErrorEntry: Codable {
        let timestamp: Date
        let errorTitle: String
        let errorMessage: String
        let errorType: String
    }

    func log(_ error: PPError) {
        let entry = ErrorEntry(
            timestamp: Date(),
            errorTitle: error.title,
            errorMessage: error.message,
            errorType: String(describing: type(of: error))
        )

        errorLog.append(entry)

        // Keep only last 100 errors
        if errorLog.count > 100 {
            errorLog.removeFirst()
        }

        // Persist to disk
        saveErrorLog()

        // Print for debugging
        #if DEBUG
        print("🔴 ERROR LOGGED: \(entry.errorTitle) - \(entry.errorMessage)")
        #endif
    }

    private func saveErrorLog() {
        // Save to UserDefaults or file
        if let encoded = try? JSONEncoder().encode(errorLog) {
            UserDefaults.standard.set(encoded, forKey: "errorLog")
        }
    }

    func getRecentErrors(limit: Int = 10) -> [ErrorEntry] {
        Array(errorLog.suffix(limit))
    }
}
```

## 🎯 Best Practices

1. **Always catch errors** - Never let errors crash the app
2. **Provide context** - Tell users what went wrong and why
3. **Offer solutions** - Give recovery actions when possible
4. **Test error paths** - Test both success and failure scenarios
5. **Log errors** - Track errors for debugging (no PII)
6. **Graceful degradation** - App should work offline
7. **User-friendly messages** - Avoid technical jargon
8. **Retry intelligently** - Use exponential backoff
9. **Validate early** - Catch errors before they reach the backend
10. **Monitor network** - Check connectivity before requests

## 📚 Related Documentation

- [Supabase Integration](./05-supabase-integration.md)
- [Architecture](./02-architecture.md)
- [Data Flow](./08-data-flow.md)

---

**Last Updated:** 2025-11-11
**Version:** 1.0.0
