---
name: ios-testing
description: Expert at writing comprehensive iOS tests using XCTest. Use when writing unit tests for ViewModels, use cases, repositories, or UI tests for critical flows. Specializes in async testing, mocking, and test organization.
---

# iOS Testing

Expert skill for writing comprehensive, maintainable tests for PoopyPals iOS using XCTest framework.

## When to Use This Skill

- Writing unit tests for ViewModels
- Testing use cases and business logic
- Creating mock implementations
- Writing UI tests for critical flows
- Debugging failing tests
- Setting up test infrastructure

## Testing Strategy

### Testing Pyramid

```
        /\
       /UI\       10% - Critical user flows only
      /----\
     / Intg \     20% - Feature integration
    /--------\
   /   Unit   \   70% - ViewModels, UseCases, Utilities
  /____________\
```

### What to Test

**High Priority (Must Test):**
- ViewModels (state changes, error handling)
- Use cases (business logic, validation)
- Data transformations (DTO ↔ Domain)
- Utilities (streak calculation, validation)

**Medium Priority (Should Test):**
- Repositories (data source coordination)
- Error handling flows
- Computed properties with logic

**Low Priority (Nice to Have):**
- Simple getters/setters
- SwiftUI view rendering (use previews instead)

## Unit Testing ViewModels

### ViewModel Test Template

```swift
import XCTest
@testable import poopypals

@MainActor
final class HomeViewModelTests: XCTestCase {
    // MARK: - System Under Test
    var sut: HomeViewModel!

    // MARK: - Dependencies (Mocks)
    var mockFetchLogsUseCase: MockFetchLogsUseCase!
    var mockCreateLogUseCase: MockCreateLogUseCase!
    var mockCalculateStreakUseCase: MockCalculateStreakUseCase!

    // MARK: - Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()

        // Create mocks
        mockFetchLogsUseCase = MockFetchLogsUseCase()
        mockCreateLogUseCase = MockCreateLogUseCase()
        mockCalculateStreakUseCase = MockCalculateStreakUseCase()

        // Create SUT with injected mocks
        sut = HomeViewModel(
            fetchLogsUseCase: mockFetchLogsUseCase,
            createLogUseCase: mockCreateLogUseCase,
            calculateStreakUseCase: mockCalculateStreakUseCase
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockFetchLogsUseCase = nil
        mockCreateLogUseCase = nil
        mockCalculateStreakUseCase = nil

        try await super.tearDown()
    }

    // MARK: - Tests: Initial State
    func testInitialState() {
        // Then
        XCTAssertTrue(sut.logs.isEmpty)
        XCTAssertEqual(sut.streakCount, 0)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorAlert)
    }

    // MARK: - Tests: Load Data
    func testLoadData_Success_UpdatesLogs() async {
        // Given
        let expectedLogs = [
            PoopLog.mock(rating: .great),
            PoopLog.mock(rating: .good)
        ]
        mockFetchLogsUseCase.logsToReturn = expectedLogs

        // When
        await sut.loadData()

        // Then
        XCTAssertEqual(sut.logs, expectedLogs)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorAlert)
    }

    func testLoadData_Failure_ShowsError() async {
        // Given
        mockFetchLogsUseCase.shouldThrowError = true
        mockFetchLogsUseCase.errorToThrow = NetworkError.noConnection

        // When
        await sut.loadData()

        // Then
        XCTAssertTrue(sut.logs.isEmpty)
        XCTAssertNotNil(sut.errorAlert)
        XCTAssertEqual(sut.errorAlert?.title, "Connection Error")
    }

    func testLoadData_SetsLoadingState() async {
        // Given
        mockFetchLogsUseCase.delay = 0.1

        // When
        let expectation = expectation(description: "Loading state set")

        Task {
            await sut.loadData()
            expectation.fulfill()
        }

        // Then - Check loading is true during execution
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
        XCTAssertTrue(sut.isLoading)

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Tests: Quick Log
    func testQuickLog_Success_AddsLogToList() async {
        // Given
        let newLog = PoopLog.mock(rating: .great)
        mockCreateLogUseCase.logToReturn = newLog

        // When
        await sut.quickLog(rating: .great)

        // Then
        XCTAssertTrue(sut.logs.contains(where: { $0.id == newLog.id }))
        XCTAssertNil(sut.errorAlert)
    }

    func testQuickLog_Success_UpdatesStreak() async {
        // Given
        mockCreateLogUseCase.logToReturn = PoopLog.mock()
        mockCalculateStreakUseCase.streakToReturn = 5

        // When
        await sut.quickLog(rating: .great)

        // Then
        XCTAssertEqual(sut.streakCount, 5)
    }

    // MARK: - Tests: Computed Properties
    func testTodayLogs_ReturnsOnlyTodayLogs() async {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        sut.logs = [
            PoopLog.mock(loggedAt: today),
            PoopLog.mock(loggedAt: yesterday),
            PoopLog.mock(loggedAt: today)
        ]

        // When
        let todayLogs = sut.todayLogs

        // Then
        XCTAssertEqual(todayLogs.count, 2)
        XCTAssertTrue(todayLogs.allSatisfy { Calendar.current.isDateInToday($0.loggedAt) })
    }
}
```

