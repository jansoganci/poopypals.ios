//
//  StreakScreen.swift
//  PoopyPals
//
//  Dedicated screen presenting the streak card in a safe-area aware layout
//

import SwiftUI

struct StreakScreen: View {
    @State private var streakCount: Int = 1

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.ppBackground
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    StreakCard(
                        streakCount: streakCount,
                        onBreakStreak: {
                            // TODO: Hook up streak action
                        }
                    )
                    .padding(.horizontal, PPSpacing.lg)

                    Spacer()
                }
                .padding(.top, geometry.safeAreaInsets.top + 20)
                .padding(.bottom, max(geometry.safeAreaInsets.bottom + 20, PPSpacing.lg))
            }
        }
    }
}

#Preview {
    StreakScreen()
}

