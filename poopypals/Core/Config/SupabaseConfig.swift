//
//  SupabaseConfig.swift
//  PoopyPals
//
//  Configuration for Supabase backend
//

import Foundation

struct SupabaseConfig {
    static let shared = SupabaseConfig()
    
    let projectURL: URL
    let anonKey: String
    
    private init() {
        // Try to load from Bundle first (if added to Xcode project)
        var configPath: String?
        var configDict: NSDictionary?
        
        // Method 1: Try Bundle
        if let bundlePath = Bundle.main.path(forResource: "Config", ofType: "plist") {
            configPath = bundlePath
            configDict = NSDictionary(contentsOfFile: bundlePath)
        }
        
        // Method 2: Try project root (for development)
        if configDict == nil {
            // Get project root by going up from bundle path
            let bundlePath = Bundle.main.bundlePath
            var searchPath = bundlePath
            
            // Go up directories to find project root
            for _ in 0..<10 {
                let testPath = (searchPath as NSString).appendingPathComponent("Config.plist")
                if FileManager.default.fileExists(atPath: testPath) {
                    configPath = testPath
                    configDict = NSDictionary(contentsOfFile: testPath)
                    break
                }
                searchPath = (searchPath as NSString).deletingLastPathComponent
                if searchPath == "/" { break }
            }
        }
        
        // Method 3: Try hardcoded project path (last resort)
        if configDict == nil {
            let hardcodedPath = "/Users/jans./Downloads/Projelerim/poopypals.ios/Config.plist"
            if FileManager.default.fileExists(atPath: hardcodedPath) {
                configPath = hardcodedPath
                configDict = NSDictionary(contentsOfFile: hardcodedPath)
            }
        }
        
        // Method 4: Try relative to source file location
        if configDict == nil {
            let sourceFile = #file
            let sourceDir = (sourceFile as NSString).deletingLastPathComponent
            let projectRoot = (sourceDir as NSString).deletingLastPathComponent
                .replacingOccurrences(of: "/Core/Config", with: "")
                .replacingOccurrences(of: "/poopypals/Core/Config", with: "")
            let testPath = (projectRoot as NSString).appendingPathComponent("Config.plist")
            if FileManager.default.fileExists(atPath: testPath) {
                configPath = testPath
                configDict = NSDictionary(contentsOfFile: testPath)
            }
        }
        
        // Method 5: Try absolute path from current directory (runtime)
        if configDict == nil {
            // Try multiple possible locations
            let bundlePath = Bundle.main.bundlePath as NSString
            let path1 = bundlePath.deletingLastPathComponent as NSString
            let path2 = path1.deletingLastPathComponent as NSString
            let path3 = path2.deletingLastPathComponent as NSString
            let possiblePaths = [
                "/Users/jans./Downloads/Projelerim/poopypals.ios/Config.plist",
                FileManager.default.currentDirectoryPath + "/Config.plist",
                path1.appendingPathComponent("Config.plist"),
                path2.appendingPathComponent("Config.plist"),
                path3.appendingPathComponent("Config.plist")
            ]
            
            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path) {
                    if let dict = NSDictionary(contentsOfFile: path) {
                        configPath = path
                        configDict = dict
                        print("✅ Config.plist found at: \(path)")
                        break
                    }
                }
            }
        }
        
        guard let dict = configDict,
              let urlString = dict["SupabaseURL"] as? String,
              let url = URL(string: urlString),
              urlString != "https://your-project-id.supabase.co", // Check if placeholder
              let key = dict["SupabaseAnonKey"] as? String,
              key != "your-anon-key-here" else { // Check if placeholder
            fatalError("""
            ⚠️ Supabase configuration missing or invalid!
            
            Config.plist found at: \(configPath ?? "not found")
            
            Please:
            1. Open Config.plist
            2. Replace 'your-project-id.supabase.co' with your real Supabase URL
            3. Replace 'your-anon-key-here' with your real anon key
            4. Add Config.plist to Xcode project:
               - Right-click project → Add Files to "poopypals"...
               - Select Config.plist
               - ✅ Copy items if needed
               - ✅ poopypals target
            """)
        }
        
        self.projectURL = url
        self.anonKey = key
    }
}

