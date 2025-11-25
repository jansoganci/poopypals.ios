//
//  GlossyCard.swift
//  PoopyPals
//
//  SHOWMAN DESIGN - Glossy 3D cards with depth!
//

import SwiftUI

struct GlossyCard<Content: View>: View {
    let content: Content
    let gradient: [Color]
    let shadowIntensity: Double

    init(
        gradient: [Color] = PPGradients.peachPink,
        shadowIntensity: Double = 0.3,
        @ViewBuilder content: () -> Content
    ) {
        self.gradient = gradient
        self.shadowIntensity = shadowIntensity
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background gradient (using Memeverse pastels)
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Glossy overlay (top shine effect)
            LinearGradient(
                colors: [
                    Color.white.opacity(0.4),
                    Color.white.opacity(0.1),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )

            // Content
            content
        }
        .cornerRadius(PPCornerRadius.lg)
        .ppShadow(.lift)
    }
}

// MARK: - Big Hero Poop Icon

struct HeroPoopIcon: View {
    let size: CGFloat
    let showGlow: Bool

    init(size: CGFloat = 120, showGlow: Bool = true) {
        self.size = size
        self.showGlow = showGlow
    }

    var body: some View {
        ZStack {
            if showGlow {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.brown.opacity(0.6),
                                Color.brown.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: size * 0.3,
                            endRadius: size * 0.8
                        )
                    )
                    .frame(width: size * 1.5, height: size * 1.5)
                    .blur(radius: 30)
            }

            // Main poop emoji
            Text("💩")
                .font(.system(size: size))
                .ppShadow(.sm)
        }
    }
}

// NOTE: PPGradients moved to Core/DesignSystem/Colors/PPGradients.swift
// Import automatically available - use PPGradients.peachPink, .mintLavender, etc.

// MARK: - Preview

#Preview {
    VStack(spacing: PPSpacing.xl) {
        GlossyCard(gradient: PPGradients.mintLavender) {
            VStack(spacing: PPSpacing.lg) {
                HeroPoopIcon(size: 100)

                Text("Your Streak")
                    .font(.ppTitle2)
                    .foregroundColor(.ppTextPrimary)

                Text("47")
                    .font(.ppNumberLarge)
                    .foregroundColor(.ppTextPrimary)

                Text("Days Strong! 🔥")
                    .font(.ppBody)
                    .foregroundColor(.ppTextSecondary)
            }
            .padding(PPSpacing.xxl)
        }
        .padding(PPSpacing.lg)

        GlossyCard(gradient: PPGradients.coralOrange) {
            HStack(spacing: PPSpacing.md) {
                Text("🏆")
                    .font(.ppEmojiMedium)

                VStack(alignment: .leading) {
                    Text("Achievement")
                        .font(.ppCaption)
                        .foregroundColor(.ppTextSecondary)

                    Text("Century Club!")
                        .font(.ppTitle2)
                        .foregroundColor(.ppTextPrimary)
                }
            }
            .padding(PPSpacing.lg)
        }
        .padding(.horizontal, PPSpacing.lg)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.ppBackground)
}
