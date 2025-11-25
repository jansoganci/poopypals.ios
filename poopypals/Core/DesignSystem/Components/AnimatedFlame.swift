//
//  AnimatedFlame.swift
//  PoopyPals
//
//  Animated flame effect for streak visualization
//

import SwiftUI

struct AnimatedFlame: View {
    let streakCount: Int
    let size: CGFloat

    @State private var flameScale: CGFloat = 1.0
    @State private var flameRotation: Double = 0
    @State private var glowOpacity: Double = 0.6

    init(streakCount: Int, size: CGFloat = 50) {
        self.streakCount = streakCount
        self.size = size
    }

    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(flameColor.opacity(glowOpacity))
                .frame(width: size * 1.5, height: size * 1.5)
                .blur(radius: 20)

            // Flame emoji (animated)
            Text("🔥")
                .font(.system(size: size))
                .scaleEffect(flameScale)
                .rotationEffect(.degrees(flameRotation))
        }
        .onAppear {
            startFlameAnimation()
        }
    }

    private var flameColor: Color {
        // Flame color changes based on streak length (Memeverse colors)
        switch streakCount {
        case 0...3: return .ppPlayfulOrange.opacity(0.3)
        case 4...7: return .ppPlayfulOrange
        case 8...30: return .ppFlameOrange  // Deep orange
        case 31...99: return .ppFunAlert
        default: return .ppFlameRed  // Dark red for 100+
        }
    }

    private func startFlameAnimation() {
        // Pulsing animation
        withAnimation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true)
        ) {
            flameScale = 1.1
            glowOpacity = 0.8
        }

        // Subtle rotation wiggle
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            flameRotation = 5
        }
    }
}

// MARK: - Flame Particle Effect (Advanced)

struct FlameParticle: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let startY: CGFloat
    let endY: CGFloat
    let size: CGFloat
    let delay: Double
}

struct FlameParticleView: View {
    let streakCount: Int
    @State private var particles: [FlameParticle] = []
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.ppPlayfulOrange, .ppFunAlert, .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(
                        x: particle.startX,
                        y: isAnimating ? particle.endY : particle.startY
                    )
                    .opacity(isAnimating ? 0 : 0.8)
                    .blur(radius: 2)
            }
        }
        .onAppear {
            generateParticles()
            startParticleAnimation()
        }
    }

    private func generateParticles() {
        particles = (0..<5).map { index in
            FlameParticle(
                startX: 50 + CGFloat.random(in: -10...10),
                startY: 50,
                endY: -20,
                size: CGFloat.random(in: 4...8),
                delay: Double(index) * 0.2
            )
        }
    }

    private func startParticleAnimation() {
        withAnimation(
            .easeOut(duration: 1.5)
            .repeatForever(autoreverses: false)
        ) {
            isAnimating = true
        }
    }
}

// MARK: - Streak Badge (Complete Component)

struct StreakBadge: View {
    let streakCount: Int
    let showParticles: Bool

    init(streakCount: Int, showParticles: Bool = true) {
        self.streakCount = streakCount
        self.showParticles = showParticles
    }

    var body: some View {
        ZStack {
            if showParticles && streakCount >= 7 {
                // Particles for 7+ day streaks
                FlameParticleView(streakCount: streakCount)
            }

            VStack(spacing: PPSpacing.xxs) {
                AnimatedFlame(streakCount: streakCount, size: 60)

                AnimatedNumber(
                    value: streakCount,
                    font: .ppNumberLarge,
                    color: .ppTextPrimary
                )

                Text(streakCount == 1 ? "Day" : "Days")
                    .font(.ppLabel)
                    .foregroundColor(.ppTextSecondary)
            }
        }
        .frame(width: 120, height: 120)
    }
}

// MARK: - Preview

#Preview {
    struct FlamePreview: View {
        @State private var streak = 0

        var body: some View {
            VStack(spacing: PPSpacing.xl) {
                StreakBadge(streakCount: streak)

                HStack {
                    Button("Reset") {
                        streak = 0
                    }

                    Button("+1 Day") {
                        streak += 1
                        HapticManager.shared.streakMilestone()
                    }

                    Button("+7 Days") {
                        streak += 7
                        HapticManager.shared.achievementUnlocked()
                    }
                }
                .bounceEffect()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient.ppGradient(PPGradients.peachYellow)
            )
        }
    }

    return FlamePreview()
}
