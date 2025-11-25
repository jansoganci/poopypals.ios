# Design System Usage Guide

**PoopyPals Design System - Memeverse Edition**
**Version:** 1.0.0
**Last Updated:** 2025-11-25

> **Practical guide** for using the Memeverse design system correctly. Learn do's, don'ts, and best practices to create beautiful, accessible interfaces.

---

## 📖 How to Use This Guide

This guide shows **side-by-side comparisons** of correct vs incorrect usage. Follow the ✅ **DO** examples and avoid the ❌ **DON'T** examples.

**Related Docs:**
- `COMPONENT_LIBRARY.md` - Component usage and props
- `DESIGN_TOKENS.md` - Complete token reference
- `04-design-system.md` - Design principles and philosophy

---

## 🎨 Color Usage Guidelines

### ✅ DO: Use Dark Text on Pastel Backgrounds

**ALWAYS use `ppTextPrimary` on pastel backgrounds for WCAG AA compliance.**

```swift
// ✅ CORRECT - Dark text on pastel (5.2:1 contrast = AA Pass)
Button("Quick Log") {
    logVisit()
}
.padding(PPSpacing.md)
.background(Color.ppMain)          // Soft Peach background
.foregroundColor(.ppTextPrimary)   // Dark purple text (CRITICAL!)
.cornerRadius(PPCornerRadius.sm)
```

**Visual Description:** Button with soft peach background, dark purple text - high contrast, easy to read.

---

### ❌ DON'T: Use White Text on Pastel Backgrounds

**NEVER use white text on `ppMain`, `ppSecondary`, or `ppAccent` - fails WCAG AA.**

```swift
// ❌ WRONG - White text on pastel (2.3:1 contrast = FAIL)
Button("Quick Log") {
    logVisit()
}
.padding(PPSpacing.md)
.background(Color.ppMain)          // Soft Peach background
.foregroundColor(.white)           // White text (FAILS ACCESSIBILITY!)
.cornerRadius(PPCornerRadius.sm)
```

**Why It's Wrong:** White on soft peach = 2.3:1 contrast ratio (WCAG requires 4.5:1 minimum).

**⚠️ CRITICAL:** This is the #1 accessibility violation in Memeverse migrations. Always use dark text on pastels!

---

### ✅ DO: Use Interactive States for Hover/Pressed

**Use predefined hover/pressed tokens - never adjust opacity manually.**

```swift
// ✅ CORRECT - Using hover state token
struct PrimaryButton: View {
    @State private var isHovered = false

    var body: some View {
        Button("Save") { }
            .padding(PPSpacing.md)
            .background(isHovered ? Color.ppMainHover : Color.ppMain)
            .foregroundColor(.ppTextPrimary)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}
```

**Visual Description:** Button darkens smoothly on hover (peach → deeper peach).

---

### ❌ DON'T: Manually Adjust Opacity for States

**Don't create your own hover states - use design tokens.**

```swift
// ❌ WRONG - Manual opacity adjustment (inconsistent)
struct PrimaryButton: View {
    @State private var isHovered = false

    var body: some View {
        Button("Save") { }
            .padding(PPSpacing.md)
            .background(Color.ppMain.opacity(isHovered ? 0.8 : 1.0))
            .foregroundColor(.ppTextPrimary)
    }
}
```

**Why It's Wrong:** Opacity creates washed-out colors instead of darker shades. Use `ppMainHover` for consistent darkening.

---

### When to Use Each Core Color

| Scenario | Color Token | Example |
|----------|-------------|---------|
| **Primary action** | `.ppMain` (Soft Peach) | "Quick Log" button, primary CTAs |
| **Secondary action** | `.ppSecondary` (Mint) | "View Details" button, secondary cards |
| **High emphasis** | `.ppAccent` (Sunshine Yellow) | Streak highlights, sparkles, emphasis |
| **Alternative highlight** | `.ppBubblegum` (Pink) | Badges, stickers, decorative elements |
| **Playful accent** | `.ppPlayfulOrange` | Hover states, callouts, warnings |
| **Tertiary info** | `.ppSupportLavender` | Tooltips, helper text backgrounds |
| **Success state** | `.ppPositive` (Green) | Success messages, completed items |
| **Warning state** | `.ppWarning` (Soft Yellow) | Mild warnings, cautions |
| **Error state** | `.ppFunAlert` (Coral) | Friendly errors, alerts |

---

