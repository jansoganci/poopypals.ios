//
//  RetryUtility.swift
//  PoopyPals
//
//  Retry logic with exponential backoff
//

import Foundation

enum RetryUtility {
    /// Retry an operation with exponential backoff
    /// - Parameters:
    ///   - maxRetries: Maximum number of retry attempts (default: 3)
    ///   - operation: The async throwing operation to retry
    /// - Returns: Result of the operation
    /// - Throws: Last error if all retries fail
    static func retry<T>(
        maxRetries: Int = 3,
        operation: () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                // Don't wait after last attempt
                if attempt < maxRetries - 1 {
                    let delay = pow(2.0, Double(attempt)) // Exponential backoff: 1s, 2s, 4s
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? DataError.syncError("Unknown error after \(maxRetries) retries")
    }
}

