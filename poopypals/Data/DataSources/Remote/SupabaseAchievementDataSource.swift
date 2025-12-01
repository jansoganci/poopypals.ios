//
//  SupabaseAchievementDataSource.swift
//  PoopyPals
//
//  Remote data source for Achievement (Supabase)
//

import Foundation
import Supabase

protocol RemoteAchievementDataSourceProtocol {
    func fetchUnlockedAchievements(deviceId: UUID) async throws -> [AchievementDTO]
    func unlockAchievement(deviceId: UUID, achievement: AchievementDTO) async throws -> AchievementDTO
    func markAsViewed(deviceId: UUID, achievementId: UUID) async throws
}

class SupabaseAchievementDataSource: RemoteAchievementDataSourceProtocol {
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
    
    func fetchUnlockedAchievements(deviceId: UUID) async throws -> [AchievementDTO] {
        do {
            struct FetchAchievementsParams: Encodable {
                let p_device_id: String
            }
            
            let params = FetchAchievementsParams(p_device_id: deviceId.uuidString)
            
            let response = try await supabaseService.client.rpc(
                "fetch_unlocked_achievements",
                params: params
            ).execute()
            
            // Decode JSONB array response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let dtos = try decoder.decode([AchievementDTO].self, from: response.data)
            return dtos
        } catch {
            throw DataError.networkError(error)
        }
    }
    
    // MARK: - Create Operations
    
    func unlockAchievement(deviceId: UUID, achievement: AchievementDTO) async throws -> AchievementDTO {
        do {
            // Encode achievement to JSON, then convert to dictionary
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let achievementData = try encoder.encode(achievement)
            let achievementDict = try JSONSerialization.jsonObject(with: achievementData) as? [String: Any] ?? [:]
            
            // Convert to snake_case for JSONB
            var snakeCaseDict: [String: Any] = [:]
            for (key, value) in achievementDict {
                let snakeKey = camelToSnake(key)
                snakeCaseDict[snakeKey] = value
            }
            
            // Encode dictionary as JSON string
            let jsonData = try JSONSerialization.data(withJSONObject: snakeCaseDict, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            
            struct UnlockAchievementParams: Encodable {
                let p_device_id: String
                let p_achievement_data: String
            }
            
            let params = UnlockAchievementParams(
                p_device_id: deviceId.uuidString,
                p_achievement_data: jsonString
            )
            
            let response = try await supabaseService.client.rpc(
                "unlock_achievement",
                params: params
            ).execute()
            
            // Decode JSONB object response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let dto = try decoder.decode(AchievementDTO.self, from: response.data)
            return dto
        } catch {
            throw DataError.networkError(error)
        }
    }
    
    // MARK: - Update Operations
    
    func markAsViewed(deviceId: UUID, achievementId: UUID) async throws {
        do {
            struct MarkViewedParams: Encodable {
                let p_device_id: String
                let p_achievement_id: String
            }
            
            let params = MarkViewedParams(
                p_device_id: deviceId.uuidString,
                p_achievement_id: achievementId.uuidString
            )
            
            // RPC function marks achievement as viewed
            _ = try await supabaseService.client.rpc(
                "mark_achievement_viewed",
                params: params
            ).execute()
        } catch {
            throw DataError.networkError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func achievementToDictionary(_ achievement: AchievementDTO) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(achievement)
        
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