### Gradient Selection Guide

| Use Case | Gradient | Colors | Feeling |
|----------|----------|--------|---------|
| **Primary cards** | `peachPink` | Peach → Pink | Warm, welcoming, primary |
| **Streak displays** | `mintLavender` | Mint → Lavender | Cool, calming, achievement |
| **Important CTAs** | `peachYellow` | Peach → Yellow | Energetic, optimistic |
| **Friendly errors** | `coralOrange` | Coral → Orange | Alert but friendly |
| **Success states** | `mintSuccess` | Mint → Green | Success, completion |
| **Mild warnings** | `yellowOrange` | Yellow → Orange | Caution, progress |
| **Fun moments** | `rainbow` | Peach → Yellow → Mint | Playful, variety |
| **Big celebrations** | `celebration` | 5-color pastel rainbow | Excitement, achievement |
| **Subtle cards** | `surfaceSubtle` | White → Blush Pink | Elegant, minimal |

**Decision Tree:**
```
Need warm feel? → peachPink, peachYellow, coralOrange
Need cool feel? → mintLavender, mintSuccess
Need high energy? → peachYellow, rainbow, celebration
Need calm/soothing? → mintLavender, surfaceSubtle
```

---

## 📝 Typography Best Practices

### ✅ DO: Use Rounded Design Fonts

**Use `.rounded` design fonts for kawaii aesthetic consistency.**

```swift
// ✅ CORRECT - Rounded fonts for Memeverse aesthetic
VStack(alignment: .leading, spacing: PPSpacing.sm) {
    Text("Your Streak")
        .font(.ppTitle1)           // 34pt Semibold Rounded
        .foregroundColor(.ppTextPrimary)

    Text("Keep it going! 🔥")
        .font(.ppBody)             // 15pt Regular Default
        .foregroundColor(.ppTextSecondary)
}
```

**Visual Description:** Title uses rounded font (soft, friendly), body uses default font (readable).

---

### ❌ DON'T: Mix System Fonts with Design Tokens

**Don't use `.system(size:)` - use typography tokens.**

```swift
// ❌ WRONG - Direct system fonts (inconsistent)
VStack(alignment: .leading, spacing: PPSpacing.sm) {
    Text("Your Streak")
        .font(.system(size: 34, weight: .semibold, design: .default))
        .foregroundColor(.ppTextPrimary)

    Text("Keep it going! 🔥")
        .font(.system(size: 15))
        .foregroundColor(.ppTextSecondary)
}
```

**Why It's Wrong:** Bypasses design system, creates inconsistency, and loses kawaii rounded aesthetic.

---

### Font Pairing Recommendations

**Proven combinations that work well together:**

#### Pattern 1: Hero Section
```swift
VStack(spacing: PPSpacing.lg) {
    Text("💩")
        .font(.ppEmojiLarge)       // 64pt emoji

    Text("47")
        .font(.ppNumberHero)       // 64pt Bold Rounded

    Text("Day Streak!")
        .font(.ppTitle2)           // 28pt Semibold Rounded

    Text("Keep logging to maintain your streak")
        .font(.ppBody)             // 15pt Regular Default
        .foregroundColor(.ppTextSecondary)
}
```

#### Pattern 2: Stat Card
```swift
VStack(spacing: PPSpacing.xs) {
    Text("This Week")
        .font(.ppLabel)            // 13pt Medium
        .foregroundColor(.ppTextSecondary)

    Text("23")
        .font(.ppNumberLarge)      // 48pt Bold Rounded
        .foregroundColor(.ppTextPrimary)

    Text("logs")
        .font(.ppCaption)          // 11pt Regular
        .foregroundColor(.ppTextTertiary)
}
```

#### Pattern 3: List Item
```swift
HStack(spacing: PPSpacing.md) {
    Image(systemName: "checkmark.circle.fill")
        .font(.ppIconMedium)       // 24pt

    VStack(alignment: .leading, spacing: PPSpacing.xxs) {
        Text("First Log")
            .font(.ppBodyLarge)    // 17pt Regular
            .foregroundColor(.ppTextPrimary)

        Text("Log your first bathroom visit")
            .font(.ppCaption)      // 11pt Regular
            .foregroundColor(.ppTextSecondary)
    }
}
```

---

### ✅ DO: Use Semantic Number Fonts

**Use dedicated number fonts for stats and metrics.**

