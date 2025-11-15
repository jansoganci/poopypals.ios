---
name: design-system
description: Expert at enforcing and using the PoopyPals design system. Use when auditing code for design system compliance, creating themed components, or ensuring consistency across the app. Specializes in PPColors, PPTypography, PPSpacing, and component usage.
---

# Design System Compliance

Expert skill for ensuring strict adherence to the PoopyPals design system and maintaining visual consistency.

## When to Use This Skill

- Auditing code for design system violations
- Refactoring hard-coded values to use design tokens
- Creating new design system components
- Ensuring accessibility compliance
- Reviewing PRs for design consistency
- Debugging visual inconsistencies

## Design System Components

### Core Design Tokens

**Location:** `Core/DesignSystem/`

1. **Colors** - `Colors/PPColors.swift`
2. **Typography** - `Typography/PPTypography.swift`
3. **Spacing** - `Spacing/PPSpacing.swift`
4. **Components** - `Components/`

## Color System

### Primary Palette

```swift
// ALWAYS use these, NEVER hard-code colors
Color.ppPrimary      // #6366F1 (Indigo) - Main brand
Color.ppSecondary    // #10B981 (Green) - Success, streaks
Color.ppAccent       // #F59E0B (Amber) - CTAs, highlights
Color.ppDanger       // #EF4444 (Red) - Errors, warnings
```

### Text Colors (Semantic)

```swift
// ✅ CORRECT - Adapts to light/dark mode
Color.ppTextPrimary       // Main text
Color.ppTextSecondary     // Supporting text
Color.ppTextTertiary      // De-emphasized text

// ❌ WRONG - Hard-coded
Color.black
Color.white
Color(hex: "#000000")
```

### Background Colors

```swift
// ✅ CORRECT
Color.ppBackground           // Main background
Color.ppBackgroundSecondary  // Secondary surfaces
Color.ppBackgroundTertiary   // Tertiary surfaces

// ❌ WRONG
Color.white
Color(UIColor.systemBackground)
```

### Rating Colors

```swift
// Specific to poop ratings
Color.ppRatingGreat      // #10B981 (Green)
Color.ppRatingGood       // #3B82F6 (Blue)
Color.ppRatingOkay       // #F59E0B (Amber)
Color.ppRatingBad        // #F97316 (Orange)
Color.ppRatingTerrible   // #EF4444 (Red)

// Usage
func colorForRating(_ rating: PoopLog.Rating) -> Color {
    switch rating {
    case .great: return .ppRatingGreat
    case .good: return .ppRatingGood
    case .okay: return .ppRatingOkay
    case .bad: return .ppRatingBad
    case .terrible: return .ppRatingTerrible
    }
}
```

### Gradients

```swift
// Pre-defined gradient sets
PPGradients.sunset   // Orange → Pink
PPGradients.ocean    // Blue → Teal
PPGradients.fire     // Red → Orange
PPGradients.purple   // Purple → Pink
PPGradients.mint     // Green → Cyan
PPGradients.poopy    // Brown theme

// Usage
.background(PPGradients.sunset)
```

## Typography System

### Display Styles

```swift
// Large headings
.font(.ppDisplayLarge)   // 34pt Bold
.font(.ppDisplayMedium)  // 28pt Bold

// ❌ NEVER do this
.font(.system(size: 34, weight: .bold))
```

### Title Styles

```swift
.font(.ppTitle1)  // 28pt Semibold - Main screen titles
.font(.ppTitle2)  // 22pt Semibold - Section headers
.font(.ppTitle3)  // 18pt Semibold - Card titles

// ❌ WRONG
.font(.title)
.font(.headline)
```

### Body Styles

```swift
.font(.ppBody)        // 15pt Regular - Body text
.font(.ppBodyBold)    // 15pt Bold - Emphasized body
.font(.ppCaption)     // 13pt Regular - Captions
.font(.ppLabel)       // 13pt Medium - Labels, buttons

// ❌ WRONG
.font(.body)
.font(.system(size: 15))
```

### Number Styles

```swift
// For displaying statistics
.font(.ppNumberLarge)   // 48pt Bold - Hero numbers
.font(.ppNumberMedium)  // 32pt Bold - Stat cards
.font(.ppNumberSmall)   // 24pt Bold - Compact stats
```

### Dynamic Type Support

```swift
// ✅ All PP fonts support Dynamic Type automatically
Text("Hello")
    .font(.ppBody)  // Scales with user preferences

// ❌ Don't use fixed sizes
Text("Hello")
    .font(.system(size: 15))  // Doesn't scale
```

