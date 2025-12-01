//
//  SupabaseService.swift
//  PoopyPals
//
//  Main Supabase client service
//

import Foundation
import Supabase
#if canImport(UIKit)
import UIKit
#endif

@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    private let deviceService: DeviceIdentificationService
    
    @Published var isConnected: Bool = false
    
    private init() {
        let config = SupabaseConfig.shared
        
        self.client = SupabaseClient(
            supabaseURL: config.projectURL,
            supabaseKey: config.anonKey,
            options: SupabaseClientOptions(
                db: SupabaseClientOptions.DatabaseOptions(
                    schema: "public"
                ),
                auth: SupabaseClientOptions.AuthOptions(
                    autoRefreshToken: false
                )
            )
        )
        
        self.deviceService = DeviceIdentificationService()
    }
    
    // MARK: - Connection Check
    
    func checkConnection() async {
        BackendLogger.shared.logInfo("Checking Supabase connection...")
        do {
            _ = try await client.from("devices").select("id").limit(1).execute()
            isConnected = true
            BackendLogger.shared.logInfo("✅ Supabase connected successfully")
            print("✅ Supabase connected successfully")
        } catch {
            isConnected = false
            BackendLogger.shared.logError(error, context: "Connection Check")
            print("❌ Supabase connection failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Device Registration
    
    /// Registers device using RPC function that bypasses RLS
    func registerDevice() async throws -> UUID {
        let deviceId = try await deviceService.getDeviceId()
        let deviceInfo = UIDevice.current
        
        // Use RPC function that bypasses RLS
        struct RegisterDeviceParams: Encodable {
            let p_device_id: String
            let p_platform: String
            let p_app_version: String?
            let p_os_version: String?
            let p_device_model: String?
        }
        
        let params = RegisterDeviceParams(
            p_device_id: deviceId.uuidString,
            p_platform: "ios",
            p_app_version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            p_os_version: deviceInfo.systemVersion,
            p_device_model: deviceInfo.model
        )
        
        // Call RPC function - this bypasses RLS
        let response = try await client.rpc(
            "register_or_get_device",
            params: params
        ).execute()
        
        // RPC function returns UUID directly as JSON string (e.g., "abc-123-def")
        // Decode as string
        let uuidString = try JSONDecoder().decode(String.self, from: response.data)
        
        guard let internalId = UUID(uuidString: uuidString) else {
            throw NSError(domain: "DeviceRegistration", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid device ID returned: \(uuidString)"])
        }
        
        BackendLogger.shared.logDevice(deviceId: deviceId, action: "REGISTERED")
        print("✅ Device registered: \(deviceId.uuidString) -> Internal ID: \(internalId)")
        
        // Return the original device_id (not internal ID) for consistency
        return deviceId
    }
    
    /// Gets device internal ID by device_id string using RPC
    func getDeviceInternalId(deviceId: UUID) async throws -> UUID {
        struct GetDeviceIdParams: Encodable {
            let p_device_id: String
        }
        
        let params = GetDeviceIdParams(p_device_id: deviceId.uuidString)
        
        let response = try await client.rpc(
            "get_device_internal_id",
            params: params
        ).execute()
        
        // RPC function returns UUID as JSON string or null
        // Try to decode as optional string
        struct NullableStringResponse: Decodable {
            let value: String?
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if container.decodeNil() {
                    value = nil
                } else {
                    value = try container.decode(String.self)
                }
            }
        }
        
        let result = try JSONDecoder().decode(NullableStringResponse.self, from: response.data)
        
        guard let idString = result.value,
              let internalId = UUID(uuidString: idString) else {
            throw DataError.deviceNotRegistered
        }
        
        return internalId
    }
}

