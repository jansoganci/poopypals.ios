//
//  PodiumView.swift
//  PoopyPals
//
//  Podium view for top 3 rankings
//

import SwiftUI

struct PodiumView: View {
    let entries: [LeaderboardEntry]  // Top 3
    let metric: LeaderboardMetric
    
    var body: some View {
        HStack(alignment: .bottom, spacing: PPSpacing.md) {
            // 2nd place (left, medium height)
            if entries.count >= 2 {
                PodiumCard(
                    entry: entries[1],
                    rank: 2,
                    metric: metric,
                    gradient: PPGradients.mintLavender  // Silver theme
                )
            }
            
            // 1st place (center, tallest)
            PodiumCard(
                entry: entries[0],
                rank: 1,
                metric: metric,
                gradient: PPGradients.peachYellow  // Gold theme
            )
            
            // 3rd place (right, shortest)
            if entries.count >= 3 {
                PodiumCard(
                    entry: entries[2],
                    rank: 3,
                    metric: metric,
                    gradient: PPGradients.coralOrange  // Bronze theme
                )
            }
        }
        .padding(.vertical, PPSpacing.xl)
    }
}

#Preview {
    PodiumView(
        entries: [
            LeaderboardEntry(id: UUID(), rank: 1, streakCount: 67, totalLogs: 200, flushFunds: 1000, lastSeenAt: Date()),
            LeaderboardEntry(id: UUID(), rank: 2, streakCount: 45, totalLogs: 120, flushFunds: 500, lastSeenAt: Date()),
            LeaderboardEntry(id: UUID(), rank: 3, streakCount: 32, totalLogs: 90, flushFunds: 300, lastSeenAt: Date())
        ],
        metric: .streak
    )
    .padding()
    .background(Color.ppBackground)
}