```swift
// ✅ CORRECT - Semantic number font
VStack {
    AnimatedNumber(
        value: flushFunds,
        font: .ppNumberMedium,     // 32pt Bold Rounded (designed for numbers)
        color: .ppTextPrimary
    )

    Text("Flush Funds")
        .font(.ppLabel)
        .foregroundColor(.ppTextSecondary)
}
```

**Why It's Right:** Number fonts use tabular spacing for alignment and bold weight for prominence.

---

### ❌ DON'T: Use Body Fonts for Large Numbers

**Don't use body fonts for stats - they lack visual weight.**

```swift
// ❌ WRONG - Body font for large stat (looks weak)
VStack {
    Text("\(flushFunds)")
        .font(.ppBody)             // 15pt Regular (too small, weak)
        .foregroundColor(.ppTextPrimary)

    Text("Flush Funds")
        .font(.ppLabel)
        .foregroundColor(.ppTextSecondary)
}
```

**Why It's Wrong:** Body fonts are 15pt Regular - too small and light for prominent stats. Use `ppNumberMedium` (32pt Bold).

---

## 📏 Spacing & Layout Patterns

### ✅ DO: Use PPSpacing Tokens Exclusively

**Always use spacing tokens - creates consistent rhythm.**

```swift
// ✅ CORRECT - Token-based spacing (8pt grid)
VStack(spacing: PPSpacing.lg) {        // 24pt section gap
    HeaderView()

    ContentView()
        .padding(.horizontal, PPSpacing.md)   // 16pt side padding

    FooterButton()
        .padding(.vertical, PPSpacing.sm)     // 12pt top/bottom padding
}
```

**Visual Description:** Consistent spacing creates visual rhythm, elements feel organized and harmonious.

---

### ❌ DON'T: Use Magic Numbers

**Don't hardcode spacing values - breaks 8pt grid.**

```swift
// ❌ WRONG - Magic numbers (inconsistent, no rhythm)
VStack(spacing: 20) {              // Random number
    HeaderView()

    ContentView()
        .padding(.horizontal, 14)  // Breaks 8pt grid

    FooterButton()
        .padding(.vertical, 10)    // Random number
}
```

**Why It's Wrong:** Values don't follow 8pt grid (8, 16, 24...), creates inconsistent spacing across app.

---

### ✅ DO: Follow 8pt Grid System

**All spacing should be multiples of 4 or 8.**

```swift
// ✅ CORRECT - 8pt grid compliance
HStack(spacing: PPSpacing.md) {    // 16pt = 2 × 8 ✅
    Image(systemName: "flame.fill")
        .font(.ppIconMedium)
        .frame(width: PPWidth.icon, height: PPWidth.icon)  // 24pt = 3 × 8 ✅

    Text("Streak")
        .padding(.leading, PPSpacing.xs)   // 8pt = 1 × 8 ✅
}
```

**Why It's Right:** Multiples of 8 (8, 16, 24, 32...) create consistent visual rhythm and scale well across devices.

---

### ❌ DON'T: Use Odd Numbers

**Avoid non-grid values like 13, 17, 23 - breaks rhythm.**

```swift
// ❌ WRONG - Odd numbers break visual rhythm
HStack(spacing: 13) {              // Not divisible by 4 or 8
    Image(systemName: "flame.fill")
        .font(.ppIconMedium)
        .frame(width: 23, height: 23)  // Awkward size

    Text("Streak")
        .padding(.leading, 17)     // Random odd number
}
```

**Why It's Wrong:** 13, 17, 23 don't align with 8pt grid, creates inconsistent spacing that feels "off."

---

### Common Layout Patterns

#### Pattern 1: Stat Card
```swift
// Standard stat card layout
VStack(spacing: PPSpacing.lg) {
    // Icon
    Image(systemName: "flame.fill")
        .font(.ppIconLarge)
        .foregroundColor(.ppPlayfulOrange)

    // Number
    AnimatedNumber(value: count, font: .ppNumberLarge)

    // Label
    Text("Day Streak")
        .font(.ppLabel)
        .foregroundColor(.ppTextSecondary)
}
.frame(width: PPHeight.statCard, height: PPHeight.statCard)  // 140×140
.padding(PPSpacing.md)
.background(LinearGradient.ppGradient(PPGradients.coralOrange))
.cornerRadius(PPCornerRadius.md)
.ppShadow(.lift)
```

