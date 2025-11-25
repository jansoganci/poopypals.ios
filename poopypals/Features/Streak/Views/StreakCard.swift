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
                .font(.ppEmojiLarge)

            Text("\(streakCount)")
                .font(.ppNumberHero)
                .foregroundColor(.ppTextPrimary)

            Text(streakLabel)
                .font(.ppLabelLarge)
                .foregroundColor(.ppTextSecondary)
                .textCase(.uppercase)

            Button(action: onBreakStreak) {
                HStack(spacing: PPSpacing.xs) {
                    Image(systemName: "flame.fill")
                    Text("Don't break the chain!")
                }
                .font(.ppButton)
                .foregroundColor(.ppTextPrimary)
                .padding(.horizontal, PPSpacing.md)
                .padding(.vertical, PPSpacing.sm)
                .background(Color.ppSurface.opacity(0.3))
                .cornerRadius(PPCornerRadius.pill)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: PPMaxWidth.card)
        .aspectRatio(0.83, contentMode: .fit)
        .padding(PPSpacing.xxl)
        .background(
            LinearGradient.ppGradient(PPGradients.coralOrange)
        )
        .cornerRadius(PPCornerRadius.xl)
        .ppShadow(.hover)
    }
}

#Preview {
    StreakCard(streakCount: 7, onBreakStreak: {})
        .padding()
        .background(Color.ppBackground)
}

