//
//  AnimatedNumber.swift
//  PoopyPals
//
//  Animated number counter (counts up smoothly)
//

import SwiftUI

struct AnimatedNumber: View {
    let value: Int
    let font: Font
    let color: Color

    @State private var displayValue: Double = 0

    init(
        value: Int,
        font: Font = .ppNumberMedium,
        color: Color = .ppTextPrimary
    ) {
        self.value = value
        self.font = font
        self.color = color
    }

    var body: some View {
        Text("\(Int(displayValue))")
            .font(font)
            .foregroundColor(color)
            .contentTransition(.numericText())
            .onAppear {
                animateToValue()
            }
            .onChange(of: value) { oldValue, newValue in
                animateToValue()
            }
    }

    private func animateToValue() {
        withAnimation(.easeOut(duration: 0.6)) {
            displayValue = Double(value)
        }
    }
}

// MARK: - Floating Number ("+10" that floats up and fades)

struct FloatingNumber: View {
    let value: Int
    let prefix: String
    let color: Color

    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1

    init(
        value: Int,
        prefix: String = "+",
        color: Color = .ppAccent
    ) {
        self.value = value
        self.prefix = prefix
        self.color = color
    }

    var body: some View {
        Text("\(prefix)\(value)")
            .font(.ppLabelLarge)
            .fontWeight(.bold)
            .foregroundColor(color)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    offset = -50
                    opacity = 0
                }
            }
    }
}

// MARK: - View Modifier for Floating Numbers

struct FloatingNumberModifier: ViewModifier {
    @Binding var trigger: Int?  // When this changes, show floating number
    let color: Color
    let prefix: String

    @State private var showingNumber: Int?
    @State private var numberId: UUID = UUID()

    func body(content: Content) -> some View {
        ZStack {
            content

            if let number = showingNumber {
                FloatingNumber(value: number, prefix: prefix, color: color)
                    .id(numberId)  // Force re-render
                    .onAppear {
                        // Auto-hide after animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showingNumber = nil
                        }
                    }
            }
        }
        .onChange(of: trigger) { oldValue, newValue in
            if let value = newValue {
                showingNumber = value
                numberId = UUID()  // Trigger re-render
            }
        }
    }
}

extension View {
    /// Show floating "+X" number when value changes
    func floatingNumber(
        trigger: Binding<Int?>,
        prefix: String = "+",
        color: Color = .ppAccent
    ) -> some View {
        self.modifier(FloatingNumberModifier(
            trigger: trigger,
            color: color,
            prefix: prefix
        ))
    }
}

// MARK: - Animated Currency (with icon)

struct AnimatedCurrency: View {
    let value: Int
    let icon: String
    let color: Color

    @State private var displayValue: Double = 0

    init(
        value: Int,
        icon: String = "dollarsign.circle.fill",
        color: Color = .ppAccent
    ) {
        self.value = value
        self.icon = icon
        self.color = color
    }

    var body: some View {
        HStack(spacing: PPSpacing.xxs) {
            Image(systemName: icon)
                .foregroundColor(color)

            Text("\(Int(displayValue))")
                .font(.ppNumberSmall)
                .foregroundColor(.ppTextPrimary)
                .contentTransition(.numericText())
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                displayValue = Double(value)
            }
        }
        .onChange(of: value) { oldValue, newValue in
            withAnimation(.easeOut(duration: 0.6)) {
                displayValue = Double(newValue)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    struct AnimatedNumberPreview: View {
        @State private var count = 0
        @State private var currency = 1000
        @State private var floatingTrigger: Int? = nil

        var body: some View {
            VStack(spacing: PPSpacing.xl) {
                // Animated Number
                VStack {
                    Text("Animated Number")
                        .font(.ppCaption)
                        .foregroundColor(.ppTextSecondary)

                    AnimatedNumber(value: count)

                    Button("Increment") {
                        count += 10
                    }
                    .bounceEffect()
                }

                Divider()

                // Animated Currency
                VStack {
                    Text("Animated Currency")
                        .font(.ppCaption)
                        .foregroundColor(.ppTextSecondary)

                    AnimatedCurrency(value: currency)

                    Button("Add 100 Funds") {
                        currency += 100
                    }
                    .bounceEffect()
                }

                Divider()

                // Floating Number
                VStack {
                    Text("Floating Number")
                        .font(.ppCaption)
                        .foregroundColor(.ppTextSecondary)

                    ZStack {
                        Text("Tap Me")
                            .font(.ppTitle2)
                            .padding(PPSpacing.xl)
                            .background(Color.ppBackgroundSecondary)
                            .cornerRadius(PPCornerRadius.md)
                    }
                    .floatingNumber(trigger: $floatingTrigger)
                    .onTapGesture {
                        floatingTrigger = 10
                        HapticManager.shared.success()
                    }
                }
            }
            .padding()
        }
    }

    return AnimatedNumberPreview()
}