#### Pattern 2: List Item
```swift
// Standard list row layout
HStack(spacing: PPSpacing.md) {
    // Leading icon
    Image(systemName: icon)
        .font(.ppIconMedium)
        .foregroundColor(.ppMain)
        .frame(width: PPWidth.icon, height: PPWidth.icon)

    // Content
    VStack(alignment: .leading, spacing: PPSpacing.xxs) {
        Text(title)
            .font(.ppBodyLarge)
            .foregroundColor(.ppTextPrimary)

        Text(subtitle)
            .font(.ppCaption)
            .foregroundColor(.ppTextSecondary)
    }

    Spacer()

    // Trailing accessory
    Image(systemName: "chevron.right")
        .font(.ppIconSmall)
        .foregroundColor(.ppTextTertiary)
}
.padding(PPSpacing.md)
```

#### Pattern 3: Button Group
```swift
// Horizontal button group
HStack(spacing: PPSpacing.sm) {
    PPBounceButton(title: "Cancel", style: .ghost) {
        dismiss()
    }
    .frame(maxWidth: .infinity)

    PPBounceButton(title: "Save", style: .primary) {
        save()
    }
    .frame(maxWidth: .infinity)
}
.padding(PPSpacing.md)
```

---

## 🧩 Component Composition

### ✅ DO: Nest Components Appropriately

**BounceButton inside GlossyCard works great.**

```swift
// ✅ CORRECT - Button nested in card
GlossyCard(gradient: PPGradients.peachPink) {
    VStack(spacing: PPSpacing.lg) {
        HeroPoopIcon(size: 100)

        Text("Quick Log")
            .font(.ppTitle2)
            .foregroundColor(.ppTextPrimary)

        PPBounceButton(title: "Log Visit", icon: "plus.circle.fill", style: .primary) {
            logVisit()
        }
    }
    .padding(PPSpacing.xl)
}
```

**Visual Description:** Card provides colorful backdrop, button has clear affordance within card.

---

### ❌ DON'T: Nest GlossyCard Inside GlossyCard

**Don't nest gradient cards - creates visual chaos.**

```swift
// ❌ WRONG - Nested gradient cards (overwhelming)
GlossyCard(gradient: PPGradients.peachPink) {
    VStack {
        Text("Outer Card")

        GlossyCard(gradient: PPGradients.mintLavender) {
            Text("Inner Card")  // Too much visual noise!
                .padding(PPSpacing.md)
        }
    }
    .padding(PPSpacing.lg)
}
```

**Why It's Wrong:** Multiple gradients compete for attention, creates visual overload. Use plain backgrounds for nested containers.

---

### ✅ DO: Use StreakCard for Streak Displays

**Use pre-built StreakCard component - don't recreate manually.**

```swift
// ✅ CORRECT - Using StreakCard component
StreakCard(
    streakCount: viewModel.currentStreak,
    onBreakStreak: {
        navigationPath.append(.streakDetails)
    }
)
.padding(.horizontal, PPSpacing.lg)
```

**Why It's Right:** Consistent streak UI across app, includes animations, correct tokens, tested accessibility.

---

### ❌ DON'T: Recreate Component UI Manually

**Don't rebuild existing components from scratch.**

```swift
// ❌ WRONG - Manually recreating StreakCard (inconsistent)
VStack(spacing: PPSpacing.xl) {
    Text("🔥")
        .font(.system(size: 64))   // Not using ppEmojiLarge

    Text("\(streakCount)")
        .font(.system(size: 64))   // Not using ppNumberHero

    Text("DAYS STREAK")
        .font(.system(size: 13))   // Not using ppLabelLarge

    Button("Don't break the chain!") { }
        .padding()                 // Magic numbers
        .background(Color.gray)    // Not using design tokens
}
.background(Color.orange)          // Not using gradient
```

**Why It's Wrong:** Inconsistent styling, missing animations, no accessibility labels, doesn't match StreakCard design.

---

### Component Combinations That Work Well

#### Combination 1: GlossyCard + AnimatedNumber + BounceButton
```swift
GlossyCard(gradient: PPGradients.sunnyMint) {
    VStack(spacing: PPSpacing.lg) {
        Text("Flush Funds")
            .font(.ppLabelLarge)

        AnimatedCurrency(value: flushFunds)

        PPBounceButton(title: "Earn More", style: .ghost) {
            showShop()
        }
    }
    .padding(PPSpacing.xl)
}
```

