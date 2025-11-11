//
//  BounceButton.swift
//  PoopyPals
//
//  Animated button with bounce effect + haptics
//

import SwiftUI

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    HapticManager.shared.light()
                }
            }
    }
}

// MARK: - View Extension

extension View {
    /// Add bounce animation to any button
    func bounceEffect() -> some View {
        self.buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Pre-built Bounce Button Component

struct PPBounceButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyleType
    let action: () -> Void

    @State private var isPressed = false

    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyleType = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    enum ButtonStyleType {
        case primary
        case secondary
        case danger
        case ghost
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTapped()
            action()
        }) {
            HStack(spacing: PPSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.ppLabelLarge)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PPSpacing.sm)
            .padding(.horizontal, PPSpacing.md)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(PPCornerRadius.sm)
        }
        .buttonStyle(BounceButtonStyle())
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return .ppPrimary
        case .secondary: return .ppSecondary
        case .danger: return .ppDanger
        case .ghost: return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary, .danger: return .white
        case .ghost: return .ppPrimary
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: PPSpacing.md) {
        PPBounceButton(title: "Primary Button", icon: "flame.fill", style: .primary) {
            print("Primary tapped")
        }

        PPBounceButton(title: "Secondary Button", style: .secondary) {
            print("Secondary tapped")
        }

        PPBounceButton(title: "Danger Button", style: .danger) {
            print("Danger tapped")
        }

        PPBounceButton(title: "Ghost Button", style: .ghost) {
            print("Ghost tapped")
        }
    }
    .padding()
}