## Spacing System (8pt Grid)

### Spacing Values

```swift
// ALWAYS use these, NEVER hard-code spacing
PPSpacing.xs    // 8pt  - Tiny gaps between related items
PPSpacing.sm    // 12pt - Compact spacing
PPSpacing.md    // 16pt - Default padding (MOST COMMON) ⭐
PPSpacing.lg    // 24pt - Section spacing
PPSpacing.xl    // 32pt - Large gaps between sections
PPSpacing.xxl   // 48pt - Extra large spacing, screen margins

// ✅ CORRECT
.padding(PPSpacing.md)
.padding(.horizontal, PPSpacing.lg)
.padding(.vertical, PPSpacing.sm)

// ❌ WRONG
.padding(16)
.padding(.horizontal, 20)
```

### Corner Radius

```swift
PPCornerRadius.sm    // 8pt  - Small elements (buttons, tags)
PPCornerRadius.md    // 12pt - Cards, containers
PPCornerRadius.lg    // 16pt - Large cards, modals
PPCornerRadius.full  // 9999 - Circular/pill shapes

// ✅ CORRECT
.cornerRadius(PPCornerRadius.md)

// ❌ WRONG
.cornerRadius(12)
.clipShape(RoundedRectangle(cornerRadius: 12))
```

### Shadows

```swift
PPShadow.small   // Subtle elevation
PPShadow.medium  // Standard cards
PPShadow.large   // Prominent floating elements

// ✅ CORRECT
.shadow(
    color: PPShadow.medium.color,
    radius: PPShadow.medium.radius,
    x: PPShadow.medium.x,
    y: PPShadow.medium.y
)

// ❌ WRONG
.shadow(radius: 8)
.shadow(color: .black.opacity(0.2), radius: 10)
```

## Component Library

### Buttons

```swift
// Primary action button
PPBounceButton(title: "Save", style: .primary) {
    // Action
}

// Secondary button
PPBounceButton(title: "Cancel", style: .secondary) {
    // Action
}

// ✅ CORRECT - Uses design system
BounceButton(action: { /* ... */ }) {
    Text("Quick Log")
        .font(.ppLabel)
        .foregroundColor(.white)
}
.buttonStyle(BounceButtonStyle())

// ❌ WRONG - Custom styling without design tokens
Button("Save") {
    // Action
}
.padding()
.background(Color.blue)
.cornerRadius(8)
```

### Cards

```swift
// Standard card
PPCard {
    VStack(spacing: PPSpacing.md) {
        Text("Title")
            .font(.ppTitle2)
        Text("Content")
            .font(.ppBody)
    }
}

// Gradient card
GlossyCard(gradient: PPGradients.sunset) {
    VStack {
        Text("Stat")
            .font(.ppNumberMedium)
    }
}
```

### Text Fields

```swift
PPTextField(
    placeholder: "Enter notes",
    text: $notes
)

// With validation
PPTextField(
    placeholder: "Duration (seconds)",
    text: $duration,
    keyboardType: .numberPad,
    validation: { text in
        Int(text) != nil && Int(text)! > 0
    }
)
```

### Badges & Tags

```swift
PPBadge(text: "New", color: .ppAccent)

PPTag(text: "Achievement", icon: "trophy.fill")
```

## Accessibility Requirements

### Color Contrast

```swift
// ✅ CORRECT - Sufficient contrast
Text("Important")
    .foregroundColor(.ppTextPrimary)
    .background(.ppBackground)

// ❌ WRONG - Poor contrast
Text("Hard to read")
    .foregroundColor(.gray.opacity(0.5))
    .background(.white)
```

### Accessibility Labels

```swift
// ✅ CORRECT
Button(action: save) {
    Image(systemName: "checkmark")
}
.accessibilityLabel("Save log")
.accessibilityHint("Saves your bathroom log entry")

// ❌ WRONG - No accessibility
Button(action: save) {
    Image(systemName: "checkmark")
}
```

### Dynamic Type

```swift
// ✅ CORRECT - All PP fonts support Dynamic Type
Text("Scales with user settings")
    .font(.ppBody)

// ❌ WRONG - Fixed size
Text("Doesn't scale")
    .font(.system(size: 15))
```

### VoiceOver Support

