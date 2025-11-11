//
//  ConfettiView.swift
//  PoopyPals
//
//  Confetti particle animation for celebrations
//

import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false

    let particleCount: Int
    let duration: Double

    init(particleCount: Int = 50, duration: Double = 3.0) {
        self.particleCount = particleCount
        self.duration = duration
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiShape()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(
                            x: isAnimating ? particle.endX : particle.startX,
                            y: isAnimating ? particle.endY : particle.startY
                        )
                        .opacity(isAnimating ? 0 : 1)
                }
            }
            .onAppear {
                // Generate particles
                particles = (0..<particleCount).map { _ in
                    ConfettiParticle(
                        screenWidth: geometry.size.width,
                        screenHeight: geometry.size.height
                    )
                }

                // Trigger animation
                withAnimation(.easeOut(duration: duration)) {
                    isAnimating = true
                }
            }
        }
        .allowsHitTesting(false)  // Don't block touches
    }
}

// MARK: - Confetti Particle Model

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let size: CGFloat
    let rotation: Double
    let color: Color

    init(screenWidth: CGFloat, screenHeight: CGFloat) {
        // Start from top center
        self.startX = screenWidth / 2 + CGFloat.random(in: -50...50)
        self.startY = -20

        // End position (spread out as they fall)
        self.endX = CGFloat.random(in: 0...screenWidth)
        self.endY = screenHeight + 50

        // Random size
        self.size = CGFloat.random(in: 8...16)

        // Random rotation
        self.rotation = Double.random(in: 0...360)

        // Random color from confetti palette
        let colors: [Color] = [
            .ppPrimary,
            .ppSecondary,
            .ppAccent,
            Color(hex: "#F59E0B"),  // Amber
            Color(hex: "#EC4899"),  // Pink
            Color(hex: "#8B5CF6"),  // Purple
            Color(hex: "#3B82F6"),  // Blue
        ]
        self.color = colors.randomElement() ?? .ppPrimary
    }
}

// MARK: - Confetti Shape (Rectangle or Circle)

struct ConfettiShape: Shape {
    func path(in rect: CGRect) -> Path {
        // Randomly choose rectangle or circle
        if Bool.random() {
            // Rectangle
            return Path(roundedRect: rect, cornerRadius: 2)
        } else {
            // Circle
            return Path(ellipseIn: rect)
        }
    }
}

// MARK: - View Modifier for Easy Use

struct ConfettiModifier: ViewModifier {
    @Binding var isActive: Bool
    let particleCount: Int
    let duration: Double

    func body(content: Content) -> some View {
        ZStack {
            content

            if isActive {
                ConfettiView(particleCount: particleCount, duration: duration)
                    .onAppear {
                        // Auto-dismiss after duration
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            isActive = false
                        }
                    }
            }
        }
    }
}

extension View {
    /// Add confetti explosion overlay
    func confetti(
        isActive: Binding<Bool>,
        particleCount: Int = 50,
        duration: Double = 3.0
    ) -> some View {
        self.modifier(ConfettiModifier(
            isActive: isActive,
            particleCount: particleCount,
            duration: duration
        ))
    }
}

// MARK: - Preview

#Preview {
    struct ConfettiPreview: View {
        @State private var showConfetti = false

        var body: some View {
            VStack {
                Button("Trigger Confetti") {
                    showConfetti = true
                    HapticManager.shared.achievementUnlocked()
                }
                .bounceEffect()
                .padding()
                .background(Color.ppPrimary)
                .foregroundColor(.white)
                .cornerRadius(PPCornerRadius.sm)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.ppBackground)
            .confetti(isActive: $showConfetti)
        }
    }

    return ConfettiPreview()
}
