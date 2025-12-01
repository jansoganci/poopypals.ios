//
//  LeaderboardView.swift
//  PoopyPals
//
//  Leaderboard Screen - Main View
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: PPSpacing.xl) {
                // Period selector
                periodSelector
                
                // Metric selector
                metricSelector
                
                // Loading state
                if viewModel.isLoading {
                    ScrollView {
                        VStack(spacing: PPSpacing.xl) {
                            // Period & metric selectors skeleton
                            VStack(spacing: PPSpacing.md) {
                                HStack(spacing: PPSpacing.sm) {
                                    ForEach(0..<3) { _ in
                                        SkeletonView(width: nil, height: 40, cornerRadius: PPCornerRadius.md)
                                    }
                                }
                                HStack(spacing: PPSpacing.sm) {
                                    ForEach(0..<3) { _ in
                                        SkeletonView(width: nil, height: 40, cornerRadius: PPCornerRadius.md)
                                    }
                                }
                            }
                            .padding(.horizontal, PPSpacing.lg)
                            
                            // Podium skeleton
                            HStack(spacing: PPSpacing.md) {
                                SkeletonPodiumCard()
                                SkeletonPodiumCard()
                                SkeletonPodiumCard()
                            }
                            .padding(.horizontal, PPSpacing.lg)
                            
                            // Leaderboard rows skeleton
                            VStack(spacing: PPSpacing.md) {
                                ForEach(0..<10) { _ in
                                    SkeletonLeaderboardRow()
                                }
                            }
                            .padding(.horizontal, PPSpacing.lg)
                        }
                        .padding(.vertical, PPSpacing.lg)
                    }
                } else {
                    // Top 3 podium
                    if viewModel.topThree.count >= 3 {
                        PodiumView(
                            entries: viewModel.topThree,
                            metric: viewModel.selectedMetric
                        )
                    }
                    
                    // Leaderboard list (rank 4+)
                    if !viewModel.remainingEntries.isEmpty {
                        leaderboardList
                    }
                    
                    // Current user rank (if not in top 100)
                    if let userRank = viewModel.currentUserRank {
                        CurrentUserRankCard(entry: userRank, metric: viewModel.selectedMetric)
                    }
                    
                    // Empty state
                    if viewModel.entries.isEmpty && !viewModel.isLoading {
                        emptyState
                    }
                }
            }
            .padding(.top, PPSpacing.md)
            .padding(.horizontal, PPSpacing.lg)
            .padding(.bottom, PPSpacing.lg)
        }
        .background(LinearGradient.ppGradient(PPGradients.lavenderPeach))
        .task {
            await viewModel.loadLeaderboard()
        }
        .refreshable {
            await viewModel.loadLeaderboard()
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
    
    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: PPSpacing.sm) {
            Text("Time Period")
                .font(.ppCaption)
                .foregroundColor(.ppTextSecondary)
                .padding(.horizontal, PPSpacing.xs)
            
            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(LeaderboardPeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedPeriod) { _, newPeriod in
                viewModel.changePeriod(newPeriod)
            }
        }
    }
    
    private var metricSelector: some View {
        VStack(alignment: .leading, spacing: PPSpacing.sm) {
            Text("Ranking By")
                .font(.ppCaption)
                .foregroundColor(.ppTextSecondary)
                .padding(.horizontal, PPSpacing.xs)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PPSpacing.sm) {
                    ForEach(LeaderboardMetric.allCases, id: \.self) { metric in
                        MetricButton(
                            metric: metric,
                            isSelected: viewModel.selectedMetric == metric
                        ) {
                            viewModel.changeMetric(metric)
                        }
                    }
                }
                .padding(.horizontal, PPSpacing.xs)
            }
        }
    }
    
    private var leaderboardList: some View {
        VStack(alignment: .leading, spacing: PPSpacing.sm) {
            Text("Rankings")
                .font(.ppTitle3)
                .foregroundColor(.ppTextPrimary)
                .padding(.horizontal, PPSpacing.xs)
            
            LazyVStack(spacing: PPSpacing.md) {
                ForEach(viewModel.remainingEntries) { entry in
                    LeaderboardRow(
                        entry: entry,
                        metric: viewModel.selectedMetric
                    )
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: PPSpacing.md) {
            Text("🏆")
                .font(.ppEmojiXL)
            
            Text("No Rankings Yet")
                .font(.ppTitle2)
                .foregroundColor(.ppTextPrimary)
            
            Text("Be the first to log and climb the leaderboard!")
                .font(.ppBody)
                .foregroundColor(.ppTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(PPSpacing.xl)
    }
}

// MARK: - Metric Button

struct MetricButton: View {
    let metric: LeaderboardMetric
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            HStack(spacing: PPSpacing.xs) {
                Image(systemName: metric.icon)
                    .font(.ppCaption)
                
                Text(metric.displayName)
                    .font(.ppBody)
            }
            .foregroundColor(isSelected ? .ppTextPrimary : .ppTextSecondary)
            .padding(.horizontal, PPSpacing.md)
            .padding(.vertical, PPSpacing.sm)
            .background(
                Group {
                    if isSelected {
                        LinearGradient.ppGradient(PPGradients.peachPink)
                    } else {
                        Color.ppSurfaceAlt
                    }
                }
            )
            .cornerRadius(PPCornerRadius.full)
            .overlay(
                RoundedRectangle(cornerRadius: PPCornerRadius.full)
                    .stroke(
                        isSelected
                            ? Color.white.opacity(0.3)
                            : Color.clear,
                        lineWidth: isSelected ? 1 : 0
                    )
            )
        }
        .buttonStyle(BounceButtonStyle())
    }
}

#Preview {
    NavigationView {
        LeaderboardView()
    }
}

