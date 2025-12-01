//
//  BackendLogger.swift
//  PoopyPals
//
//  Comprehensive backend logging for Xcode console
//

import Foundation

class BackendLogger {
    static let shared = BackendLogger()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    private var isEnabled: Bool = true
    
    // MARK: - Logging Methods
    
    func logRequest(method: String, table: String, action: String = "") {
        guard isEnabled else { return }
        let timestamp = dateFormatter.string(from: Date())
        let actionText = action.isEmpty ? "" : " [\(action)]"
        print("🌐 [\(timestamp)] REQUEST → \(method) \(table)\(actionText)")
    }
    
    func logResponse(table: String, success: Bool, count: Int? = nil) {
        guard isEnabled else { return }
        let timestamp = dateFormatter.string(from: Date())
        let countText = count != nil ? " (\(count!) items)" : ""
        let icon = success ? "✅" : "❌"
        print("\(icon) [\(timestamp)] RESPONSE ← \(table)\(countText)")
    }
    
    func logError(_ error: Error, context: String = "") {
        guard isEnabled else { return }
        let timestamp = dateFormatter.string(from: Date())
        let contextText = context.isEmpty ? "" : " [\(context)]"
        print("❌ [\(timestamp)] ERROR\(contextText): \(error.localizedDescription)")
        
        // Print full error details in debug
        #if DEBUG
        print("   📋 Error Type: \(type(of: error))")
        print("   📋 Error Description: \(error.localizedDescription)")
        #endif
    }
    
    func logSync(action: String, item: String, success: Bool) {
        guard isEnabled else { return }
        let timestamp = dateFormatter.string(from: Date())
        let icon = success ? "🔄" : "⚠️"
        print("\(icon) [\(timestamp)] SYNC \(action) → \(item)")
    }
    
    func logDevice(deviceId: UUID, action: String) {
        guard isEnabled else { return }
        let timestamp = dateFormatter.string(from: Date())
        print("📱 [\(timestamp)] DEVICE \(action): \(deviceId.uuidString)")
    }
    
    func logCache(action: String, key: String, count: Int? = nil) {
        guard isEnabled else { return }
        let timestamp = dateFormatter.string(from: Date())
        let countText = count != nil ? " (\(count!) items)" : ""
        print("💾 [\(timestamp)] CACHE \(action) → \(key)\(countText)")
    }
    
    func logInfo(_ message: String) {
        guard isEnabled else { return }
        let timestamp = dateFormatter.string(from: Date())
        print("ℹ️ [\(timestamp)] \(message)")
    }
    
    // MARK: - Supabase Request Interceptor
    
    func logSupabaseRequest(url: String, method: String, table: String) {
        guard isEnabled else { return }
        let timestamp = dateFormatter.string(from: Date())
        print("🔵 [\(timestamp)] SUPABASE → \(method) \(table)")
        #if DEBUG
        print("   URL: \(url)")
        #endif
    }
    
    func logSupabaseResponse(table: String, statusCode: Int?, dataCount: Int? = nil) {
        guard isEnabled else { return }
        let timestamp = dateFormatter.string(from: Date())
        let statusIcon = (statusCode ?? 0) >= 200 && (statusCode ?? 0) < 300 ? "✅" : "❌"
        let statusText = statusCode != nil ? " [\(statusCode!)]" : ""
        let countText = dataCount != nil ? " (\(dataCount!) items)" : ""
        print("\(statusIcon) [\(timestamp)] SUPABASE ← \(table)\(statusText)\(countText)")
    }
    
    // MARK: - Control
    
    func enable() {
        isEnabled = true
        logInfo("Backend logging ENABLED")
    }
    
    func disable() {
        isEnabled = false
        print("Backend logging DISABLED")
    }
}


