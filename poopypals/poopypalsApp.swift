//
//  poopypalsApp.swift
//  PoopyPals
//
//  Created by Can Soğancı on 11.11.2025.
//

import SwiftUI
import StableID

@main
struct PoopyPalsApp: App {
    @StateObject private var appContainer = AppContainer.shared
    
    init() {
        // Configure StableID for persistent device identification
        StableID.configure()
        
        // Initialize app container
        Task { @MainActor in
            await AppContainer.shared.initialize()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
