//
//  BackendTester.swift
//  PoopyPals
//
//  Backend connection tester utility
//

import Foundation

@MainActor
class BackendTester {
    static let shared = BackendTester()
    
    private let supabaseService = SupabaseService.shared
    private let deviceService = DeviceIdentificationService()
    
    // MARK: - Test Methods
    
    /// Test backend connection and print results
    func testConnection() async {
        print("\n🔍 BACKEND CONNECTION TEST")
        print(String(repeating: "=", count: 50))
        
        // 1. Check Config
        print("\n1️⃣ Checking Supabase Config...")
        do {
            let config = SupabaseConfig.shared
            print("   ✅ Project URL: \(config.projectURL)")
            print("   ✅ Anon Key: \(String(config.anonKey.prefix(20)))...")
        } catch {
            print("   ❌ Config Error: \(error)")
            return
        }
        
        // 2. Test Device Registration
        print("\n2️⃣ Testing Device Registration...")
        do {
            let deviceId = try await deviceService.getDeviceId()
            print("   ✅ Device ID: \(deviceId.uuidString)")
            
            let registeredId = try await supabaseService.registerDevice()
            print("   ✅ Device Registered: \(registeredId.uuidString)")
        } catch {
            print("   ❌ Registration Failed: \(error.localizedDescription)")
        }
        
        // 3. Test Connection
        print("\n3️⃣ Testing Supabase Connection...")
        await supabaseService.checkConnection()
        if supabaseService.isConnected {
            print("   ✅ Connected to Supabase!")
        } else {
            print("   ❌ Connection Failed!")
        }
        
        // 4. Test Database Tables
        print("\n4️⃣ Testing Database Tables...")
        await testTables()
        
        print("\n" + String(repeating: "=", count: 50))
        print("✅ TEST COMPLETE\n")
    }
    
    private func testTables() async {
        let tables = ["devices", "poop_logs", "achievements"]
        
        for table in tables {
            do {
                let response = try await supabaseService.client
                    .from(table)
                    .select("id")
                    .limit(1)
                    .execute()
                
                print("   ✅ Table '\(table)' accessible")
            } catch {
                print("   ❌ Table '\(table)' error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Get current backend status
    func getStatus() -> String {
        var status = "📊 BACKEND STATUS\n"
        status += String(repeating: "=", count: 30) + "\n"
        
        // Config status
        do {
            let config = SupabaseConfig.shared
            status += "✅ Config: Loaded\n"
            status += "   URL: \(config.projectURL)\n"
        } catch {
            status += "❌ Config: Missing\n"
            status += "   Error: \(error.localizedDescription)\n"
        }
        
        // Connection status
        status += supabaseService.isConnected ? "✅ Connection: Active\n" : "❌ Connection: Failed\n"
        
        return status
    }
}

