//
//  SupabaseLeaderboardDataSource.swift
//  PoopyPals
//
//  Remote data source for Leaderboard (Supabase)
//

import Foundation
import Supabase

class SupabaseLeaderboardDataSource: RemoteLeaderboardDataSourceProtocol {
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
    
    func fetchLeaderboard(
        period: LeaderboardPeriod,
        metric: LeaderboardMetric,
        limit: Int,
        currentDeviceId: UUID
    ) async throws -> [LeaderboardEntry] {
        do {
            let functionName = "get_\(period.rawValue)_leaderboard"
            
            struct LeaderboardParams: Encodable {
                let p_metric: String
                let p_limit: Int
            }
            
            let response = try await supabaseService.client.rpc(
                functionName,
                params: LeaderboardParams(
                    p_metric: metric.rawValue,
                    p_limit: limit
                )
            ).execute()
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let dtos = try decoder.decode([LeaderboardEntryDTO].self, from: response.data)
            
            // Get current user's internal device ID for comparison
            let currentInternalId = try? await getDeviceInternalId(deviceId: currentDeviceId)
            
            // Convert to domain entities and mark current user
            return dtos.map { dto in
                var entry = dto.toDomain()
                if let internalId = currentInternalId {
                    entry.isCurrentUser = (entry.id == internalId)
                }
                return entry
            }
        } catch {
            throw DataError.networkError(error)
        }
    }
    
    func fetchUserRank(
        deviceId: UUID,
        period: LeaderboardPeriod,
        metric: LeaderboardMetric
    ) async throws -> LeaderboardEntry? {
        do {
            struct UserRankParams: Encodable {
                let p_device_id: String
                let p_period: String
                let p_metric: String
            }
            
            let response = try await supabaseService.client.rpc(
                "get_user_rank",
                params: UserRankParams(
                    p_device_id: deviceId.uuidString,
                    p_period: period.rawValue,
                    p_metric: metric.rawValue
                )
            ).execute()
            
            // Check if response is empty (user not found or no rank)
            guard !response.data.isEmpty else {
                return nil
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let dtos = try decoder.decode([LeaderboardEntryDTO].self, from: response.data)
            
            if let dto = dtos.first {
                var entry = dto.toDomain()
                entry.isCurrentUser = true
                return entry
            }
            
            return nil
        } catch {
            throw DataError.networkError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getDeviceInternalId(deviceId: UUID) async throws -> UUID {
        // Try to get device internal ID using RPC function
        do {
            return try await supabaseService.getDeviceInternalId(deviceId: deviceId)
        } catch {
            // Device not found, register it first
            _ = try await supabaseService.registerDevice()
            // Try again after registration
            return try await supabaseService.getDeviceInternalId(deviceId: deviceId)
        }
    }
}

