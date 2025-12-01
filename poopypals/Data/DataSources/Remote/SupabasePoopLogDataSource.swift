//
//  SupabasePoopLogDataSource.swift
//  PoopyPals
//
//  Remote data source for PoopLog (Supabase)
//

import Foundation
import Supabase

protocol RemotePoopLogDataSourceProtocol {
    func fetchLogs(deviceId: UUID, limit: Int, offset: Int) async throws -> [PoopLogDTO]
    func fetchTodayLogs(deviceId: UUID) async throws -> [PoopLogDTO]
    func fetchLog(deviceId: UUID, id: UUID) async throws -> PoopLogDTO
    func createLog(deviceId: UUID, log: PoopLogDTO) async throws -> PoopLogDTO
    func updateLog(deviceId: UUID, log: PoopLogDTO) async throws -> PoopLogDTO
    func deleteLog(deviceId: UUID, id: UUID) async throws
}

class SupabasePoopLogDataSource: RemotePoopLogDataSourceProtocol {
    private let supabaseService: SupabaseService
    private let deviceService: DeviceIdentificationService
    
    init(
        supabaseService: SupabaseService? = nil,
        deviceService: DeviceIdentificationService = DeviceIdentificationService()
    ) {
        let service = supabaseService ?? SupabaseService.shared
        self.supabaseService = service
        self.deviceService = deviceService
    }
    
    // MARK: - Fetch Operations
    
    func fetchLogs(deviceId: UUID, limit: Int = 30, offset: Int = 0) async throws -> [PoopLogDTO] {
        BackendLogger.shared.logRequest(method: "GET", table: "poop_logs", action: "fetchLogs")
        do {
            struct FetchLogsParams: Encodable {
                let p_device_id: String
                let p_limit: Int
                let p_offset: Int
            }
            
            let params = FetchLogsParams(
                p_device_id: deviceId.uuidString,
                p_limit: limit,
                p_offset: offset
            )
            
            let response = try await supabaseService.client.rpc(
                "fetch_poop_logs",
                params: params
            ).execute()
            
            // Decode JSONB array response
            let jsonArray = try JSONDecoder().decode([PoopLogDTO].self, from: response.data)
            BackendLogger.shared.logResponse(table: "poop_logs", success: true, count: jsonArray.count)
            return jsonArray
        } catch {
            BackendLogger.shared.logError(error, context: "fetchLogs")
            throw DataError.networkError(error)
        }
    }
    
    func fetchTodayLogs(deviceId: UUID) async throws -> [PoopLogDTO] {
        do {
            struct FetchTodayLogsParams: Encodable {
                let p_device_id: String
            }
            
            let params = FetchTodayLogsParams(p_device_id: deviceId.uuidString)
            
            let response = try await supabaseService.client.rpc(
                "fetch_today_logs",
                params: params
            ).execute()
            
            // Decode JSONB array response
            let jsonArray = try JSONDecoder().decode([PoopLogDTO].self, from: response.data)
            return jsonArray
        } catch {
            throw DataError.networkError(error)
        }
    }
    
    func fetchLog(deviceId: UUID, id: UUID) async throws -> PoopLogDTO {
        do {
            struct FetchLogParams: Encodable {
                let p_device_id: String
                let p_log_id: String
            }
            
            let params = FetchLogParams(
                p_device_id: deviceId.uuidString,
                p_log_id: id.uuidString
            )
            
            let response = try await supabaseService.client.rpc(
                "fetch_poop_log",
                params: params
            ).execute()
            
            // Decode JSONB object response
            let dto = try JSONDecoder().decode(PoopLogDTO.self, from: response.data)
            return dto
        } catch {
            if let error = error as? DataError {
                throw error
            }
            throw DataError.networkError(error)
        }
    }
    
    // MARK: - Create Operations
    
