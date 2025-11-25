//
//  HomeView.swift
//  PoopyPals
//
//  Home Screen - Main App Screen
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: PPSpacing.lg) {
                    // Streak Card (Gamification!)
                    StreakCard(
                        streakCount: viewModel.streakCount,
                        onBreakStreak: {
                            // TODO: Hook up streak reminder action
                        }
                    )

                    // Stats Row
                    StatsRow(
                        totalLogs: viewModel.logs.count,
                        flushFunds: viewModel.totalFlushFunds
                    )

                    // Quick Log Buttons (FAST ONBOARDING!)
                    QuickLogSection(onLogTapped: { rating in
                        viewModel.quickLog(rating: rating)
                    })

                    // Today's Logs
                    if !viewModel.todayLogs.isEmpty {
                        TodayLogsSection(logs: viewModel.todayLogs)
                    }

                    Spacer()
                }
                .padding(PPSpacing.md)
            }
            .navigationTitle("PoopyPals")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.ppBackground)
        }
        .sheet(isPresented: $viewModel.showAchievementUnlock) {
            if let achievement = viewModel.recentAchievement {
                AchievementUnlockView(
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

// MARK: - Stats Row

struct StatsRow: View {
    let totalLogs: Int
    let flushFunds: Int

    var body: some View {
        HStack(spacing: PPSpacing.md) {
            StatCard(
                icon: "list.bullet.circle.fill",
                value: "\(totalLogs)",
                label: "Total Logs",
                color: .ppMain
            )

            StatCard(
                icon: "dollarsign.circle.fill",
                value: "\(flushFunds)",
                label: "Flush Funds",
                color: .ppAccent
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: PPSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)

            // Animated number instead of static text
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
        .background(Color.ppBackgroundSecondary)
        .cornerRadius(PPCornerRadius.md)
        .ppShadow(.sm)
        .slideIn(from: .bottom, delay: 0.2)  // Staggered animation
    }
}

// MARK: - Quick Log Section (VIRAL - FAST ENGAGEMENT!)

struct QuickLogSection: View {
    let onLogTapped: (PoopLog.Rating) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PPSpacing.sm) {
            Text("How was it?")
                .font(.ppTitle3)
                .foregroundColor(.ppTextPrimary)

            HStack(spacing: PPSpacing.xs) {
                ForEach(PoopLog.Rating.allCases, id: \.self) { rating in
                    QuickLogButton(rating: rating) {
                        onLogTapped(rating)
                    }
                }
            }
        }
    }
}

struct QuickLogButton: View {
    let rating: PoopLog.Rating
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTapped()
            action()
        }) {
            VStack(spacing: PPSpacing.xxs) {
                Text(rating.emoji)
                    .font(.ppEmojiSmall)

                Text(rating.displayName)
                    .font(.ppCaptionSmall)
                    .foregroundColor(.ppTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PPSpacing.sm)
            .background(Color.ppBackgroundSecondary)
            .cornerRadius(PPCornerRadius.sm)
        }
        .buttonStyle(BounceButtonStyle())  // Add bounce effect!
        .scaleIn(delay: 0.3)  // Slide in animation
    }
}

// MARK: - Today's Logs Section

struct TodayLogsSection: View {
    let logs: [PoopLog]

    var body: some View {
        VStack(alignment: .leading, spacing: PPSpacing.sm) {
            Text("Today's Logs")
                .font(.ppTitle3)
                .foregroundColor(.ppTextPrimary)

            ForEach(logs) { log in
                LogRow(log: log)
            }
        }
    }
}

struct LogRow: View {
    let log: PoopLog

    var body: some View {
        HStack(spacing: PPSpacing.md) {
            Text(log.rating.emoji)
                .font(.ppEmojiSmall)

            VStack(alignment: .leading, spacing: PPSpacing.xxs) {
                Text(log.formattedTime)
                    .font(.ppLabelLarge)
                    .foregroundColor(.ppTextPrimary)

                Text("\(log.durationMinutes) min • Type \(log.consistency)")
                    .font(.ppCaption)
                    .foregroundColor(.ppTextSecondary)
            }

            Spacer()

            HStack(spacing: PPSpacing.xxs) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.ppAccent)
                Text("+\(log.flushFundsEarned)")
                    .font(.ppLabelSmall)
                    .foregroundColor(.ppTextSecondary)
            }
        }
        .padding(PPSpacing.md)
        .background(Color.ppBackgroundSecondary)
        .cornerRadius(PPCornerRadius.md)
        .ppShadow(.sm)
    }
}

// MARK: - Achievement Unlock View (VIRAL MOMENT!)

struct AchievementUnlockView: View {
    let achievement: Achievement
    let onShare: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var showConfetti = false
    @State private var scaleIcon = false

    var body: some View {
        ZStack {
            Color.ppSurface.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: PPSpacing.xl) {
                // Confetti animation!
                Text("🎉")
                    .font(.ppEmojiLarge)
                    .scaleEffect(scaleIcon ? 1.2 : 0.8)
                    .onAppear {
                        HapticManager.shared.achievementUnlocked()
                        showConfetti = true

                        withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                            scaleIcon = true
                        }
                    }

                Image(systemName: achievement.iconName)
                    .font(.ppEmojiMedium)
                    .foregroundColor(.ppMain)

                Text("Achievement Unlocked!")
                    .font(.ppTitle1)
                    .foregroundColor(.ppTextPrimary)

                Text(achievement.title)
                    .font(.ppTitle2)
                    .foregroundColor(.ppTextPrimary)

                Text(achievement.description)
                    .font(.ppBody)
                    .foregroundColor(.ppTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PPSpacing.xl)

                HStack(spacing: PPSpacing.xs) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.ppAccent)
                    Text("+\(achievement.flushFundsReward) Flush Funds")
                        .font(.ppLabelLarge)
                        .foregroundColor(.ppAccent)
                }

                // Share Button (VIRAL!)
                if achievement.isShareable {
                    Button(action: {
                        onShare()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Achievement")
                        }
                        .font(.ppLabelLarge)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PPSpacing.sm)
                        .background(Color.ppMain)
                        .foregroundColor(.ppTextPrimary)
                        .cornerRadius(PPCornerRadius.sm)
                    }
                    .padding(.horizontal, PPSpacing.xl)
                }

                Button("Continue") {
                    dismiss()
                }
                .font(.ppBody)
                .foregroundColor(.ppTextSecondary)
            }
            .padding(PPSpacing.xxl)
            .background(Color.ppBackgroundSecondary)
            .cornerRadius(PPCornerRadius.lg)
            .ppShadow(.xl)
            .padding(PPSpacing.xl)
            .scaleIn()  // Scale in animation
        }
        .confetti(isActive: $showConfetti, particleCount: 60)  // CONFETTI!
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
