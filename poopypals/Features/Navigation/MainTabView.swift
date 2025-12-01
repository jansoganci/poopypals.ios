//
//  MainTabView.swift
//  PoopyPals
//
//  Main Navigation - Tab Bar with 4 core screens
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    // Expose selectedTab for child views
    var selectedTabBinding: Binding<Int> {
        Binding(
            get: { selectedTab },
            set: { selectedTab = $0 }
        )
    }
    
    init() {
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Background - Warm white with pink tint
        appearance.backgroundColor = UIColor(Color.ppSurface)
        
        // Selected item - Peach with purple text
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.ppMain)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.ppMain),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        // Unselected items - Purple text
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.ppTextSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.ppTextSecondary),
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        
        // Shadow - Pastel pink
        appearance.shadowColor = UIColor(Color.ppShadowPink.opacity(0.3))
        appearance.shadowImage = UIImage()
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView(selectedTab: selectedTabBinding)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // History Tab
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(1)
            
            // Leaderboard Tab
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy.fill")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .transaction { transaction in
            transaction.animation = nil
        }
        .animation(nil, value: selectedTab)
    }
}

#Preview {
    MainTabView()
}

