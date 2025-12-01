//
//  HomeView.swift
//  PoopyPals
//
//  Home Screen - Main App Screen with Better UX & Visual Hierarchy
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var selectedTab: Int
    
    init(selectedTab: Binding<Int> = .constant(0)) {
        self._selectedTab = selectedTab
    }

    var body: some View {
        GeometryReader { geometry in
            let topPadding = geometry.safeAreaInsets.top

            ZStack {
                // Memeverse gradient background
                LinearGradient.ppGradient(PPGradients.lavenderPeach)
                .ignoresSafeArea()

                if viewModel.isLoading {
                    ScrollView {
                        VStack(spacing: PPSpacing.xl) {
                            // Header skeleton
                            VStack(alignment: .leading, spacing: PPSpacing.sm) {
                                SkeletonView(width: 150, height: 20)
                                SkeletonView(width: 200, height: 16)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // Hero quick log skeleton
                            GlossyCard(gradient: PPGradients.surfaceSubtle, shadowIntensity: 0.2) {
                                VStack(spacing: PPSpacing.md) {
                                    HStack(spacing: PPSpacing.sm) {
                                        SkeletonView(width: nil, height: 80, cornerRadius: PPCornerRadius.md)
                                        SkeletonView(width: nil, height: 80, cornerRadius: PPCornerRadius.md)
                                        SkeletonView(width: nil, height: 80, cornerRadius: PPCornerRadius.md)
                                    }
                                    HStack(spacing: PPSpacing.sm) {
                                        Spacer()
                                        SkeletonView(width: nil, height: 80, cornerRadius: PPCornerRadius.md)
                                        SkeletonView(width: nil, height: 80, cornerRadius: PPCornerRadius.md)
                                        Spacer()
                                    }
                                }
                                .padding(PPSpacing.md)
                            }

                            // Today's progress skeleton
                            GlossyCard(gradient: PPGradients.surfaceSubtle, shadowIntensity: 0.2) {
                                HStack(spacing: PPSpacing.lg) {
                                    VStack(spacing: PPSpacing.xs) {
                                        SkeletonView(width: 60, height: 20)
                                        SkeletonView(width: 80, height: 12)
                                    }
                                    Divider().frame(height: 40)
                                    VStack(spacing: PPSpacing.xs) {
                                        SkeletonView(width: 40, height: 20)
                                        SkeletonView(width: 80, height: 12)
                                    }
                                    Divider().frame(height: 40)
                                    VStack(spacing: PPSpacing.xs) {
                                        SkeletonView(width: 60, height: 20)
                                        SkeletonView(width: 80, height: 12)
                                    }
                                }
                                .padding(PPSpacing.lg)
                            }

                            // Stats grid skeleton
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: PPSpacing.md) {
                                SkeletonStatCard()
                                SkeletonStatCard()
                                SkeletonStatCard()
                            }

                            // Logs skeleton
                            VStack(spacing: PPSpacing.md) {
                                ForEach(0..<3) { _ in
                                    SkeletonLogRow()
                                }
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.top, topPadding)
                        .padding(.horizontal, PPSpacing.lg)
                        .padding(.bottom, PPSpacing.lg)
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    ScrollView {
                        VStack(spacing: PPSpacing.xl) {
                            // Header section
                            headerSection
                                .slideIn(from: .top, delay: 0.1)

                            // Hero quick log section
                            heroQuickLogSection
                                .scaleIn(delay: 0.2)

                            // Today's progress card
                            todaysProgressCard
                                .slideIn(from: .bottom, delay: 0.3)

                            // Quick stats grid
                            quickStatsGrid
                                .slideIn(from: .bottom, delay: 0.4)

                            // Today's logs section
                            todaysLogsSection
                                .slideIn(from: .bottom, delay: 0.5)

                            // Quick navigation section
                            quickNavigationSection
                                .slideIn(from: .bottom, delay: 0.6)

                            Spacer(minLength: 100)
                        }
                        .padding(.top, topPadding)
                        .padding(.horizontal, PPSpacing.lg)
                        .padding(.bottom, PPSpacing.lg)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $viewModel.showAchievementUnlock) {
                if let achievement = viewModel.recentAchievement {
                    VibrantAchievementView(
                        achievement: achievement,
                        onShare: {
                            viewModel.shareAchievement(achievement)
                        }
                    )
                }
            }
            .shareSheet(isPresented: $viewModel.showShareSheet, items: viewModel.shareItems)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.sm) {
            Text(timeBasedGreeting)
                .font(.ppTitle3)
                .foregroundColor(.ppTextPrimary)

            if viewModel.todayLogs.isEmpty {
                Text("Ready to log your first visit?")
                    .font(.ppBody)
                    .foregroundColor(.ppTextSecondary)
            } else {
                Text("\(viewModel.todayLogs.count) log\(viewModel.todayLogs.count == 1 ? "" : "s") today")
                    .font(.ppBody)
                    .foregroundColor(.ppTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    // MARK: - Hero Quick Log Section

    private var heroQuickLogSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            Text("How was it?")
                .font(.ppTitle3)
                .foregroundColor(.ppTextPrimary)
                .padding(.horizontal, PPSpacing.xs)

            GlossyCard(gradient: PPGradients.peachYellow, shadowIntensity: 0.3) {
                VStack(spacing: PPSpacing.md) {
                    // Top row: Great, Good, Okay
                    HStack(spacing: PPSpacing.sm) {
                        HeroQuickLogButton(rating: .great) {
                            viewModel.quickLog(rating: .great)
                        }
                        HeroQuickLogButton(rating: .good) {
                            viewModel.quickLog(rating: .good)
                        }
                        HeroQuickLogButton(rating: .okay) {
                            viewModel.quickLog(rating: .okay)
                        }
                    }

                    // Bottom row: Bad, Terrible (centered)
                    HStack(spacing: PPSpacing.sm) {
                        Spacer()
                        HeroQuickLogButton(rating: .bad) {
                            viewModel.quickLog(rating: .bad)
                        }
                        HeroQuickLogButton(rating: .terrible) {
                            viewModel.quickLog(rating: .terrible)
                        }
                        Spacer()
                    }
                }
                .padding(PPSpacing.md)
            }
        }
    }

    // MARK: - Today's Progress Card

    private var todaysProgressCard: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            Text("Today's Progress")
                .font(.ppTitle3)
                .foregroundColor(.ppTextPrimary)
                .padding(.horizontal, PPSpacing.xs)

            GlossyCard(gradient: PPGradients.mintLavender, shadowIntensity: 0.3) {
                HStack(spacing: PPSpacing.lg) {
                    // Streak
                    VStack(spacing: PPSpacing.xs) {
                        HStack(spacing: PPSpacing.xs) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.ppAccent)
                            AnimatedNumber(
                                value: viewModel.streakCount,
                                font: .ppNumberMedium,
                                color: .ppTextPrimary
                            )
                        }
                        Text("Day Streak")
                            .font(.ppCaption)
                            .foregroundColor(.ppTextSecondary)
                    }

                    Divider()
                        .frame(height: 40)

                    // Today's logs
                    VStack(spacing: PPSpacing.xs) {
                        AnimatedNumber(
                            value: viewModel.todayLogs.count,
                            font: .ppNumberMedium,
                            color: .ppTextPrimary
                        )
                        Text("Logs Today")
                            .font(.ppCaption)
                            .foregroundColor(.ppTextSecondary)
                    }

                    Divider()
                        .frame(height: 40)

                    // Today's flush funds
                    VStack(spacing: PPSpacing.xs) {
                        HStack(spacing: PPSpacing.xs) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.ppAccent)
                            AnimatedNumber(
                                value: viewModel.todayFlushFunds,
                                font: .ppNumberMedium,
                                color: .ppTextPrimary
                            )
                        }
                        Text("Earned Today")
                            .font(.ppCaption)
                            .foregroundColor(.ppTextSecondary)
                    }
                }
                .padding(PPSpacing.lg)
            }
        }
    }

    // MARK: - Quick Stats Grid

    private var quickStatsGrid: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            Text("Your Stats")
                .font(.ppTitle3)
                .foregroundColor(.ppTextPrimary)
                .padding(.horizontal, PPSpacing.xs)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: PPSpacing.md) {
                VibrantStatCard(
                    icon: "list.bullet.circle.fill",
                    value: viewModel.logs.count,
                    label: "Total Logs",
                    gradient: PPGradients.mintLavender
                )

                VibrantStatCard(
                    icon: "flame.fill",
                    value: viewModel.streakCount,
                    label: "Streak",
                    gradient: PPGradients.coralOrange
                )

                VibrantStatCard(
                    icon: "dollarsign.circle.fill",
                    value: viewModel.totalFlushFunds,
                    label: "Flush Funds",
                    gradient: PPGradients.sunnyMint
                )
            }
        }
    }

    // MARK: - Today's Logs Section

    private var todaysLogsSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            HStack {
                Text("Today's Logs")
                    .font(.ppTitle3)
                    .foregroundColor(.ppTextPrimary)

                Spacer()

                if !viewModel.todayLogs.isEmpty {
                    Button {
                        selectedTab = 1 // History tab
                    } label: {
                        Text("View All")
                            .font(.ppCaption)
                            .foregroundColor(.ppAccent)
                    }
                }
            }
            .padding(.horizontal, PPSpacing.xs)

            if viewModel.todayLogs.isEmpty {
                // Empty state
                VStack(spacing: PPSpacing.sm) {
                    Text("📝")
                        .font(.ppEmojiLarge)
                    Text("No logs yet today")
                        .font(.ppBody)
                        .foregroundColor(.ppTextSecondary)
                    Text("Tap a rating above to get started!")
                        .font(.ppCaption)
                        .foregroundColor(.ppTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(PPSpacing.xl)
                .background(Color.ppSurfaceAlt)
                .cornerRadius(PPCornerRadius.md)
            } else {
                // Show max 3 logs
                ForEach(Array(viewModel.todayLogs.prefix(3))) { log in
                    CompactLogCard(log: log)
                }
            }
        }
    }

    // MARK: - Quick Navigation Section

    private var quickNavigationSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            Text("Quick Access")
                .font(.ppTitle3)
                .foregroundColor(.ppTextPrimary)
                .padding(.horizontal, PPSpacing.xs)

            HStack(spacing: PPSpacing.md) {
                QuickNavCard(
                    icon: "calendar",
                    label: "History",
                    gradient: PPGradients.peachPink
                ) {
                    selectedTab = 1
                }

                QuickNavCard(
                    icon: "trophy.fill",
                    label: "Leaderboard",
                    gradient: PPGradients.peachPink
                ) {
                    selectedTab = 2
                }

                QuickNavCard(
                    icon: "person.fill",
                    label: "Profile",
                    gradient: PPGradients.peachPink
                ) {
                    selectedTab = 3
                }
            }
        }
    }
}

