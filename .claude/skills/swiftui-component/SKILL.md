---
name: swiftui-component
description: Expert at creating reusable SwiftUI components following the PoopyPals design system. Use when creating new UI components, refactoring views, or building design system elements. Specializes in PPColors, PPTypography, PPSpacing patterns.
---

# SwiftUI Component Creation

Expert skill for building production-ready SwiftUI components that follow the PoopyPals design system and best practices.

## When to Use This Skill

- Creating new reusable UI components
- Building design system components in `Core/DesignSystem/Components/`
- Refactoring large views into smaller, composable components
- Ensuring design system compliance in UI code
- Implementing custom SwiftUI modifiers

## Design System Requirements

### Always Use Design Tokens

**Colors:**
```swift
// ✅ CORRECT
.foregroundColor(.ppPrimary)
.background(.ppSecondary)

// ❌ WRONG
.foregroundColor(.blue)
.background(Color(hex: "#6366F1"))
```

**Typography:**
```swift
// ✅ CORRECT
.font(.ppTitle1)
.font(.ppBody)

// ❌ WRONG
.font(.system(size: 16))
.font(.custom("SF Pro", size: 28))
```

**Spacing:**
```swift
// ✅ CORRECT
.padding(PPSpacing.md)
.padding(.vertical, PPSpacing.lg)

// ❌ WRONG
.padding(16)
.padding(.vertical, 24)
```

**Corner Radius & Shadows:**
```swift
// ✅ CORRECT
.cornerRadius(PPCornerRadius.md)
.shadow(color: PPShadow.medium.color, radius: PPShadow.medium.radius)

// ❌ WRONG
.cornerRadius(12)
.shadow(radius: 8)
```

## Component Structure Template

```swift
import SwiftUI

/// Brief description of what this component does
///
/// Usage example:
/// ```swift
/// PPMyComponent(title: "Hello") {
///     // Action
/// }
/// ```
struct PPMyComponent: View {
    // MARK: - Properties
    let title: String
    let action: () -> Void

    // MARK: - State (if needed)
    @State private var isPressed = false

    // MARK: - Body
    var body: some View {
        VStack(spacing: PPSpacing.md) {
            headerSection
            contentSection
        }
        .padding(PPSpacing.md)
    }

    // MARK: - Subviews
    private var headerSection: some View {
        Text(title)
            .font(.ppTitle2)
            .foregroundColor(.ppTextPrimary)
    }

    private var contentSection: some View {
        // Content implementation
        EmptyView()
    }
}

// MARK: - Preview
#Preview {
    PPMyComponent(title: "Preview") {
        print("Action triggered")
    }
}
```

## Best Practices

### 1. Extract Subviews for Readability

Keep `body` under 30 lines by extracting computed properties:

```swift
var body: some View {
    VStack {
        headerSection
        contentSection
        footerSection
    }
}

private var headerSection: some View {
    HStack {
        Text("Header")
            .font(.ppTitle1)
        Spacer()
    }
}
```

### 2. Use @ViewBuilder for Flexible Content

```swift
struct PPCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(PPSpacing.md)
            .background(.ppBackground)
            .cornerRadius(PPCornerRadius.md)
    }
}
```

### 3. Support Accessibility

```swift
Button(action: save) {
    Image(systemName: "checkmark")
}
.accessibilityLabel("Save")
.accessibilityHint("Saves your current changes")
```

### 4. Add Preview Variations

```swift
#Preview("Default") {
    PPMyComponent(title: "Default")
}

#Preview("Dark Mode") {
    PPMyComponent(title: "Dark")
        .preferredColorScheme(.dark)
}

#Preview("Large Text") {
    PPMyComponent(title: "Large")
        .environment(\.sizeCategory, .accessibilityExtraLarge)
}
```

### 5. Use Proper Modifiers Order

```swift
// Correct order: content → layout → visual → accessibility
Text("Hello")
    .font(.ppBody)              // Content
    .padding(PPSpacing.md)      // Layout
    .background(.ppPrimary)     // Visual
    .accessibilityLabel("Greeting") // Accessibility
```

## Component Checklist

Before considering a component complete, verify:

- [ ] Uses design system tokens (colors, typography, spacing)
- [ ] Has extracted subviews (body < 30 lines)
- [ ] Includes documentation comments
- [ ] Has at least one SwiftUI preview
- [ ] Supports accessibility (labels, hints, traits)
- [ ] Supports Dynamic Type (no fixed sizes)
- [ ] Supports Dark Mode (uses semantic colors)
- [ ] Has proper MARK comments for organization
- [ ] Follows naming convention (PP prefix for design system)
- [ ] Is saved in correct location (`Core/DesignSystem/Components/` for reusable)

## Common Component Patterns

### Button with Haptics

```swift
struct PPButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            Text(title)
                .font(.ppBody)
                .foregroundColor(.ppTextPrimary)
                .padding(PPSpacing.md)
                .background(.ppPrimary)
                .cornerRadius(PPCornerRadius.sm)
        }
    }
}
```

### Card with Gradient

```swift
struct PPGradientCard<Content: View>: View {
    let gradient: LinearGradient
    let content: Content

    init(gradient: LinearGradient = PPGradients.sunset,
         @ViewBuilder content: () -> Content) {
        self.gradient = gradient
        self.content = content()
    }

    var body: some View {
        content
            .padding(PPSpacing.lg)
            .background(gradient)
            .cornerRadius(PPCornerRadius.md)
            .shadow(
                color: PPShadow.medium.color,
                radius: PPShadow.medium.radius,
                x: PPShadow.medium.x,
                y: PPShadow.medium.y
            )
    }
}
```

### Animated Component

```swift
struct PPAnimatedBadge: View {
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(.ppLabel)
            .foregroundColor(.white)
            .padding(.horizontal, PPSpacing.sm)
            .padding(.vertical, PPSpacing.xs)
            .background(Capsule().fill(.ppAccent))
            .scaleEffect(count > 0 ? 1.0 : 0.1)
            .animation(.spring(response: 0.3), value: count)
    }
}
```

## File Naming & Location

### Design System Components
Location: `Core/DesignSystem/Components/`
Naming: `PP{ComponentName}.swift`
Example: `PPButton.swift`, `PPCard.swift`, `PPTextField.swift`

### Feature-Specific Components
Location: `Features/{FeatureName}/Views/Components/`
Naming: `{ComponentName}.swift`
Example: `QuickLogButton.swift`, `StreakBadge.swift`

## References

- Design system colors: `Core/DesignSystem/Colors/PPColors.swift`
- Typography: `Core/DesignSystem/Typography/PPTypography.swift`
- Spacing: `Core/DesignSystem/Spacing/PPSpacing.swift`
- Existing components: `Core/DesignSystem/Components/`
- Design guidelines: `docs/04-design-system.md`

## Common Mistakes to Avoid

1. **Hard-coding values** - Always use design tokens
2. **Massive body properties** - Extract subviews
3. **Missing accessibility** - Add labels and hints
4. **No previews** - Always include at least one
5. **Breaking naming conventions** - PP prefix for design system components
6. **Forgetting Dark Mode** - Test in both color schemes
7. **Fixed sizes** - Use relative sizing for Dynamic Type support
8. **No documentation** - Add doc comments for public APIs
