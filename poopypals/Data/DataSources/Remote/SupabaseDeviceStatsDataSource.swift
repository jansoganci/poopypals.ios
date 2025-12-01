//
//  SupabaseDeviceStatsDataSource.swift
//  PoopyPals
//
//  Remote data source for Device Stats (Supabase)
//

import Foundation
import Supabase

protocol RemoteDeviceStatsDataSourceProtocol {
    func fetchStats(deviceId: UUID) async throws -> DeviceStatsDTO
    func updateStreak(deviceId: UUID, count: Int) async throws
    func addFlushFunds(deviceId: UUID, amount: Int) async throws
}

class SupabaseDeviceStatsDataSource: RemoteDeviceStatsDataSourceProtocol {
    private let supabaseService: SupabaseService
    private let deviceService: DeviceIdentificationService
    
    init(
        supabaseService: SupabaseService = .shared,
        deviceService: DeviceIdentificationService = DeviceIdentificationService()
    ) {
        self.supabaseService = supabaseService
        self.deviceService = deviceService
    }
    
    // MARK: - Fetch Operations
    
    func fetchStats(deviceId: UUID) async throws -> DeviceStatsDTO {
        do {
            struct FetchStatsParams: Encodable {
                let p_device_id: String
            }
            
            let params = FetchStatsParams(p_device_id: deviceId.uuidString)
            
            let response = try await supabaseService.client.rpc(
                "fetch_device_stats",
                params: params
            ).execute()
            
            // Decode JSONB object response
            struct DeviceStatsResponse: Codable {
                let streakCount: Int
                let flushFunds: Int
                let totalLogs: Int
                let lastLogDate: Date?
                
                enum CodingKeys: String, CodingKey {
                    case streakCount = "streak_count"
                    case flushFunds = "flush_funds"
                    case totalLogs = "total_logs"
                    case lastLogDate = "last_log_date"
                }
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let stats = try decoder.decode(DeviceStatsResponse.self, from: response.data)
            
            return DeviceStatsDTO(
                streakCount: stats.streakCount,
                totalFlushFunds: stats.flushFunds,
                totalLogs: stats.totalLogs,
                lastLogDate: stats.lastLogDate
            )
        } catch {
            throw DataError.networkError(error)
        }
    }
    
    // MARK: - Update Operations
    
    func updateStreak(deviceId: UUID, count: Int) async throws {
        do {
            // Create JSONB payload for stats update
            let statsDict: [String: Any] = ["streak_count": count]
            let jsonData = try JSONSerialization.data(withJSONObject: statsDict, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            
            struct UpdateStatsParams: Encodable {
                let p_device_id: String
                let p_stats_data: String
            }
            
            let params = UpdateStatsParams(
                p_device_id: deviceId.uuidString,
                p_stats_data: jsonString
            )
            
            // Use RPC function to update stats
            _ = try await supabaseService.client.rpc(
                "update_device_stats_fields",
                params: params
            ).execute()
        } catch {
            throw DataError.networkError(error)
        }
    }
    
    func addFlushFunds(deviceId: UUID, amount: Int) async throws {
        do {
            // Get current flush funds, then add amount
            let currentStats = try await fetchStats(deviceId: deviceId)
            let newAmount = currentStats.totalFlushFunds + amount
            
            // Create JSONB payload for stats update
            let statsDict: [String: Any] = ["flush_funds": newAmount]
            let jsonData = try JSONSerialization.data(withJSONObject: statsDict, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            
            struct UpdateStatsParams: Encodable {
                let p_device_id: String
                let p_stats_data: String
            }
            
            let params = UpdateStatsParams(
                p_device_id: deviceId.uuidString,
                p_stats_data: jsonString
            )
            
            // Use RPC function to update stats
            _ = try await supabaseService.client.rpc(
                "update_device_stats_fields",
                params: params
            ).execute()
        } catch {
            throw DataError.networkError(error)
        }
    }
    
}

