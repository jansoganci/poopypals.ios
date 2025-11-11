//
//  View+Animations.swift
//  PoopyPals
//
//  Reusable animation modifiers
//

import SwiftUI

// MARK: - Slide In Animations

extension View {
    /// Slide in from specified edge with optional delay
    func slideIn(
        from edge: Edge = .bottom,
        delay: Double = 0,
        duration: Double = 0.4
    ) -> some View {
        self.modifier(SlideInModifier(edge: edge, delay: delay, duration: duration))
    }

    /// Slide and fade in
    func slideAndFadeIn(
        from edge: Edge = .bottom,
        delay: Double = 0
    ) -> some View {
        self.transition(
            .asymmetric(
                insertion: .move(edge: edge).combined(with: .opacity),
                removal: .opacity
            )
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: UUID())
    }
}

struct SlideInModifier: ViewModifier {
    let edge: Edge
    let delay: Double
    let duration: Double

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .offset(
                x: edge == .leading ? (isVisible ? 0 : -UIScreen.main.bounds.width) :
                   edge == .trailing ? (isVisible ? 0 : UIScreen.main.bounds.width) : 0,
                y: edge == .top ? (isVisible ? 0 : -UIScreen.main.bounds.height) :
                   edge == .bottom ? (isVisible ? 0 : UIScreen.main.bounds.height) : 0
            )
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: duration, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Scale Animations

extension View {
    /// Scale in with bounce
    func scaleIn(delay: Double = 0) -> some View {
        self.modifier(ScaleInModifier(delay: delay))
    }

    /// Pulse animation (continuous)
    func pulse(scale: CGFloat = 1.1, duration: Double = 1.0) -> some View {
        self.modifier(PulseModifier(scale: scale, duration: duration))
    }
}

struct ScaleInModifier: ViewModifier {
    let delay: Double

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(delay)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

struct PulseModifier: ViewModifier {
    let scale: CGFloat
    let duration: Double

    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? scale : 1.0)
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Shake Animation

extension View {
    /// Shake horizontally (for errors)
    func shake(trigger: Bool) -> some View {
        self.modifier(ShakeModifier(trigger: trigger))
    }
}

struct ShakeModifier: ViewModifier {
    let trigger: Bool

    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { oldValue, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                        offset = 10
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                            offset = -10
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                            offset = 0
                        }
                    }

                    HapticManager.shared.error()
                }
            }
    }
}

// MARK: - Shimmer Effect (Loading State)

extension View {
    /// Add shimmer loading effect
    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
}

struct ShimmerModifier: ViewModifier {
    let isActive: Bool

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isActive {
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.3),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width)
                        .offset(x: phase * geometry.size.width)
                        .onAppear {
                            withAnimation(
                                .linear(duration: 1.5)
                                .repeatForever(autoreverses: false)
                            ) {
                                phase = 1
                            }
                        }
                    }
                }
            )
            .clipped()
    }
}

// MARK: - Rotation Animations

extension View {
    /// Continuous rotation
    func rotate(duration: Double = 1.0) -> some View {
        self.modifier(RotateModifier(duration: duration))
    }
}

struct RotateModifier: ViewModifier {
    let duration: Double

    @State private var rotation: Double = 0

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Fade Animations

extension View {
    /// Fade in with delay
    func fadeIn(delay: Double = 0, duration: Double = 0.3) -> some View {
        self.modifier(FadeInModifier(delay: delay, duration: duration))
    }
}

struct FadeInModifier: ViewModifier {
    let delay: Double
    let duration: Double

    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// MARK: - Preview

#Preview {
    struct AnimationPreview: View {
        @State private var showShake = false
        @State private var showSlide = false

        var body: some View {
            ScrollView {
                VStack(spacing: PPSpacing.xl) {
                    // Slide In
                    Text("Slide In from Bottom")
                        .padding()
                        .background(Color.ppPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(PPCornerRadius.sm)
                        .slideIn(from: .bottom, delay: 0.1)

                    // Scale In
                    Text("Scale In with Bounce")
                        .padding()
                        .background(Color.ppSecondary)
                        .foregroundColor(.white)
                        .cornerRadius(PPCornerRadius.sm)
                        .scaleIn(delay: 0.3)

                    // Pulse
                    Text("Pulsing")
                        .padding()
                        .background(Color.ppAccent)
                        .foregroundColor(.white)
                        .cornerRadius(PPCornerRadius.sm)
                        .pulse()

                    // Shimmer
                    RoundedRectangle(cornerRadius: PPCornerRadius.md)
                        .fill(Color.ppBackgroundSecondary)
                        .frame(height: 100)
                        .shimmer()
                        .overlay(
                            Text("Loading...")
                                .foregroundColor(.ppTextSecondary)
                        )

                    // Shake
                    Text("Tap to Shake")
                        .padding()
                        .background(Color.ppDanger)
                        .foregroundColor(.white)
                        .cornerRadius(PPCornerRadius.sm)
                        .shake(trigger: showShake)
                        .onTapGesture {
                            showShake.toggle()
                        }

                    // Rotate
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(.ppPrimary)
                        .rotate(duration: 2.0)
                }
                .padding()
            }
        }
    }

    return AnimationPreview()
}
