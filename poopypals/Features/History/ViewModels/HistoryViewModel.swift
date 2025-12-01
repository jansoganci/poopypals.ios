//
//  HistoryViewModel.swift
//  PoopyPals
//
//  History Screen - ViewModel
//

import Foundation
import SwiftUI

@MainActor
class HistoryViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published var logs: [PoopLog] = []
    @Published var selectedDate: Date = Date()
    @Published var selectedLog: PoopLog?
    @Published var isLoading = false
    @Published var errorAlert: ErrorAlert?
    
    // MARK: - Dependencies
    
    private let fetchPoopLogsUseCase: FetchPoopLogsUseCaseProtocol
    
    // MARK: - Initialization
    
    init(fetchPoopLogsUseCase: FetchPoopLogsUseCaseProtocol? = nil) {
        let container = AppContainer.shared
        self.fetchPoopLogsUseCase = fetchPoopLogsUseCase ?? container.fetchPoopLogsUseCase
        
        Task {
            await loadLogs()
        }
    }
    
    // MARK: - Public Methods
    
    func loadLogs() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            logs = try await fetchPoopLogsUseCase.execute(limit: 500, offset: 0)
        } catch {
            errorAlert = ErrorAlert(
                title: "Error Loading History",
                message: error.localizedDescription
            )
        }
    }
    
    // MARK: - Computed Properties
    
    var logsByDate: [Date: [PoopLog]] {
        Dictionary(grouping: logs) { log in
            Calendar.current.startOfDay(for: log.loggedAt)
        }
    }
    
    var sortedDates: [Date] {
        logsByDate.keys.sorted(by: >)
    }
    
    func logsForDate(_ date: Date) -> [PoopLog] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return logsByDate[dayStart] ?? []
    }
    
    var hasLogsForSelectedDate: Bool {
        !logsForDate(selectedDate).isEmpty
    }
}

