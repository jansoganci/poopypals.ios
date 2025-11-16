---
name: mvvm-pattern
description: Expert at implementing MVVM + Clean Architecture pattern in PoopyPals. Use when creating ViewModels, use cases, repositories, or implementing data flow. Specializes in @MainActor, @Published state, and dependency injection.
---

# MVVM Pattern Implementation

Expert skill for implementing MVVM + Clean Architecture following PoopyPals architectural guidelines.

## When to Use This Skill

- Creating new ViewModels for features
- Implementing use cases (business logic)
- Building repositories (data access layer)
- Setting up dependency injection
- Refactoring code to follow MVVM
- Debugging data flow issues

## Architecture Layers

### Presentation Layer (Features/)

**Views (SwiftUI)**
- Pure declarative UI
- No business logic
- Bind to ViewModel via @StateObject/@ObservedObject
- Handle user interactions by calling ViewModel methods

**ViewModels**
- Always annotated with @MainActor
- Use @Published for state that drives UI
- Contain presentation logic only
- Call use cases for business operations
- Handle error presentation

### Domain Layer (Domain/)

**Entities**
- Business models (PoopLog, Achievement, etc.)
- Immutable structs
- Pure Swift (no UIKit/SwiftUI)
- Located in `Domain/Entities/`

**Use Cases**
- Single responsibility business operations
- Pure business logic
- Call repository protocols
- Located in `Domain/UseCases/`

### Data Layer (Data/)

**Repositories**
- Implement repository protocols
- Coordinate between data sources
- Handle data transformation (DTO ↔ Domain)
- Manage caching and sync logic

**Data Sources**
- Direct API/database access
- Remote (Supabase) and Local (Keychain, UserDefaults)

## ViewModel Template

```swift
import Foundation
import Combine

@MainActor
class FeatureViewModel: ObservableObject {
    // MARK: - Published State
    @Published var items: [ItemType] = []
    @Published var isLoading = false
    @Published var errorAlert: ErrorAlert?
    @Published var searchQuery = ""

    // MARK: - Dependencies (private)
    private let fetchItemsUseCase: FetchItemsUseCase
    private let createItemUseCase: CreateItemUseCase

    // MARK: - Private State
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var filteredItems: [ItemType] {
        guard !searchQuery.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - Initialization
    init(
        fetchItemsUseCase: FetchItemsUseCase,
        createItemUseCase: CreateItemUseCase
    ) {
        self.fetchItemsUseCase = fetchItemsUseCase
        self.createItemUseCase = createItemUseCase

        setupBindings()
    }

    // MARK: - Public Methods
    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await fetchItemsUseCase.execute()
        } catch {
            handleError(error)
        }
    }

    func createItem(name: String) async {
        guard !name.isEmpty else {
            errorAlert = ErrorAlert(
                title: "Invalid Input",
                message: "Name cannot be empty"
            )
            return
        }

        do {
            let newItem = try await createItemUseCase.execute(name: name)
            items.insert(newItem, at: 0)
            HapticManager.shared.success()
        } catch {
            handleError(error)
        }
    }

    func refresh() async {
        await loadData()
    }

    // MARK: - Private Methods
    private func setupBindings() {
        // Setup any Combine subscriptions here
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.performSearch(query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(_ query: String) {
        // Search logic
    }

    private func handleError(_ error: Error) {
        if let ppError = error as? PPError {
            errorAlert = ErrorAlert(error: ppError)
        } else {
            errorAlert = ErrorAlert(
                title: "Error",
                message: error.localizedDescription
            )
        }
        HapticManager.shared.error()
    }
}
```

## Use Case Template

```swift
import Foundation

/// Describes what this use case does
///
/// Example usage:
/// ```swift
/// let items = try await useCase.execute(param: value)
/// ```
protocol FetchItemsUseCaseProtocol {
    func execute(filter: FilterType?) async throws -> [ItemType]
}

class FetchItemsUseCase: FetchItemsUseCaseProtocol {
    // MARK: - Dependencies
    private let repository: ItemRepositoryProtocol