## Mock Implementations

### Mock Use Case Template

```swift
class MockFetchLogsUseCase: FetchLogsUseCaseProtocol {
    // MARK: - Mock Configuration
    var logsToReturn: [PoopLog] = []
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.noConnection
    var delay: TimeInterval = 0
    var executeCallCount = 0

    // MARK: - Mock Implementation
    func execute() async throws -> [PoopLog] {
        executeCallCount += 1

        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        if shouldThrowError {
            throw errorToThrow
        }

        return logsToReturn
    }

    // MARK: - Verification Helpers
    func verify_ExecuteCalled(times: Int = 1, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(executeCallCount, times, "Expected execute to be called \(times) times", file: file, line: line)
    }

    func reset() {
        logsToReturn = []
        shouldThrowError = false
        errorToThrow = NetworkError.noConnection
        delay = 0
        executeCallCount = 0
    }
}
```

### Mock Repository Template

```swift
class MockPoopLogRepository: PoopLogRepositoryProtocol {
    // MARK: - Mock Data
    var logsToReturn: [PoopLog] = []
    var logToReturn: PoopLog?
    var shouldThrowError = false
    var errorToThrow: Error = RepositoryError.fetchFailed

    // MARK: - Call Tracking
    var fetchAllCallCount = 0
    var createCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0

    // MARK: - Mock Implementation
    func fetchAll() async throws -> [PoopLog] {
        fetchAllCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        return logsToReturn
    }

    func create(_ log: PoopLog) async throws -> PoopLog {
        createCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        return logToReturn ?? log
    }

    func update(_ log: PoopLog) async throws -> PoopLog {
        updateCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        return logToReturn ?? log
    }

    func delete(id: UUID) async throws {
        deleteCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }
    }
}
```

## Testing Use Cases

```swift
final class CreatePoopLogUseCaseTests: XCTestCase {
    var sut: CreatePoopLogUseCase!
    var mockRepository: MockPoopLogRepository!

    override func setUp() {
        mockRepository = MockPoopLogRepository()
        sut = CreatePoopLogUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
    }

    func testExecute_ValidInput_CreatesLog() async throws {
        // Given
        let rating = PoopLog.Rating.great
        let duration = 180
        let expectedLog = PoopLog.mock(rating: rating, durationSeconds: duration)
        mockRepository.logToReturn = expectedLog

        // When
        let result = try await sut.execute(
            rating: rating,
            durationSeconds: duration,
            consistency: 4,
            notes: "Test note"
        )

        // Then
        XCTAssertEqual(result.id, expectedLog.id)
        XCTAssertEqual(result.rating, rating)
        XCTAssertEqual(mockRepository.createCallCount, 1)
    }

    func testExecute_CalculatesFlushFunds() async throws {
        // Given
        let rating = PoopLog.Rating.great

        // When
        let result = try await sut.execute(rating: rating, durationSeconds: 120)

        // Then
        XCTAssertEqual(result.flushFundsEarned, 10) // Great rating = 10 funds
    }

    func testExecute_InvalidDuration_ThrowsError() async {
        // Given
        let invalidDuration = -10

        // When/Then
        do {
            _ = try await sut.execute(rating: .good, durationSeconds: invalidDuration)
            XCTFail("Expected error to be thrown")
        } catch let error as ValidationError {
            XCTAssertEqual(error, ValidationError.invalidDuration)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
```

## Testing Async Code

### Test Async Functions

```swift
func testAsyncFunction() async throws {
    // Arrange
    let expected = "result"

    // Act
    let actual = try await sut.performAsyncOperation()

    // Assert
    XCTAssertEqual(actual, expected)
}
```

### Test with Expectations

```swift
func testAsyncCallback() {
    // Given
    let expectation = expectation(description: "Callback called")
    var result: String?

    // When
    sut.performOperation { value in
        result = value
        expectation.fulfill()
    }

    // Then
    wait(for: [expectation], timeout: 1.0)
    XCTAssertEqual(result, "expected")
}
```

### Test Publishers (Combine)

```swift
func testPublisher() {
    // Given
    var cancellables = Set<AnyCancellable>()
    let expectation = expectation(description: "Publisher emits")
    var receivedValue: String?

    // When
    sut.publisher
        .sink { value in
            receivedValue = value
            expectation.fulfill()
        }
        .store(in: &cancellables)

    sut.triggerPublisher()

    // Then
    wait(for: [expectation], timeout: 1.0)
    XCTAssertEqual(receivedValue, "expected")
}
```

## UI Testing

### UI Test Template