```swift
// ✅ CORRECT
HStack {
    Image(systemName: "flame.fill")
    Text("\(streakCount)")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(streakCount) day streak")

// ❌ WRONG - Reads separately
HStack {
    Image(systemName: "flame.fill")
    Text("\(streakCount)")
}
// VoiceOver: "Flame image" "5"
```

## Dark Mode Support

### Always Use Semantic Colors

```swift
// ✅ CORRECT - Adapts automatically
.foregroundColor(.ppTextPrimary)
.background(.ppBackground)

// ❌ WRONG - Same in light and dark
.foregroundColor(.black)
.background(.white)
```

### Test in Both Modes

```swift
#Preview("Light Mode") {
    MyView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    MyView()
        .preferredColorScheme(.dark)
}
```

## Animation Standards

### Timing

```swift
// Standard animations
PPAnimation.quick    // 0.2s - Button taps, small changes
PPAnimation.standard // 0.3s - Default animations
PPAnimation.slow     // 0.5s - Large transitions

// ✅ CORRECT
.animation(.spring(response: 0.3), value: isExpanded)

// ❌ WRONG - Arbitrary timing
.animation(.linear(duration: 0.27), value: isExpanded)
```

### Haptic Feedback

```swift
// ALWAYS pair visual feedback with haptics
Button("Quick Log") {
    HapticManager.shared.light()  // Subtle tap
    quickLog()
}

// Success actions
HapticManager.shared.success()  // Success notification

// Achievements
HapticManager.shared.achievementUnlocked()  // Special pattern
```

## Design System Audit Checklist

Use this checklist when reviewing code:

### Colors
- [ ] No hard-coded hex colors (`Color(hex:)` only in PPColors.swift)
- [ ] No `Color.blue`, `.red`, `.green` etc.
- [ ] All colors from `PPColors`
- [ ] Semantic colors used (`.ppTextPrimary` not `.black`)
- [ ] Gradients from `PPGradients`

### Typography
- [ ] No `.font(.system(size:))` or `.font(.title)`
- [ ] All fonts from `PPTypography` (`.ppBody`, `.ppTitle1`, etc.)
- [ ] No custom font sizes
- [ ] Dynamic Type supported

### Spacing
- [ ] No hard-coded padding values
- [ ] All spacing from `PPSpacing`
- [ ] Consistent use of 8pt grid
- [ ] Corner radius from `PPCornerRadius`
- [ ] Shadows from `PPShadow`

### Components
- [ ] Using design system components when available
- [ ] Not recreating existing components
- [ ] New components follow naming (PP prefix)
- [ ] Components use design tokens internally

### Accessibility
- [ ] Accessibility labels on interactive elements
- [ ] Sufficient color contrast
- [ ] Dynamic Type support
- [ ] VoiceOver tested
- [ ] Semantic grouping where appropriate

### Dark Mode
- [ ] Tested in dark mode
- [ ] No hard-coded light-only colors
- [ ] Semantic colors used throughout

## Common Violations & Fixes

### ❌ Hard-coded Colors

```swift
// BEFORE
Text("Error")
    .foregroundColor(.red)
    .background(Color(hex: "#FF0000"))

// AFTER
Text("Error")
    .foregroundColor(.ppDanger)
    .background(.ppDanger.opacity(0.1))
```

### ❌ Custom Typography

```swift
// BEFORE
Text("Title")
    .font(.system(size: 28, weight: .semibold))

// AFTER
Text("Title")
    .font(.ppTitle1)
```

### ❌ Hard-coded Spacing

```swift
// BEFORE
VStack(spacing: 16) {
    // ...
}
.padding(20)

// AFTER
VStack(spacing: PPSpacing.md) {
    // ...
}
.padding(PPSpacing.lg)
```

### ❌ Custom Buttons

```swift
// BEFORE
Button("Save") {
    save()
}
.padding()
.background(Color.blue)
.foregroundColor(.white)
.cornerRadius(8)

// AFTER
PPBounceButton(title: "Save", style: .primary) {
    save()
}
// OR
BounceButton(action: save) {
    Text("Save")
        .font(.ppLabel)
        .foregroundColor(.white)
}
.buttonStyle(BounceButtonStyle())
```

## References

- Design system guide: `docs/04-design-system.md`
- Colors: `Core/DesignSystem/Colors/PPColors.swift`
- Typography: `Core/DesignSystem/Typography/PPTypography.swift`
- Spacing: `Core/DesignSystem/Spacing/PPSpacing.swift`
- Components: `Core/DesignSystem/Components/`