    // MARK: - Initialization
    init(repository: ItemRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    func execute(filter: FilterType? = nil) async throws -> [ItemType] {
        // 1. Validate inputs
        guard let filter = filter else {
            return try await repository.fetchAll()
        }

        // 2. Perform business logic
        let allItems = try await repository.fetchAll()
        let filteredItems = applyBusinessRules(to: allItems, with: filter)

        // 3. Return result
        return filteredItems
    }

    // MARK: - Private Helpers
    private func applyBusinessRules(to items: [ItemType], with filter: FilterType) -> [ItemType] {
        // Business logic here
        return items
    }
}
```

## Repository Template

```swift
import Foundation

/// Repository protocol defining data access contract
protocol ItemRepositoryProtocol {
    func fetchAll() async throws -> [ItemType]
    func fetch(id: UUID) async throws -> ItemType?
    func create(_ item: ItemType) async throws -> ItemType
    func update(_ item: ItemType) async throws -> ItemType
    func delete(id: UUID) async throws
}

class ItemRepository: ItemRepositoryProtocol {
    // MARK: - Dependencies
    private let remoteDataSource: RemoteItemDataSource
    private let localDataSource: LocalItemDataSource
    private let deviceService: DeviceIdentificationService

    // MARK: - Initialization
    init(
        remoteDataSource: RemoteItemDataSource,
        localDataSource: LocalItemDataSource,
        deviceService: DeviceIdentificationService
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.deviceService = deviceService
    }

    // MARK: - Public Methods
    func fetchAll() async throws -> [ItemType] {
        let deviceId = try await deviceService.getDeviceId()

        do {
            // Try remote first
            let items = try await remoteDataSource.fetchItems(for: deviceId)
            // Cache locally
            try await localDataSource.saveItems(items)
            return items
        } catch {
            // Fallback to local cache
            return try await localDataSource.fetchItems()
        }
    }

    func create(_ item: ItemType) async throws -> ItemType {
        let deviceId = try await deviceService.getDeviceId()

        // Save locally first (optimistic update)
        try await localDataSource.saveItem(item)

        do {
            // Sync to remote
            let remoteItem = try await remoteDataSource.createItem(item, deviceId: deviceId)
            // Update local with server response
            try await localDataSource.updateItem(remoteItem)
            return remoteItem
        } catch {
            // If remote fails, keep local copy
            // Mark for sync later
            try await localDataSource.markForSync(item.id)
            return item
        }
    }

    func update(_ item: ItemType) async throws -> ItemType {
        let deviceId = try await deviceService.getDeviceId()

        // Update locally first
        try await localDataSource.updateItem(item)

        do {
            // Sync to remote
            return try await remoteDataSource.updateItem(item, deviceId: deviceId)
        } catch {
            // Mark for sync later
            try await localDataSource.markForSync(item.id)
            throw error
        }
    }

    func delete(id: UUID) async throws {
        let deviceId = try await deviceService.getDeviceId()

        // Delete locally first
        try await localDataSource.deleteItem(id: id)

        do {
            // Sync to remote
            try await remoteDataSource.deleteItem(id: id, deviceId: deviceId)
        } catch {
            // If remote fails, it's already deleted locally
            // This is acceptable for delete operations
        }
    }
}
```

## Data Flow Pattern

### User Action → ViewModel → UseCase → Repository → DataSource

```swift
// 1. View triggers action
Button("Save") {
    Task {
        await viewModel.save()
    }
}

// 2. ViewModel calls use case
@MainActor
class MyViewModel: ObservableObject {
    func save() async {
        do {
            let item = try await createItemUseCase.execute(name: itemName)
            items.append(item)
        } catch {
            handleError(error)
        }
    }
}

// 3. UseCase executes business logic
class CreateItemUseCase {
    func execute(name: String) async throws -> Item {
        // Validate
        guard !name.isEmpty else {
            throw ValidationError.emptyName
        }

        // Create entity
        let item = Item(id: UUID(), name: name, createdAt: Date())

        // Save via repository
        return try await repository.create(item)
    }
}

// 4. Repository coordinates data sources
class ItemRepository {
    func create(_ item: Item) async throws -> Item {
        let deviceId = try await deviceService.getDeviceId()
        return try await remoteDataSource.createItem(item, deviceId: deviceId)
    }
}

// 5. DataSource calls backend
class SupabaseItemDataSource {
    func createItem(_ item: Item, deviceId: UUID) async throws -> Item {
        let dto = item.toDTO(deviceId: deviceId)
        let response = try await client.from("items").insert(dto).execute()
        return try DTO.toDomain(response)
    }
}
```

## Dependency Injection

### Container Pattern

```swift
// Core/DI/DependencyContainer.swift
class DependencyContainer {
    // MARK: - Singletons
    static let shared = DependencyContainer()

