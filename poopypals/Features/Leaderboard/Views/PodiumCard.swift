//
//  PodiumCard.swift
//  PoopyPals
//
//  Podium card component for top 3 rankings
//

import SwiftUI

struct PodiumCard: View {
    let entry: LeaderboardEntry
    let rank: Int
    let metric: LeaderboardMetric
    let gradient: [Color]
    
    private var height: CGFloat {
        switch rank {
        case 1: return 200  // Tallest
        case 2: return 160   // Medium
        case 3: return 120  // Shortest
        default: return 100
        }
    }
    
    var body: some View {
        VStack(spacing: PPSpacing.sm) {
            // Rank badge
            Text("#\(rank)")
                .font(.ppNumberLarge)
                .foregroundColor(.ppTextPrimary)
            
            // Avatar placeholder
            Circle()
                .fill(LinearGradient.ppGradient(gradient))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(rankEmoji)
                        .font(.ppEmojiMedium)
                )
            
            // Display name
            Text(entry.displayName)
                .font(.ppBody)
                .foregroundColor(.ppTextPrimary)
                .lineLimit(1)
                .frame(maxWidth: 100)
            
            // Metric value
            AnimatedNumber(
                value: metricValue,
                font: .ppNumberMedium,
                color: .ppAccent
            )
            
            // Metric label
            Text(metric.displayName)
                .font(.ppCaption)
                .foregroundColor(.ppTextSecondary)
        }
        .frame(width: 100, height: height)
        .padding(PPSpacing.md)
        .background(
            GlossyCard(gradient: gradient) {
                EmptyView()
            }
        )
    }
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏆"
        }
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
    HStack(alignment: .bottom, spacing: PPSpacing.md) {
        PodiumCard(
            entry: LeaderboardEntry(
                id: UUID(),
                rank: 2,
                streakCount: 45,
                totalLogs: 120,
                flushFunds: 500,
                lastSeenAt: Date()
            ),
            rank: 2,
            metric: .streak,
            gradient: PPGradients.mintLavender
        )
        
        PodiumCard(
            entry: LeaderboardEntry(
                id: UUID(),
                rank: 1,
                streakCount: 67,
                totalLogs: 200,
                flushFunds: 1000,
                lastSeenAt: Date()
            ),
            rank: 1,
            metric: .streak,
            gradient: PPGradients.peachYellow
        )
        
        PodiumCard(
            entry: LeaderboardEntry(
                id: UUID(),
                rank: 3,
                streakCount: 32,
                totalLogs: 90,
                flushFunds: 300,
                lastSeenAt: Date()
            ),
            rank: 3,
            metric: .streak,
            gradient: PPGradients.coralOrange
        )
    }
    .padding()
    .background(Color.ppBackground)
}

