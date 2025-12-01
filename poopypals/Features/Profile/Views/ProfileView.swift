//
//  ProfileView.swift
//  PoopyPals
//
//  Profile Screen - Stats & Achievements
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient.ppGradient(PPGradients.lavenderPeach)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ScrollView {
                    VStack(spacing: PPSpacing.xl) {
                        // Profile header skeleton
                        SkeletonProfileHeader()
                        
                        // Stats grid skeleton
                        VStack(alignment: .leading, spacing: PPSpacing.md) {
                            SkeletonView(width: 100, height: 20)
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: PPSpacing.md) {
                                SkeletonStatCard()
                                SkeletonStatCard()
                                SkeletonStatCard()
                            }
                        }
                        
                        // Achievements skeleton
                        VStack(alignment: .leading, spacing: PPSpacing.md) {
                            SkeletonView(width: 120, height: 20)
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: PPSpacing.md) {
                                ForEach(0..<4) { _ in
                                    SkeletonCard()
                                }
                            }
                        }
                    }
                    .padding(.top, PPSpacing.md)
                    .padding(.horizontal, PPSpacing.lg)
                    .padding(.bottom, PPSpacing.lg)
                }
            } else {
                ScrollView {
                    VStack(spacing: PPSpacing.xl) {
                        // Profile header
                        profileHeader
                        
                        // Stats grid
                        statsGrid
                        
                        // Achievements section
                        achievementsSection
                    }
                    .padding(.top, PPSpacing.md)
                    .padding(.horizontal, PPSpacing.lg)
                    .padding(.bottom, PPSpacing.lg)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .refreshable {
            await viewModel.loadData()
        }
        .alert(item: $viewModel.errorAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Subviews
    
    private var profileHeader: some View {
        VStack(spacing: PPSpacing.md) {
            // Avatar
            Circle()
                .fill(LinearGradient.ppGradient(PPGradients.peachYellow))
                .frame(width: 100, height: 100)
                .overlay(
                    Text("💩")
                        .font(.ppEmojiXL)
                )
                .ppShadow(.md)
            
            // Display name
            Text("FlushMaster#\(viewModel.deviceIdString)")
                .font(.ppTitle2)
                .foregroundColor(.ppTextPrimary)
            
            // Device ID (subtle)
            Text("Device ID: \(viewModel.deviceIdString)")
                .font(.ppCaption)
                .foregroundColor(.ppTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(PPSpacing.xl)
        .background(
            GlossyCard(gradient: PPGradients.peachPink, shadowIntensity: 0.3) {
                EmptyView()
            }
        )
        .cornerRadius(PPCornerRadius.md)
    }
    
    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            Text("Your Stats")
                .font(.ppTitle3)
                .foregroundColor(.ppTextPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: PPSpacing.md) {
                ProfileStatCard(
                    icon: "list.bullet.circle.fill",
                    value: "\(viewModel.totalLogs)",
                    label: "Total Logs",
                    gradient: PPGradients.mintLavender
                )
                
                ProfileStatCard(
                    icon: "flame.fill",
                    value: "\(viewModel.streakCount)",
                    label: "Streak",
                    gradient: PPGradients.fire
                )
                
                ProfileStatCard(
                    icon: "dollarsign.circle.fill",
                    value: "\(viewModel.totalFlushFunds)",
                    label: "Flush Funds",
                    gradient: PPGradients.peachYellow
                )
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            HStack {
                Text("Achievements")
                    .font(.ppTitle3)
                    .foregroundColor(.ppTextPrimary)
                
                Spacer()
                
                Text("\(viewModel.unlockedAchievements.count)")
                    .font(.ppNumberSmall)
                    .foregroundColor(.ppAccent)
            }
            
            if viewModel.unlockedAchievements.isEmpty {
                VStack(spacing: PPSpacing.sm) {
                    Text("🏆")
                        .font(.ppEmojiLarge)
                    Text("No achievements yet")
                        .font(.ppBody)
                        .foregroundColor(.ppTextSecondary)
                    Text("Keep logging to unlock achievements!")
                        .font(.ppCaption)
                        .foregroundColor(.ppTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(PPSpacing.xl)
                .background(Color.ppSurfaceAlt)
                .cornerRadius(PPCornerRadius.md)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: PPSpacing.md) {
                    ForEach(viewModel.unlockedAchievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            }
        }
    }
}

// MARK: - Profile Stat Card

struct ProfileStatCard: View {
    let icon: String
    let value: String
    let label: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: PPSpacing.sm) {
            Image(systemName: icon)
                .font(.ppTitle2)
                .foregroundColor(.ppTextPrimary)
            
            AnimatedNumber(
                value: Int(value) ?? 0,
                font: .ppNumberMedium,
                color: .ppTextPrimary
            )
            
            Text(label)
                .font(.ppCaption)
                .foregroundColor(.ppTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(PPSpacing.md)
        .background(
            GlossyCard(gradient: gradient, shadowIntensity: 0.2) {
                EmptyView()
            }
        )
        .cornerRadius(PPCornerRadius.md)
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: PPSpacing.xs) {
            Image(systemName: achievement.iconName)
                .font(.ppIconLarge)
                .foregroundColor(.ppTextPrimary)
            
            Text(achievement.title)
                .font(.ppBody)
                .foregroundColor(.ppTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(PPSpacing.md)
        .background(
            GlossyCard(gradient: PPGradients.coralOrange, shadowIntensity: 0.2) {
                EmptyView()
            }
        )
        .cornerRadius(PPCornerRadius.md)
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}