#### Combination 2: AnimatedFlame + AnimatedNumber
```swift
VStack(spacing: PPSpacing.md) {
    AnimatedFlame(streakCount: streak, size: 60)

    AnimatedNumber(value: streak, font: .ppNumberLarge)

    Text(streak == 1 ? "Day" : "Days")
        .font(.ppLabel)
        .foregroundColor(.ppTextSecondary)
}
```

#### Combination 3: ConfettiView + ShareableAchievementCard
```swift
ZStack {
    MainContent()

    if showAchievement {
        ShareableAchievementCard(
            achievement: unlockedAchievement,
            streakCount: currentStreak
        )
        .transition(.scale)
    }
}
.confetti(isActive: $showConfetti)
.onChange(of: viewModel.achievementUnlocked) { _, unlocked in
    if unlocked {
        showConfetti = true
        showAchievement = true
        HapticManager.shared.achievementUnlocked()
    }
}
```

---

## ♿ Accessibility Guidelines

### ✅ DO: Test All Color Combinations

**Use WCAG contrast checker for all text/background pairs.**

```swift
// ✅ CORRECT - High contrast text (tested)
VStack {
    Text("Important Message")
        .font(.ppBody)
        .foregroundColor(.ppTextPrimary)   // #2E1135 Dark Purple
        .padding(PPSpacing.md)
        .background(Color.ppMain)          // #FFB8A0 Soft Peach
        // Contrast: 5.2:1 (AA Pass ✅)
}
```

**Contrast Ratios (WCAG AA = 4.5:1 minimum):**
- ppTextPrimary on ppSurface: 12.3:1 (AAA ✅)
- ppTextPrimary on ppMain: 5.2:1 (AA ✅)
- ppTextPrimary on ppAccent: 7.1:1 (AA ✅)
- White on ppMain: 2.3:1 (FAIL ❌)

---

### ❌ DON'T: Use Color Alone for Information

**Don't rely on color to convey meaning - add icons or text.**

```swift
// ❌ WRONG - Color alone conveys state (fails accessibility)
HStack {
    Circle()
        .fill(isOnline ? Color.ppPositive : Color.ppFunAlert)
        .frame(width: 8, height: 8)

    Text("Status")
        .font(.ppBody)
}
```

**Why It's Wrong:** Color-blind users can't distinguish green from red. Add text or icons.

**✅ CORRECT VERSION:**
```swift
HStack(spacing: PPSpacing.xs) {
    Image(systemName: isOnline ? "checkmark.circle.fill" : "xmark.circle.fill")
        .foregroundColor(isOnline ? .ppPositive : .ppFunAlert)

    Text(isOnline ? "Online" : "Offline")  // Text label (CRITICAL!)
        .font(.ppBody)
}
```

---

### ✅ DO: Add Outlines to Low-Contrast Elements

**Use 2-3pt `ppOutline` strokes on decorative pastels.**

```swift
// ✅ CORRECT - Outline improves visibility
Circle()
    .fill(Color.ppAccent)          // Sunshine Yellow (low contrast on white)
    .frame(width: 40, height: 40)
    .overlay(
        Circle()
            .stroke(Color.ppOutline, lineWidth: 2)  // 2pt pink outline
    )
```

**Why It's Right:** Outline separates low-contrast element from background, improves visibility.

---

### ❌ DON'T: Use ppAccent for Critical Text

**Yellow is hard to see on light backgrounds - use for decoration only.**

```swift
// ❌ WRONG - Yellow text is hard to read
Text("Important: Your streak expires tomorrow!")
    .font(.ppBody)
    .foregroundColor(.ppAccent)    // Sunshine Yellow (1.3:1 on white = FAIL)
```

**Why It's Wrong:** ppAccent on ppBackground = 1.3:1 contrast (far below 4.5:1 minimum).

**✅ CORRECT VERSION:**
```swift
HStack(spacing: PPSpacing.xs) {
    Image(systemName: "exclamationmark.triangle.fill")
        .foregroundColor(.ppAccent)        // Icon can be decorative

    Text("Important: Your streak expires tomorrow!")
        .font(.ppBody)
        .foregroundColor(.ppTextPrimary)   // Dark text (readable!)
}
```

---

### VoiceOver Testing Checklist

**Test these scenarios with VoiceOver enabled (Cmd+F5):**