// MARK: - Hero Quick Log Button

struct HeroQuickLogButton: View {
    let rating: PoopLog.Rating
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTapped()
            action()
        }) {
            VStack(spacing: PPSpacing.xs) {
                Text(rating.emoji)
                    .font(.ppEmojiLarge)

                Text(rating.displayName)
                    .font(.ppCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.ppTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 80)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: PPCornerRadius.md)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: PPCornerRadius.md)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                }
            )
            .ppShadow(.md)
        }
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Compact Log Card

struct CompactLogCard: View {
    let log: PoopLog

    var body: some View {
        GlossyCard(gradient: PPGradients.mintLavender, shadowIntensity: 0.2) {
            HStack(spacing: PPSpacing.md) {
                // Rating emoji
                Text(log.rating.emoji)
                    .font(.ppEmojiMedium)

                VStack(alignment: .leading, spacing: PPSpacing.xs) {
                    // Time
                    Text(log.formattedTime)
                        .font(.ppBody)
                        .foregroundColor(.ppTextPrimary)

                    // Rating & duration
                    HStack(spacing: PPSpacing.sm) {
                        Text(log.rating.rawValue.capitalized)
                            .font(.ppCaption)
                            .foregroundColor(.ppTextSecondary)

                        if log.durationSeconds > 0 {
                            Text("•")
                                .foregroundColor(.ppTextTertiary)
                            Text("\(log.durationSeconds)s")
                                .font(.ppCaption)
                                .foregroundColor(.ppTextSecondary)
                        }
                    }
                }

                Spacer()

                // Flush funds earned
                if log.flushFundsEarned > 0 {
                    HStack(spacing: PPSpacing.xxs) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.ppAccent)
                        Text("\(log.flushFundsEarned)")
                            .font(.ppNumberSmall)
                            .foregroundColor(.ppTextPrimary)
                    }
                }
            }
            .padding(PPSpacing.md)
        }
    }
}

