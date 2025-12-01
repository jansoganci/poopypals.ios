//
//  CurrentUserRankCard.swift
//  PoopyPals
//
//  Current user rank card (shown when user is outside top 100)
//

import SwiftUI

struct CurrentUserRankCard: View {
    let entry: LeaderboardEntry
    let metric: LeaderboardMetric
    
    var body: some View {
        GlossyCard(gradient: PPGradients.mintLavender) {
            VStack(spacing: PPSpacing.md) {
                Text("Your Rank")
                    .font(.ppTitle3)
                    .foregroundColor(.ppTextPrimary)
                
                Text("#\(entry.rank)")
                    .font(.ppNumberLarge)
                    .foregroundColor(.ppAccent)
                
                HStack(spacing: PPSpacing.sm) {
                    Image(systemName: metric.icon)
                        .foregroundColor(.ppAccent)
                    
                    Text("\(metricValue) \(metric.displayName)")
                        .font(.ppBody)
                        .foregroundColor(.ppTextSecondary)
                }
            }
            .padding(PPSpacing.lg)
        }
        .padding(.horizontal, PPSpacing.lg)
    }
    
    private var metricValue: Int {
        switch metric {
        case .streak: return entry.streakCount
        case .totalLogs: return entry.totalLogs
        case .flushFunds: return entry.flushFunds
        }
    }
}

#Preview {
    CurrentUserRankCard(
        entry: LeaderboardEntry(
            id: UUID(),
            rank: 150,
            streakCount: 10,
            totalLogs: 30,
            flushFunds: 100,
            lastSeenAt: Date()
        ),
        metric: .streak
    )
    .padding()
    .background(Color.ppBackground)
}

