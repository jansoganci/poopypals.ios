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
        gradient: [Color] = [.ppPrimary, .ppSecondary],
        shadowIntensity: Double = 0.3,
        @ViewBuilder content: () -> Content
    ) {
        self.gradient = gradient
        self.shadowIntensity = shadowIntensity
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background gradient
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
        .shadow(
            color: Color.black.opacity(shadowIntensity),
            radius: 20,
            x: 0,
            y: 10
        )
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
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Vibrant Gradient Backgrounds

enum PPGradients {
    static let sunset = [
        Color(hex: "#FF6B6B"),
        Color(hex: "#FFD93D"),
        Color(hex: "#6BCB77")
    ]

    static let ocean = [
        Color(hex: "#4E54C8"),
        Color(hex: "#8F94FB")
    ]

    static let fire = [
        Color(hex: "#FF416C"),
        Color(hex: "#FF4B2B")
    ]

    static let purple = [
        Color(hex: "#667EEA"),
        Color(hex: "#764BA2")
    ]

    static let mint = [
        Color(hex: "#00F260"),
        Color(hex: "#0575E6")
    ]

    static let poopy = [
        Color(hex: "#8B4513"),  // Brown
        Color(hex: "#D2691E"),
        Color(hex: "#CD853F")
    ]
}

// MARK: - Preview

#Preview {
    VStack(spacing: PPSpacing.xl) {
        GlossyCard(gradient: PPGradients.ocean) {
            VStack(spacing: PPSpacing.lg) {
                HeroPoopIcon(size: 100)

                Text("Your Streak")
                    .font(.ppTitle2)
                    .foregroundColor(.white)

                Text("47")
                    .font(.ppNumberLarge)
                    .foregroundColor(.white)

                Text("Days Strong! 🔥")
                    .font(.ppBody)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(PPSpacing.xxl)
        }
        .padding(PPSpacing.lg)

        GlossyCard(gradient: PPGradients.fire) {
            HStack(spacing: PPSpacing.md) {
                Text("🏆")
                    .font(.system(size: 60))

                VStack(alignment: .leading) {
                    Text("Achievement")
                        .font(.ppCaption)
                        .foregroundColor(.white.opacity(0.8))

                    Text("Century Club!")
                        .font(.ppTitle2)
                        .foregroundColor(.white)
                }
            }
            .padding(PPSpacing.lg)
        }
        .padding(.horizontal, PPSpacing.lg)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.ppBackground)
}
