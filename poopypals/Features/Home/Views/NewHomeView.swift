//
//  NewHomeView.swift
//  PoopyPals
//
//  MEHMET ALİ ERBİL EDITION - VIBRANT & FUN! 🎉
//

import SwiftUI

struct NewHomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        GeometryReader { geometry in
            let topPadding = geometry.safeAreaInsets.top + 40

            ZStack {
                // Memeverse gradient background
                LinearGradient.ppGradient(PPGradients.lavenderPeach)
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: PPSpacing.xl) {
                        // BIG HERO STREAK CARD
                        StreakCard(
                            streakCount: viewModel.streakCount,
                            onBreakStreak: {
                                // TODO: Define streak action
                            }
                        )
                        .slideIn(from: .top, delay: 0.1)

                        // Quick action buttons (emoji taps)
                        quickLogSection
                            .scaleIn(delay: 0.3)

                        // Stats grid
                        statsGrid
                            .slideIn(from: .bottom, delay: 0.4)

                        // Today's logs (if any)
                        if !viewModel.todayLogs.isEmpty {
                            todayLogsSection
                                .slideIn(from: .bottom, delay: 0.5)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, topPadding)
                    .padding(.horizontal, PPSpacing.lg)
                    .padding(.bottom, PPSpacing.lg)
                }
            }
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

    // MARK: - Quick Log Section (BIG EMOJI BUTTONS!)

    private var quickLogSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            HStack(spacing: PPSpacing.sm) {
                ForEach(PoopLog.Rating.allCases, id: \.self) { rating in
                    VibrantQuickLogButton(rating: rating) {
                        viewModel.quickLog(rating: rating)
                    }
                }
            }
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        VStack(spacing: PPSpacing.md) {
            HStack(spacing: PPSpacing.md) {
                VibrantStatCard(
                    icon: "list.bullet.circle.fill",
                    value: viewModel.logs.count,
                    label: "Total Logs",
                    gradient: PPGradients.mintLavender
                )

                VibrantStatCard(
                    icon: "dollarsign.circle.fill",
                    value: viewModel.totalFlushFunds,
                    label: "Flush Funds",
                    gradient: PPGradients.sunnyMint
                )
            }

            HStack(spacing: PPSpacing.md) {
                VibrantStatCard(
                    icon: "trophy.fill",
                    value: 3,  // TODO: Real achievement count
                    label: "Achievements",
                    gradient: PPGradients.coralOrange
                )

                VibrantStatCard(
                    icon: "person.2.fill",
                    value: 0,  // TODO: Active challenges
                    label: "Challenges",
                    gradient: PPGradients.peachPink
                )
            }
        }
    }

    // MARK: - Today's Logs

    private var todayLogsSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            Text("Today's Logs")
                .font(.ppTitle2)
                .fontWeight(.bold)
                .foregroundColor(.ppTextPrimary)
                .padding(.horizontal, PPSpacing.xs)

            ForEach(viewModel.todayLogs) { log in
                VibrantLogCard(log: log)
            }
        }
    }
}

// MARK: - Vibrant Quick Log Button

struct VibrantQuickLogButton: View {
    let rating: PoopLog.Rating
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTapped()
            action()
        }) {
            VStack(spacing: PPSpacing.xxs) {
                Text(rating.emoji)
                    .font(.ppEmojiSmall)
                    .ppShadow(.sm)

                Text(rating.displayName)
                    .font(.ppCaptionSmall)
                    .fontWeight(.semibold)
                    .foregroundColor(.ppTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                ZStack {
                    // Glossy background
                    RoundedRectangle(cornerRadius: PPCornerRadius.md)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Shine overlay
                    RoundedRectangle(cornerRadius: PPCornerRadius.md)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                }
            )
            .ppShadow(.md)
        }
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Vibrant Stat Card

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

// MARK: - Vibrant Log Card

struct VibrantLogCard: View {
    let log: PoopLog

    var body: some View {
        HStack(spacing: PPSpacing.md) {
            // Emoji in glossy circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Text(log.rating.emoji)
                    .font(.ppEmojiSmall)
            }

            VStack(alignment: .leading, spacing: PPSpacing.xxs) {
                Text(log.formattedTime)
                    .font(.ppLabelLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.ppTextPrimary)

                Text("\(log.durationMinutes) min • Type \(log.consistency)")
                    .font(.ppCaption)
                    .foregroundColor(.ppTextTertiary)

                if let notes = log.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.ppBodySmall)
                        .foregroundColor(.ppTextSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Flush funds earned
            VStack(spacing: PPSpacing.xxs) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.ppIconMedium)
                    .foregroundColor(.ppAccent)

                Text("+\(log.flushFundsEarned)")
                    .font(.ppLabel)
                    .fontWeight(.bold)
                    .foregroundColor(.ppTextPrimary)
            }
        }
        .padding(PPSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: PPCornerRadius.md)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.25), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: PPCornerRadius.md)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .ppShadow(.sm)
    }
}

// MARK: - Vibrant Achievement View

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
    NewHomeView()
}