    // MARK: - Services
    lazy var supabaseClient: SupabaseClient = {
        // Initialize Supabase
        return SupabaseClient(/* config */)
    }()

    lazy var deviceService: DeviceIdentificationService = {
        return DeviceIdentificationService()
    }()

    // MARK: - Data Sources
    func makeItemDataSource() -> RemoteItemDataSource {
        return SupabaseItemDataSource(client: supabaseClient)
    }

    // MARK: - Repositories
    func makeItemRepository() -> ItemRepositoryProtocol {
        return ItemRepository(
            remoteDataSource: makeItemDataSource(),
            localDataSource: LocalItemDataSource(),
            deviceService: deviceService
        )
    }

    // MARK: - Use Cases
    func makeFetchItemsUseCase() -> FetchItemsUseCase {
        return FetchItemsUseCase(repository: makeItemRepository())
    }

    func makeCreateItemUseCase() -> CreateItemUseCase {
        return CreateItemUseCase(repository: makeItemRepository())
    }

    // MARK: - ViewModels
    func makeItemViewModel() -> ItemViewModel {
        return ItemViewModel(
            fetchItemsUseCase: makeFetchItemsUseCase(),
            createItemUseCase: makeCreateItemUseCase()
        )
    }
}
```

### View Injection

```swift
struct ItemView: View {
    @StateObject private var viewModel: ItemViewModel

    init(container: DependencyContainer = .shared) {
        _viewModel = StateObject(wrappedValue: container.makeItemViewModel())
    }

    var body: some View {
        // View implementation
    }
}
```

## Best Practices

### 1. ViewModels

- ✅ Always use @MainActor
- ✅ Use @Published for UI-driving state only
- ✅ Inject dependencies via initializer
- ✅ Keep ViewModels focused (single feature)
- ✅ Use async/await for async operations
- ❌ Don't access UI from ViewModel
- ❌ Don't make ViewModels too large (>300 lines)

### 2. Use Cases

- ✅ Single responsibility (one business operation)
- ✅ Keep them small (<100 lines)
- ✅ Use protocol for testability
- ✅ Focus on business logic only
- ❌ Don't access UI or presentation logic
- ❌ Don't call multiple repositories (compose use cases instead)

### 3. Repositories

- ✅ Implement repository protocol
- ✅ Coordinate between data sources
- ✅ Handle offline scenarios
- ✅ Transform DTOs to domain entities
- ❌ Don't include business logic (belongs in use cases)
- ❌ Don't expose DTOs (return domain entities)

## Common Patterns

### Loading State

```swift
@MainActor
class MyViewModel: ObservableObject {
    @Published var isLoading = false

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await fetchUseCase.execute()
        } catch {
            handleError(error)
        }
    }
}
```

### Pagination

```swift
@MainActor
class MyViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoadingMore = false
    private var currentPage = 0
    private var hasMorePages = true

    func loadMore() async {
        guard !isLoadingMore && hasMorePages else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let newItems = try await fetchUseCase.execute(
                page: currentPage,
                pageSize: 30
            )

            items.append(contentsOf: newItems)
            currentPage += 1
            hasMorePages = newItems.count == 30
        } catch {
            handleError(error)
        }
    }
}
```

### Search with Debounce

```swift
@Published var searchQuery = ""

private func setupBindings() {
    $searchQuery
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .removeDuplicates()
        .sink { [weak self] query in
            Task { await self?.performSearch(query) }
        }
        .store(in: &cancellables)
}
```

## Checklist

- [ ] ViewModel annotated with @MainActor
- [ ] Dependencies injected via initializer
- [ ] Use protocol-oriented design
- [ ] Use cases have single responsibility
- [ ] Repository implements protocol
- [ ] Error handling implemented
- [ ] Loading states managed
- [ ] No business logic in Views
- [ ] No UI access in ViewModels/UseCases/Repositories
- [ ] DTOs converted to domain entities
- [ ] Tests written for ViewModels and UseCases

## References

- Architecture guide: `docs/02-architecture.md`
- Error handling: `docs/07-error-handling.md`
- Existing ViewModels: `Features/*/ViewModels/`
- Existing use cases: `Domain/UseCases/`
