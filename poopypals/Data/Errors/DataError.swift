//
//  DataError.swift
//  PoopyPals
//
//  Data layer error types
//

import Foundation

enum DataError: LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case encodingError(Error)
    case notFound
    case unauthorized
    case syncError(String)
    case invalidData
    case deviceNotRegistered
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .notFound:
            return "Resource not found"
        case .unauthorized:
            return "Unauthorized access"
        case .syncError(let message):
            return "Sync error: \(message)"
        case .invalidData:
            return "Invalid data format"
        case .deviceNotRegistered:
            return "Device not registered"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .networkError:
            return "Unable to connect to server"
        case .decodingError:
            return "Data format mismatch"
        case .encodingError:
            return "Unable to serialize data"
        case .notFound:
            return "The requested resource does not exist"
        case .unauthorized:
            return "Access denied"
        case .syncError:
            return "Failed to synchronize data"
        case .invalidData:
            return "Data validation failed"
        case .deviceNotRegistered:
            return "Device needs to be registered first"
        }
    }
}