- [ ] All interactive elements are focusable
- [ ] Buttons announce as "Button" + label
- [ ] Images have `.accessibilityLabel()` if meaningful
- [ ] Decorative images use `.accessibilityHidden(true)`
- [ ] Complex components have custom accessibility labels
- [ ] Numbers are read naturally ("47 days", not "four seven days")
- [ ] Navigation order is logical (top to bottom, left to right)

**Example:**
```swift
AnimatedFlame(streakCount: 7)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Current streak: 7 days")
```

---

### Dynamic Type Support Requirements

**All text must scale with system font size settings.**

```swift
// ✅ CORRECT - Text scales automatically
Text("Welcome")
    .font(.ppTitle1)               // Scales with Dynamic Type

// ❌ WRONG - Fixed height prevents scaling
Text("Welcome")
    .font(.ppTitle1)
    .frame(height: 40)             // Clips text when user increases font size
```

**Best Practices:**
- ✅ Use `.fixedSize()` sparingly
- ✅ Avoid hardcoded `.frame(height:)` on text
- ✅ Test with largest accessibility font size (Settings → Accessibility → Display & Text Size)
- ✅ Use `.minimumScaleFactor()` for single-line labels that must fit

---

## 🎬 Animation Guidelines

### ✅ DO: Use BounceButton for Primary Actions

**BounceButton provides satisfying haptic feedback.**

```swift
// ✅ CORRECT - BounceButton for main action
PPBounceButton(
    title: "Quick Log",
    icon: "plus.circle.fill",
    style: .primary
) {
    logBathroomVisit()
}
```

**Why It's Right:** Built-in bounce animation + haptics = satisfying interaction. Users know the action succeeded.

---

### ❌ DON'T: Over-Animate Everything

**Too many animations = visual chaos and cognitive overload.**

```swift
// ❌ WRONG - Every element animates (overwhelming)
VStack {
    Text("Title")
        .scaleEffect(isAnimating ? 1.2 : 1.0)        // Pulsing title
        .animation(.easeInOut.repeatForever())

    AnimatedFlame(streakCount: 7)                     // Flame animates
        .rotationEffect(.degrees(rotation))           // + rotation
        .animation(.linear.repeatForever())

    AnimatedNumber(value: count)                      // Number animates

    ConfettiView()                                    // Confetti falling
}
.background(
    LinearGradient.ppGradient(PPGradients.rainbow)
        .offset(x: gradientOffset)                    // Gradient moves
        .animation(.linear.repeatForever())
)
```

**Why It's Wrong:** 5+ simultaneous animations create sensory overload. Users can't focus. Reduce to 1-2 animations max.

---

### ✅ DO: Use ConfettiView for Major Celebrations

**Confetti is perfect for achievement unlocks and milestones.**

```swift
// ✅ CORRECT - Confetti for achievement (rare, special moment)
.onChange(of: viewModel.achievementUnlocked) { _, unlocked in
    if unlocked {
        showConfetti = true
        HapticManager.shared.achievementUnlocked()
    }
}
.confetti(isActive: $showConfetti)
```

**When to Use:**
- ✅ First achievement unlock
- ✅ Major milestones (100th log, 30-day streak)
- ✅ Level-ups or rare events

---

### ❌ DON'T: Use Confetti for Errors or Warnings

**Confetti celebrates success - don't use for negative events.**

```swift
// ❌ WRONG - Confetti for error (confusing signal)
.onChange(of: viewModel.errorOccurred) { _, hasError in
    if hasError {
        showConfetti = true  // ??? Celebrating an error?
    }
}
.confetti(isActive: $showConfetti)
```

**Why It's Wrong:** Confetti signals celebration/success. Using it for errors sends mixed signals. Use subtle error states instead.

---

### Animation Timing Recommendations

| Animation Type | Duration | Easing | Use Case |
|----------------|----------|--------|----------|
| **Button press** | 0.3s | Spring | BounceButton, tap feedback |
| **Number count** | 0.6s | Ease Out | AnimatedNumber, stats |
| **Card appear** | 0.4s | Ease In-Out | Modal presentation |
| **Confetti** | 3.0s | Ease Out | Celebration particles |
| **Flame pulse** | 0.8s | Ease In-Out | AnimatedFlame glow |
| **Floating text** | 1.5s | Ease Out | FloatingNumber "+10" |

**Rule of Thumb:**
- Quick feedback: 0.2-0.4s
- Visual transitions: 0.4-0.6s
- Celebrations: 1.5-3.0s
- Subtle loops: 0.8-1.2s