// MARK: - Quick Navigation Card

struct QuickNavCard: View {
    let icon: String
    let label: String
    let gradient: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            VStack(spacing: PPSpacing.sm) {
                Image(systemName: icon)
                    .font(.ppIconLarge)
                    .foregroundColor(.ppTextPrimary)

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
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Vibrant Stat Card (keep existing)

struct VibrantStatCard: View {
    let icon: String
    let value: Int
    let label: String
    let gradient: [Color]

    var body: some View {
        GlossyCard(gradient: gradient, shadowIntensity: 0.3) {
            VStack(spacing: PPSpacing.sm) {
                Image(systemName: icon)
                    .font(.ppIconLarge)
                    .foregroundColor(.ppTextPrimary)
                    .ppShadow(.sm)

                AnimatedNumber(
                    value: value,
                    font: .ppNumberMedium,
                    color: .ppTextPrimary
                )

                Text(label)
                    .font(.ppCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.ppTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(PPSpacing.md)
        }
        .frame(height: 140)
    }
}

// MARK: - Vibrant Achievement View (keep existing)

struct VibrantAchievementView: View {
    let achievement: Achievement
    let onShare: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var showConfetti = false
    @State private var scaleIcon = false

    var body: some View {
        ZStack {
            // Memeverse gradient background
            LinearGradient.ppGradient(PPGradients.peachPink)
            .ignoresSafeArea()

            VStack(spacing: PPSpacing.xl) {
                Spacer()

                // Celebration emoji
                Text("🎉")
                    .font(.ppEmojiXL)
                    .scaleEffect(scaleIcon ? 1.2 : 0.8)
                    .onAppear {
                        HapticManager.shared.achievementUnlocked()
                        showConfetti = true

                        withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                            scaleIcon = true
                        }
                    }

                // Achievement icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 120, height: 120)

                    Image(systemName: achievement.iconName)
                        .font(.ppEmojiMedium)
                        .foregroundColor(.ppTextPrimary)
                }
                .pulse()

                Text("Achievement Unlocked!")
                    .font(.ppTitle1)
                    .fontWeight(.bold)
                    .foregroundColor(.ppTextPrimary)

                Text(achievement.title)
                    .font(.ppTitle2)
                    .foregroundColor(.ppTextSecondary)

                Text(achievement.description)
                    .font(.ppBody)
                    .foregroundColor(.ppTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PPSpacing.xl)

                // Reward
                HStack(spacing: PPSpacing.xs) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.ppAccent)
                    Text("+\(achievement.flushFundsReward) Flush Funds")
                        .font(.ppLabelLarge)
                        .fontWeight(.bold)
                        .foregroundColor(.ppTextPrimary)
                }
                .padding(PPSpacing.md)
                .background(Color.white.opacity(0.2))
                .cornerRadius(PPCornerRadius.full)

                Spacer()

                // Buttons
                VStack(spacing: PPSpacing.sm) {
                    if achievement.isShareable {
                        PPBounceButton(
                            title: "Share Achievement",
                            icon: "square.and.arrow.up",
                            style: .primary
                        ) {
                            onShare()
                            dismiss()
                        }
                    }

                    Button("Continue") {
                        dismiss()
                    }
                    .font(.ppBody)
                    .foregroundColor(.ppTextSecondary)
                }
                .padding(.horizontal, PPSpacing.xl)
                .padding(.bottom, PPSpacing.xl)
            }
        }
        .confetti(isActive: $showConfetti, particleCount: 80)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