```swift
import XCTest

final class HomeScreenUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testQuickLogFlow() {
        // Given - Home screen is visible
        XCTAssertTrue(app.staticTexts["Welcome"].exists)

        // When - Tap quick log button
        let quickLogButton = app.buttons["Quick Log"]
        XCTAssertTrue(quickLogButton.exists)
        quickLogButton.tap()

        // Then - Rating selection appears
        let greatButton = app.buttons["Great"]
        XCTAssertTrue(greatButton.waitForExistence(timeout: 2))

        // When - Select rating
        greatButton.tap()

        // Then - Success state shown
        let successMessage = app.staticTexts["Log saved!"]
        XCTAssertTrue(successMessage.waitForExistence(timeout: 2))
    }

    func testStreakDisplay() {
        // Given
        let streakLabel = app.staticTexts["streakCount"]

        // Then
        XCTAssertTrue(streakLabel.exists)
        XCTAssertTrue(streakLabel.label.contains("day"))
    }
}
```

## Test Helpers

### Mock Data Factories

```swift
extension PoopLog {
    static func mock(
        id: UUID = UUID(),
        loggedAt: Date = Date(),
        durationSeconds: Int = 120,
        rating: Rating = .good,
        consistency: Int? = 4,
        notes: String? = nil,
        flushFundsEarned: Int = 5
    ) -> PoopLog {
        PoopLog(
            id: id,
            loggedAt: loggedAt,
            durationSeconds: durationSeconds,
            rating: rating,
            consistency: consistency,
            notes: notes,
            flushFundsEarned: flushFundsEarned
        )
    }

    static func mockArray(count: Int, rating: Rating = .good) -> [PoopLog] {
        (0..<count).map { index in
            mock(
                loggedAt: Date().addingTimeInterval(TimeInterval(-index * 86400)),
                rating: rating
            )
        }
    }
}
```

### Custom Assertions

```swift
func XCTAssertThrowsError<T, E: Error>(
    _ expression: @autoclosure () async throws -> T,
    _ expectedError: E,
    file: StaticString = #file,
    line: UInt = #line
) async where E: Equatable {
    do {
        _ = try await expression()
        XCTFail("Expected error to be thrown", file: file, line: line)
    } catch let error as E {
        XCTAssertEqual(error, expectedError, file: file, line: line)
    } catch {
        XCTFail("Unexpected error type: \(error)", file: file, line: line)
    }
}
```

## Best Practices

### Test Naming

```swift
// Pattern: test_[MethodName]_[Scenario]_[ExpectedResult]
func testLoadData_Success_UpdatesLogs() async { }
func testLoadData_NetworkError_ShowsAlert() async { }
func testQuickLog_InvalidInput_ThrowsValidationError() async { }
```

### AAA Pattern (Arrange, Act, Assert)

```swift
func testExample() async {
    // Arrange (Given)
    let input = "test"
    mockUseCase.resultToReturn = "expected"

    // Act (When)
    let result = await sut.performAction(input)

    // Assert (Then)
    XCTAssertEqual(result, "expected")
}
```

### One Assertion Per Test (Ideal)

```swift
// ✅ GOOD - Tests one thing
func testLoadData_UpdatesLogs() async {
    await sut.loadData()
    XCTAssertEqual(sut.logs.count, 2)
}

func testLoadData_ResetsLoadingState() async {
    await sut.loadData()
    XCTAssertFalse(sut.isLoading)
}

// ❌ AVOID - Tests multiple things
func testLoadData() async {
    await sut.loadData()
    XCTAssertEqual(sut.logs.count, 2)
    XCTAssertFalse(sut.isLoading)
    XCTAssertNil(sut.errorAlert)
}
```

## Test Organization

```
Tests/
├── UnitTests/
│   ├── Presentation/
│   │   └── ViewModels/
│   │       └── HomeViewModelTests.swift
│   ├── Domain/
│   │   ├── UseCases/
│   │   │   └── CreatePoopLogUseCaseTests.swift
│   │   └── Entities/
│   │       └── PoopLogTests.swift
│   ├── Data/
│   │   └── Repositories/
│   │       └── PoopLogRepositoryTests.swift
│   └── Mocks/
│       ├── MockUseCases.swift
│       ├── MockRepositories.swift
│       └── MockDataFactories.swift
└── UITests/
    └── CriticalFlows/
        ├── QuickLogFlowTests.swift
        └── StreakTrackingTests.swift
```

## Checklist

- [ ] Tests follow naming convention (test_method_scenario_result)
- [ ] Use AAA pattern (Arrange, Act, Assert)
- [ ] Mock all external dependencies
- [ ] Test success and error paths
- [ ] Test edge cases and validation
- [ ] Async tests use async/await
- [ ] UI tests only for critical flows
- [ ] Tests are independent (no shared state)
- [ ] Use mock data factories
- [ ] Tests run fast (<0.1s per unit test)

## References

- Architecture guide: `docs/02-architecture.md`
- Existing tests: `Tests/`
- XCTest documentation: Apple Developer Docs