---

### When to Use AnimatedNumber vs Static Text

**Decision Tree:**
```
Value changes frequently (real-time)?
  → NO → Use AnimatedNumber (e.g., daily stats)
  → YES → Use static Text (avoid constant animation)

Value is emphasized (hero stat)?
  → YES → Use AnimatedNumber
  → NO → Use static Text

User triggers the change?
  → YES → Use AnimatedNumber (satisfying feedback)
  → NO → Consider static Text
```

**Examples:**

✅ **Use AnimatedNumber:**
- Streak count (changes daily, emphasized)
- Flush funds (user-triggered changes)
- Achievement progress (visual reward)

❌ **Use Static Text:**
- Current time (changes every second - too frequent)
- List of logs (too many numbers animating at once)
- Timestamps (not emphasized)

---

## 🚨 Common Mistakes & Fixes

### Mistake 1: Hardcoding Color Hex Values

**Problem:**
```swift
// ❌ WRONG
Text("Hello")
    .foregroundColor(Color(hex: "#FFB8A0"))
```

**Fix:**
```swift
// ✅ CORRECT
Text("Hello")
    .foregroundColor(.ppMain)
```

**Why:** Hardcoded hex values bypass design tokens, break theming, and can't be updated globally.

---

### Mistake 2: White Text on Pastels

**Problem:**
```swift
// ❌ WRONG - Fails WCAG (2.3:1)
Button("Save") { }
    .foregroundColor(.white)
    .background(Color.ppMain)
```

**Fix:**
```swift
// ✅ CORRECT - Passes WCAG (5.2:1)
Button("Save") { }
    .foregroundColor(.ppTextPrimary)
    .background(Color.ppMain)
```

**Why:** White on soft peach = 2.3:1 contrast (WCAG requires 4.5:1). Use dark purple text instead.

---

### Mistake 3: Inconsistent Spacing

**Problem:**
```swift
// ❌ WRONG - Random padding values
VStack {
    Text("Title")
        .padding(14)
    Text("Body")
        .padding(18)
}
```

**Fix:**
```swift
// ✅ CORRECT - Token-based spacing
VStack {
    Text("Title")
        .padding(PPSpacing.md)    // 16pt
    Text("Body")
        .padding(PPSpacing.md)    // 16pt (consistent!)
}
```

**Why:** Random numbers create visual inconsistency. Tokens ensure 8pt grid compliance.

---

### Mistake 4: Not Using Component Library

**Problem:**
```swift
// ❌ WRONG - Rebuilding button manually
Button(action: { save() }) {
    HStack {
        Image(systemName: "checkmark")
        Text("Save")
    }
    .padding()
    .background(Color.green)
    .cornerRadius(8)
}
```

**Fix:**
```swift
// ✅ CORRECT - Using PPBounceButton
PPBounceButton(title: "Save", icon: "checkmark", style: .primary) {
    save()
}
```

**Why:** Component library provides animations, haptics, accessibility, and consistent styling.

---

### Mistake 5: Nesting Gradient Cards

**Problem:**
```swift
// ❌ WRONG - Visual chaos
GlossyCard(gradient: PPGradients.peachPink) {
    GlossyCard(gradient: PPGradients.mintLavender) {
        Text("Content")
    }
}
```

**Fix:**
```swift
// ✅ CORRECT - Plain inner container
GlossyCard(gradient: PPGradients.peachPink) {
    VStack {
        Text("Content")
    }
    .padding(PPSpacing.md)
    .background(Color.ppSurface)
    .cornerRadius(PPCornerRadius.sm)
}
```

**Why:** Multiple gradients compete for attention. Use plain backgrounds for nested containers.

---

### Mistake 6: Ignoring Touch Target Sizes

**Problem:**
```swift
// ❌ WRONG - Touch target too small (32pt < 44pt minimum)
Button("Tap") { }
    .frame(width: 32, height: 32)
```

**Fix:**
```swift
// ✅ CORRECT - Meets iOS HIG minimum (48pt > 44pt)
Button("Tap") { }
    .frame(height: PPHeight.button)  // 48pt
```

**Why:** iOS HIG requires minimum 44pt touch targets. 48pt provides comfortable tap area.

---

### Mistake 7: Missing Accessibility Labels

**Problem:**
```swift
// ❌ WRONG - Icon button with no label
Button(action: { delete() }) {
    Image(systemName: "trash")
}
```

