//
//  LeaderboardRow.swift
//  PoopyPals
//
//  Leaderboard row component for rank 4+
//

import SwiftUI

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let metric: LeaderboardMetric
    
    var body: some View {
        HStack(spacing: PPSpacing.md) {
            // Rank badge
            Text("#\(entry.rank)")
                .font(.ppNumberMedium)
                .foregroundColor(.ppTextPrimary)
                .frame(width: 50, alignment: .leading)
            
            // Avatar placeholder
            Circle()
                .fill(
                    LinearGradient.ppGradient(
                        entry.isCurrentUser ? PPGradients.mintLavender : PPGradients.peachPink
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text("💩")
                        .font(.ppEmojiSmall)
                )
            
            // User info
            VStack(alignment: .leading, spacing: PPSpacing.xxs) {
                HStack {
                    Text(entry.displayName)
                        .font(.ppBody)
                        .foregroundColor(.ppTextPrimary)
                    
                    if entry.isCurrentUser {
                        Text("(You)")
                            .font(.ppCaption)
                            .foregroundColor(.ppAccent)
                    }
                }
                
                Text("\(metricValue) \(metric.displayName)")
                    .font(.ppCaption)
                    .foregroundColor(.ppTextSecondary)
            }
            
            Spacer()
            
            // Metric value
            AnimatedNumber(
                value: metricValue,
                font: .ppNumberMedium,
                color: entry.isCurrentUser ? .ppAccent : .ppTextPrimary
            )
        }
        .padding(PPSpacing.md)
        .background(
            Group {
                if entry.isCurrentUser {
                    LinearGradient.ppGradient(PPGradients.mintLavender)
                } else {
                    Color.ppSurfaceAlt
                }
            }
        )
        .cornerRadius(PPCornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: PPCornerRadius.md)
                .stroke(
                    entry.isCurrentUser
                        ? Color.white.opacity(0.3)
                        : Color.clear,
                    lineWidth: entry.isCurrentUser ? 2 : 0
                )
        )
        .ppShadow(entry.isCurrentUser ? .md : .sm)
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
    VStack(spacing: PPSpacing.sm) {
        LeaderboardRow(
            entry: LeaderboardEntry(
                id: UUID(),
                rank: 4,
                streakCount: 25,
                totalLogs: 80,
                flushFunds: 250,
                lastSeenAt: Date(),
                isCurrentUser: true
            ),
            metric: .streak
        )
        
        LeaderboardRow(
            entry: LeaderboardEntry(
                id: UUID(),
                rank: 5,
                streakCount: 20,
                totalLogs: 70,
                flushFunds: 200,
                lastSeenAt: Date(),
                isCurrentUser: false
            ),
            metric: .streak
        )
    }
    .padding()
    .background(Color.ppBackground)
}

