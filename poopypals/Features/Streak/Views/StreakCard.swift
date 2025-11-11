//
//  StreakCard.swift
//  PoopyPals
//
//  Reusable streak summary card component
//

import SwiftUI

struct StreakCard: View {
    let streakCount: Int
    let onBreakStreak: () -> Void

    private var streakLabel: String {
        streakCount == 1 ? "DAY STREAK" : "DAYS STREAK"
    }

    var body: some View {
        VStack(spacing: PPSpacing.xl) {
            Text("🔥")
                .font(.system(size: 80))

            Text("\(streakCount)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(streakLabel)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.95))
                .textCase(.uppercase)

            Button(action: onBreakStreak) {
                HStack(spacing: PPSpacing.xs) {
                    Image(systemName: "flame.fill")
                    Text("Don't break the chain!")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.95))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: 350)
        .aspectRatio(0.83, contentMode: .fit)
        .padding(40)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.45, blue: 0.45),
                    Color(red: 1.0, green: 0.30, blue: 0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.18), radius: 20, x: 0, y: 12)
    }
}

#Preview {
    StreakCard(streakCount: 7, onBreakStreak: {})
        .padding()
        .background(Color(red: 0.545, green: 0.624, blue: 1.0))
}