**Fix:**
```swift
// ✅ CORRECT - Explicit accessibility label
Button(action: { delete() }) {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete log")
```

**Why:** VoiceOver users need descriptive labels. "trash" alone doesn't explain the action.

---

## 📋 Quick Decision Trees

### Which Color to Use?

```
Primary action? → .ppMain (Soft Peach)
Secondary action? → .ppSecondary (Mint)
High emphasis? → .ppAccent (Sunshine Yellow)
Success state? → .ppPositive (Green)
Error state? → .ppFunAlert (Coral)
Warning state? → .ppWarning (Soft Yellow)
Info state? → .ppInfo (Lavender)
Background? → .ppBackground (Warm White)
Card surface? → .ppSurface (Pure White)
Text primary? → .ppTextPrimary (Dark Purple)
Text secondary? → .ppTextSecondary (Medium Purple)
```

---

### Which Typography Token?

```
Hero title? → .ppDisplayLarge (34pt Bold Rounded)
Page title? → .ppTitle1 (34pt Semibold Rounded)
Section title? → .ppTitle2 (28pt Semibold Rounded)
Body text? → .ppBody (15pt Regular)
Label? → .ppLabel (13pt Medium)
Caption? → .ppCaption (11pt Regular)
Large number? → .ppNumberLarge (48pt Bold)
Standard icon? → .ppIconMedium (24pt)
Emoji? → .ppEmojiLarge (64pt)
Button text? → .ppButton (15pt Semibold)
```

---

### Which Gradient?

```
Warm/welcoming? → peachPink (Peach → Pink)
Cool/calming? → mintLavender (Mint → Lavender)
Energetic? → peachYellow (Peach → Yellow)
Alert/warning? → coralOrange (Coral → Orange)
Success? → mintSuccess (Mint → Green)
Playful? → rainbow (3-color pastel)
Celebration? → celebration (5-color pastel)
Subtle? → surfaceSubtle (White → Blush)
```

---

### Which Spacing?

```
Tiny gap? → PPSpacing.xxs (4pt)
Small gap? → PPSpacing.xs (8pt)
Default padding? → PPSpacing.md (16pt) ⭐ Most common
Section spacing? → PPSpacing.lg (24pt)
Large spacing? → PPSpacing.xl (32pt)
Hero padding? → PPSpacing.xxl (48pt)
```

---

### Which Component?

```
Need button? → PPBounceButton
Need gradient container? → GlossyCard
Need number that updates? → AnimatedNumber
Need streak display? → StreakCard or AnimatedFlame
Need celebration? → ConfettiView
Need shareable image? → ShareableAchievementCard
Need animated currency? → AnimatedCurrency
```

---

## 🎓 Best Practices Summary

### Always Do ✅

1. **Use design tokens exclusively** (colors, fonts, spacing)
2. **Use dark text on pastel backgrounds** (ppTextPrimary on ppMain)
3. **Follow 8pt grid system** (8, 16, 24, 32...)
4. **Test WCAG contrast ratios** (4.5:1 minimum)
5. **Add accessibility labels** to icons and images
6. **Use component library** instead of rebuilding
7. **Limit animations** (1-2 per screen max)
8. **Support Dynamic Type** (avoid fixed heights on text)

---

### Never Do ❌

1. **Hardcode colors** (`Color(hex: "#...")`)
2. **Use white text on pastels** (fails WCAG)
3. **Use magic numbers** (`.padding(14)`)
4. **Nest gradient cards** (visual overload)
5. **Rely on color alone** for meaning
6. **Over-animate** (too many animations = chaos)
7. **Ignore touch targets** (minimum 44pt)
8. **Skip accessibility testing** (VoiceOver, Dynamic Type)

---

## 📚 Related Documentation

- **Component Library:** `docs/COMPONENT_LIBRARY.md` - How to use all 7 components
- **Design Tokens:** `docs/DESIGN_TOKENS.md` - Complete token reference
- **Design Principles:** `docs/04-design-system.md` - Philosophy and guidelines
- **Migration Guide:** `docs/MEMEVERSE_MIGRATION.md` - Color migration details
- **Developer Guide:** `CLAUDE.md` - Architecture and conventions

---

**Questions?** Check the Component Library for usage examples or Design Tokens for complete token reference.

**Found a mistake?** File an issue or submit a PR with corrections.

**Need clarification?** Consult `docs/04-design-system.md` for design philosophy and principles.