    func createLog(deviceId: UUID, log: PoopLogDTO) async throws -> PoopLogDTO {
        BackendLogger.shared.logRequest(method: "POST", table: "poop_logs", action: "createLog")
        do {
            // Encode log to JSON, then convert to dictionary for JSONB
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let logData = try encoder.encode(log)
            let logDict = try JSONSerialization.jsonObject(with: logData) as? [String: Any] ?? [:]
            
            // Convert to snake_case for JSONB
            var snakeCaseDict: [String: Any] = [:]
            for (key, value) in logDict {
                let snakeKey = camelToSnake(key)
                snakeCaseDict[snakeKey] = value
            }
            
            // Encode dictionary as JSON string for RPC
            let jsonData = try JSONSerialization.data(withJSONObject: snakeCaseDict, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            
            struct CreateLogParams: Encodable {
                let p_device_id: String
                let p_log_data: String
            }
            
            let params = CreateLogParams(
                p_device_id: deviceId.uuidString,
                p_log_data: jsonString
            )
            
            let response = try await supabaseService.client.rpc(
                "create_poop_log",
                params: params
            ).execute()
            
            // Decode JSONB object response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let dto = try decoder.decode(PoopLogDTO.self, from: response.data)
            BackendLogger.shared.logResponse(table: "poop_logs", success: true, count: 1)
            return dto
        } catch {
            BackendLogger.shared.logError(error, context: "createLog")
            throw DataError.networkError(error)
        }
    }
    
    // MARK: - Update Operations
    
    func updateLog(deviceId: UUID, log: PoopLogDTO) async throws -> PoopLogDTO {
        guard let id = log.id else {
            throw DataError.invalidData
        }
        
        do {
            // Create update payload without id and device_id
            let updatePayload = PoopLogDTO(
                id: nil,
                deviceId: nil,
                loggedAt: log.loggedAt,
                durationSeconds: log.durationSeconds,
                rating: log.rating,
                consistency: log.consistency,
                notes: log.notes,
                flushFundsEarned: log.flushFundsEarned,
                isStreakCounted: log.isStreakCounted,
                localId: log.localId,
                isDeleted: log.isDeleted,
                syncedAt: log.syncedAt,
                createdAt: log.createdAt,
                updatedAt: log.updatedAt
            )
            
            // Encode update payload to JSON, then convert to dictionary
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let logData = try encoder.encode(updatePayload)
            let logDict = try JSONSerialization.jsonObject(with: logData) as? [String: Any] ?? [:]
            
            // Convert to snake_case for JSONB
            var snakeCaseDict: [String: Any] = [:]
            for (key, value) in logDict {
                let snakeKey = camelToSnake(key)
                snakeCaseDict[snakeKey] = value
            }
            
            // Encode dictionary as JSON string
            let jsonData = try JSONSerialization.data(withJSONObject: snakeCaseDict, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            
            struct UpdateLogParams: Encodable {
                let p_device_id: String
                let p_log_id: String
                let p_log_data: String
            }
            
            let params = UpdateLogParams(
                p_device_id: deviceId.uuidString,
                p_log_id: id.uuidString,
                p_log_data: jsonString
            )
            
            let response = try await supabaseService.client.rpc(
                "update_poop_log",
                params: params
            ).execute()
            
            // Decode JSONB object response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let dto = try decoder.decode(PoopLogDTO.self, from: response.data)
            return dto
        } catch {
            throw DataError.networkError(error)
        }
    }
    
    // MARK: - Delete Operations
    
    func deleteLog(deviceId: UUID, id: UUID) async throws {
        do {
            struct DeleteLogParams: Encodable {
                let p_device_id: String
                let p_log_id: String
            }
            
            let params = DeleteLogParams(
                p_device_id: deviceId.uuidString,
                p_log_id: id.uuidString
            )
            
            // RPC function performs soft delete
            _ = try await supabaseService.client.rpc(
                "delete_poop_log",
                params: params
            ).execute()
        } catch {
            throw DataError.networkError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func logToDictionary(_ log: PoopLogDTO) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(log)
        
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw DataError.encodingError(NSError(domain: "EncodingError", code: -1))
        }
        
        // Convert camelCase keys to snake_case
        var snakeCaseDict: [String: Any] = [:]
        for (key, value) in dict {
            let snakeKey = camelToSnake(key)
            snakeCaseDict[snakeKey] = value
        }
        
        return snakeCaseDict
    }
    
    private func camelToSnake(_ string: String) -> String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: string.utf16.count)
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "$1_$2").lowercased()
    }
}

