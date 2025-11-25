# Component Library

**PoopyPals Design System**
**Version:** 1.0.0 (Memeverse Edition)
**Last Updated:** 2025-11-25

---

## Overview

This document catalogs all 7 reusable UI components in the PoopyPals design system. Each component is built with SwiftUI, follows the Memeverse aesthetic (kawaii pastels), and uses design tokens exclusively (no hardcoded values).

**Design Philosophy:**
- **Token-Based:** All colors, typography, and spacing use PPColors, PPTypography, PPSpacing, PPGradients
- **Composable:** Components can be combined to create complex UIs
- **Accessible:** WCAG AA compliant with VoiceOver and Dynamic Type support
- **Animated:** Smooth transitions and haptic feedback enhance user experience
- **Preview-Ready:** Every component has interactive `#Preview` for rapid iteration

**Location:** `poopypals/Core/DesignSystem/Components/`

---

## Components

### 1. PPBounceButton

**Purpose:** Primary interactive button with spring animation and haptic feedback.

**Visual Description:** Full-width button with customizable style (primary/secondary/danger/ghost), optional SF Symbol icon, smooth bounce animation on press, and haptic feedback.

#### When to Use
- ✅ Primary actions (Submit, Save, Quick Log)
- ✅ Navigation triggers (Go to Settings)
- ✅ Destructive actions (Delete, Reset Streak)
- ✅ Any tap-sensitive UI element that benefits from haptic feedback

#### When NOT to Use
- ❌ Text links in paragraphs (use native `Button` instead)
- ❌ Toolbar items (iOS native buttons work better)
- ❌ List row actions (use swipe actions)

---

#### Code Examples

**Basic Usage:**
```swift
PPBounceButton(title: "Quick Log", style: .primary) {
    // Handle tap
    logBathroomVisit()
}
```

**With Icon:**
```swift
PPBounceButton(
    title: "Start Streak",
    icon: "flame.fill",
    style: .secondary
) {
    startNewStreak()
}
```

**All Styles:**
```swift
VStack(spacing: PPSpacing.md) {
    PPBounceButton(title: "Primary", style: .primary) { }
    PPBounceButton(title: "Secondary", style: .secondary) { }
    PPBounceButton(title: "Danger", style: .danger) { }
    PPBounceButton(title: "Ghost", style: .ghost) { }
}
```

**Extension Usage (Apply to Any Button):**
```swift
Button("Custom Button") {
    // action
}
.bounceEffect()  // Adds bounce animation + haptics
```

---

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String` | Required | Button text label |
| `icon` | `String?` | `nil` | Optional SF Symbol name (e.g., "flame.fill") |
| `style` | `ButtonStyleType` | `.primary` | Visual style (primary/secondary/danger/ghost) |
| `action` | `() -> Void` | Required | Closure called on tap |

**ButtonStyleType Enum:**
- `.primary` - Soft Peach background (`ppMain`), dark text
- `.secondary` - Mint background (`ppSecondary`), dark text
- `.danger` - Fun Alert pink background (`ppFunAlert`), dark text
- `.ghost` - Transparent background, peach text

---

#### Design Token Usage

**Colors:**
- `PPColors.ppMain` - Primary button background
- `PPColors.ppSecondary` - Secondary button background
- `PPColors.ppFunAlert` - Danger button background
- `PPColors.ppTextPrimary` - Button text (solid backgrounds)

**Typography:**
- `Font.ppLabelLarge` - Button text style (13pt Medium)

**Spacing:**
- `PPSpacing.xs` (8pt) - Icon-to-text gap
- `PPSpacing.sm` (12pt) - Vertical padding
- `PPSpacing.md` (16pt) - Horizontal padding
- `PPCornerRadius.sm` (8pt) - Rounded corners

**Haptics:**
- `HapticManager.shared.light()` - On press
- `HapticManager.shared.buttonTapped()` - On action

---

#### Accessibility

- ✅ **VoiceOver:** Automatically reads title + "Button"
- ✅ **Dynamic Type:** Text scales with system font size settings
- ⚠️ **Contrast:** Primary/secondary/danger styles use `ppTextPrimary` for WCAG AA compliance (4.5:1 minimum). White text on pastel backgrounds FAILS accessibility (2.3:1).
- ✅ **Minimum Touch Target:** 44pt height (iOS standard)

---

#### Composition Patterns

**Button Stack:**
```swift
VStack(spacing: PPSpacing.md) {
    PPBounceButton(title: "Save", style: .primary) { save() }
    PPBounceButton(title: "Cancel", style: .ghost) { dismiss() }
}
```

**Horizontal Actions:**
```swift
HStack(spacing: PPSpacing.sm) {
    PPBounceButton(title: "Yes", style: .primary) { confirm() }
        .frame(maxWidth: .infinity)
    PPBounceButton(title: "No", style: .secondary) { cancel() }
        .frame(maxWidth: .infinity)
}
```

---

### 2. GlossyCard

**Purpose:** 3D glassmorphism container with gradient background and glossy shine overlay.

**Visual Description:** Elevated card with customizable gradient, subtle white shine on top edge (glassmorphism effect), rounded corners, and soft shadow for depth.

#### When to Use
- ✅ Stats cards (streak count, flush funds balance)
- ✅ Achievement showcases
- ✅ Highlighted content sections
- ✅ Feature promotions
- ✅ Hero sections on home screen

#### When NOT to Use
- ❌ Text-heavy content (readability suffers on gradients)
- ❌ Form inputs (use plain backgrounds)
- ❌ List rows (too heavy visually)

---

#### Code Examples

**Basic Usage:**
```swift
GlossyCard(gradient: PPGradients.mintLavender) {
    VStack {
        Text("47")
            .font(.ppNumberLarge)
        Text("Day Streak")
            .font(.ppBody)
    }
    .padding(PPSpacing.xl)
}
```

**With Custom Shadow:**
```swift
GlossyCard(
    gradient: PPGradients.peachPink,
    shadowIntensity: 0.5  // Deeper shadow
) {
    // Content
}
```

**Real-World Example (Stats Card):**
```swift
GlossyCard(gradient: PPGradients.sunnyMint) {
    VStack(spacing: PPSpacing.md) {
        HeroPoopIcon(size: 100, showGlow: true)

        AnimatedNumber(value: streakCount)

        Text("Days Strong! 🔥")
            .font(.ppBody)
            .foregroundColor(.ppTextSecondary)
    }
    .padding(PPSpacing.xxl)
}
```

---

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `gradient` | `[Color]` | `PPGradients.peachPink` | Gradient color array (2+ colors) |
| `shadowIntensity` | `Double` | `0.3` | Shadow depth (0.0 = none, 1.0 = max) |
| `content` | `@ViewBuilder` | Required | Inner view content |

---

#### Design Token Usage

**Colors:**
- `PPGradients.*` - Any Memeverse gradient (peachPink, mintLavender, coralOrange, sunnyMint, etc.)
- `Color.white.opacity(0.4)` - Glossy shine overlay (top)

**Spacing:**
- Padding determined by inner content (use PPSpacing tokens)
- `PPCornerRadius.lg` (20pt) - Rounded corners

**Shadows:**
- `.ppShadow(.lift)` - Elevation shadow effect

---

#### Accessibility

- ✅ **VoiceOver:** Reads inner content normally (card is transparent to accessibility tree)
- ✅ **Dynamic Type:** Respects inner content font scaling
- ⚠️ **Contrast Warning:** Ensure text on gradient backgrounds meets WCAG AA (4.5:1). Avoid white text on light pastels. Use `ppTextPrimary` (near-black) for best results.
- ✅ **Reduce Motion:** Gradient is static (no animation issues)

---

#### Composition Patterns

**Card Grid:**
```swift
LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PPSpacing.md) {
    GlossyCard(gradient: PPGradients.coralOrange) { StatContent() }
    GlossyCard(gradient: PPGradients.mintLavender) { AchievementContent() }
    GlossyCard(gradient: PPGradients.sunnyMint) { StreakContent() }
}
```

**With HeroPoopIcon:**
```swift
GlossyCard(gradient: PPGradients.peachYellow) {
    VStack {
        HeroPoopIcon(size: 120, showGlow: true)  // Includes glow effect
        Text("Quick Log")
            .font(.ppTitle2)
    }
    .padding(PPSpacing.xxl)
}
```

---

### 3. AnimatedNumber

**Purpose:** Smoothly animated number counter that counts up from 0 to target value.

**Visual Description:** Number display with smooth easing animation (600ms), uses iOS 17+ `.contentTransition(.numericText())` for native digit morphing.

#### When to Use
- ✅ Stats displays (streak count, flush funds, logs this week)
- ✅ Score updates after user actions
- ✅ Dashboard metrics
- ✅ Achievement progress (e.g., "47/100")

#### When NOT to Use
- ❌ Real-time counters that update constantly (performance)
- ❌ Static labels (no need for animation)
- ❌ Currency with decimals (component only supports Int)

---

#### Code Examples

**Basic Usage:**
```swift
@State private var score = 0

AnimatedNumber(value: score)
    .onAppear {
        score = 100  // Animates from 0 to 100
    }
```

**Custom Style:**
```swift
AnimatedNumber(
    value: streakCount,
    font: .ppNumberHero,     // Large number
    color: .ppPlayfulOrange   // Custom color
)
```

**Floating "+X" Number (Gamification):**
```swift
@State private var flushFunds = 1000
@State private var floatingTrigger: Int? = nil

VStack {
    Text("Flush Funds: \(flushFunds)")
}
.floatingNumber(trigger: $floatingTrigger, color: .ppAccent)
.onTapGesture {
    flushFunds += 10
    floatingTrigger = 10  // Shows "+10" that floats up and fades
}
```

**Animated Currency with Icon:**
```swift
AnimatedCurrency(
    value: flushFunds,
    icon: "dollarsign.circle.fill",
    color: .ppAccent
)
```

---

#### Parameters

**AnimatedNumber:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `Int` | Required | Target number to animate to |
| `font` | `Font` | `.ppNumberMedium` | Typography style (32pt Bold) |
| `color` | `Color` | `.ppTextPrimary` | Text color |

**FloatingNumber:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `Int` | Required | Number to display (e.g., 10 for "+10") |
| `prefix` | `String` | `"+"` | Prefix character (use "-" for negative) |
| `color` | `Color` | `.ppAccent` | Text color |

**AnimatedCurrency:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `Int` | Required | Currency amount |
| `icon` | `String` | `"dollarsign.circle.fill"` | SF Symbol name |
| `color` | `Color` | `.ppAccent` | Icon color |

---

#### Design Token Usage

**Typography:**
- `Font.ppNumberMedium` (32pt Bold) - Default number style
- `Font.ppNumberSmall` (24pt Bold) - Currency style
- `Font.ppLabelLarge` (13pt Medium) - Floating number

**Colors:**
- `PPColors.ppTextPrimary` - Default text
- `PPColors.ppAccent` - Currency/floating number highlights

**Spacing:**
- `PPSpacing.xxs` (4pt) - Icon-to-number gap

---

#### Accessibility

- ✅ **VoiceOver:** Reads final value (animation is visual only)
- ✅ **Dynamic Type:** Font scales with system settings
- ✅ **Reduce Motion:** Animation still occurs but iOS respects user preference (can disable with `UIAccessibility.isReduceMotionEnabled`)
- ✅ **Contrast:** Uses `ppTextPrimary` by default (WCAG AA compliant)

---

#### Composition Patterns

**Stats Grid with Animated Numbers:**
```swift
HStack(spacing: PPSpacing.xl) {
    VStack {
        AnimatedNumber(value: logsThisWeek, font: .ppNumberLarge)
        Text("This Week")
            .font(.ppCaption)
    }

    VStack {
        AnimatedCurrency(value: flushFunds)
        Text("Flush Funds")
            .font(.ppCaption)
    }
}
```

**Gamified Action with Floating Number:**
```swift
Button("Quick Log") {
    logPoopVisit()
    flushFunds += 10
    floatingTrigger = 10  // "+10" appears
}
.floatingNumber(trigger: $floatingTrigger)
```

---

### 4. AnimatedFlame

**Purpose:** Animated flame emoji with pulsing glow effect for streak visualization.

**Visual Description:** 🔥 emoji with scale animation (1.0 → 1.1), subtle rotation wiggle (-5° → +5°), colored glow that changes based on streak length.

#### When to Use
- ✅ Streak count displays
- ✅ Milestone achievements
- ✅ Gamification badges
- ✅ Motivational UI elements

#### When NOT to Use
- ❌ Static informational content
- ❌ Non-streak related features
- ❌ Performance-critical views (animation runs continuously)

---

#### Code Examples

**Basic Usage:**
```swift
AnimatedFlame(streakCount: 7, size: 50)
```

**Complete Streak Badge:**
```swift
StreakBadge(streakCount: streakCount, showParticles: true)
// Displays flame + animated number + "Days" label
// Adds particle effects for 7+ day streaks
```

**Custom Size:**
```swift
AnimatedFlame(streakCount: 30, size: 100)  // Hero flame
```

**Real-World Example:**
```swift
VStack {
    AnimatedFlame(streakCount: viewModel.currentStreak, size: 60)

    AnimatedNumber(value: viewModel.currentStreak, font: .ppNumberLarge)

    Text(viewModel.currentStreak == 1 ? "Day" : "Days")
        .font(.ppLabel)
}
```

---

#### Parameters

**AnimatedFlame:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `streakCount` | `Int` | Required | Current streak length (affects glow color) |
| `size` | `CGFloat` | `50` | Flame emoji size in points |

**StreakBadge:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `streakCount` | `Int` | Required | Current streak length |
| `showParticles` | `Bool` | `true` | Enable flame particles for 7+ streaks |

---

#### Design Token Usage

**Colors (Dynamic Based on Streak):**
- 0-3 days: `PPColors.ppPlayfulOrange.opacity(0.3)` - Light orange
- 4-7 days: `PPColors.ppPlayfulOrange` - Playful orange
- 8-30 days: `PPColors.ppFlameOrange` - Deep orange
- 31-99 days: `PPColors.ppFunAlert` - Hot pink
- 100+ days: `PPColors.ppFlameRed` - Dark red (legendary)

**Typography:**
- `Font.ppNumberLarge` (48pt Bold) - Streak number in StreakBadge
- `Font.ppLabel` (13pt Medium) - "Days" label

**Spacing:**
- `PPSpacing.xxs` (4pt) - Badge internal spacing

---

#### Accessibility

- ⚠️ **VoiceOver:** Flame emoji reads as "Fire" - consider adding `.accessibilityLabel("Streak: \(streakCount) days")`
- ✅ **Dynamic Type:** Text elements scale appropriately
- ⚠️ **Reduce Motion:** Animation runs continuously (should check `UIAccessibility.isReduceMotionEnabled` and disable for accessibility)
- ✅ **Contrast:** Glow colors are decorative, text uses `ppTextPrimary`

**Accessibility Enhancement Recommendation:**
```swift
AnimatedFlame(streakCount: 7)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Current streak: 7 days")
```

---

#### Composition Patterns

**Streak Hero Section:**
```swift
VStack(spacing: PPSpacing.lg) {
    AnimatedFlame(streakCount: streak, size: 80)

    AnimatedNumber(value: streak, font: .ppNumberHero, color: .ppPlayfulOrange)

    Text("🔥 Day Streak! Keep it going!")
        .font(.ppTitle2)
}
.padding(PPSpacing.xxl)
.background(
    LinearGradient.ppGradient(PPGradients.coralOrange)
)
.cornerRadius(PPCornerRadius.lg)
```

**Streak Card with Particles:**
```swift
StreakBadge(streakCount: 10, showParticles: true)
    .frame(width: 120, height: 120)
    .onTapGesture {
        HapticManager.shared.streakMilestone()
    }
```

---

### 5. ConfettiView

**Purpose:** Celebratory confetti particle animation that falls from top of screen.

**Visual Description:** 50 colorful particles (rectangles and circles) that burst from top-center, spread horizontally as they fall, rotate randomly, and fade out over 3 seconds.

#### When to Use
- ✅ Achievement unlocks
- ✅ Milestone celebrations (100th log, 30-day streak)
- ✅ First-time user actions (first log, first streak)
- ✅ Level-ups or reward claims

#### When NOT to Use
- ❌ Every button tap (overuse dilutes impact)
- ❌ Error states or failures
- ❌ Routine actions (daily log shouldn't trigger confetti every time)

---

#### Code Examples

**Basic Usage (Standalone):**
```swift
@State private var showConfetti = false

ZStack {
    ContentView()

    if showConfetti {
        ConfettiView()
    }
}
```

**Using View Modifier (Recommended):**
```swift
@State private var celebrateAchievement = false

VStack {
    Button("Unlock Achievement") {
        celebrateAchievement = true
        HapticManager.shared.achievementUnlocked()
    }
}
.confetti(isActive: $celebrateAchievement)
// Auto-dismisses after 3 seconds
```

**Custom Particle Count & Duration:**
```swift
VStack { }
    .confetti(
        isActive: $showConfetti,
        particleCount: 100,  // More particles
        duration: 5.0        // Slower fall
    )
```

**Real-World Example (Achievement Unlock):**
```swift
.onChange(of: viewModel.newAchievement) { _, achievement in
    if achievement != nil {
        showConfetti = true
        HapticManager.shared.achievementUnlocked()
    }
}
.confetti(isActive: $showConfetti)
```

---

#### Parameters

**ConfettiView:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `particleCount` | `Int` | `50` | Number of confetti particles (10-200 recommended) |
| `duration` | `Double` | `3.0` | Animation duration in seconds (1.0-5.0 recommended) |

**View Modifier:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `isActive` | `Binding<Bool>` | Required | Controls visibility (auto-resets to false after duration) |
| `particleCount` | `Int` | `50` | Number of particles |
| `duration` | `Double` | `3.0` | Animation duration |

---

#### Design Token Usage

**Colors (Random Selection):**
- `PPColors.ppMain` (Soft Peach)
- `PPColors.ppSecondary` (Mint)
- `PPColors.ppAccent` (Sunshine Yellow)
- `PPColors.ppConfettiYellow` (Yellow)
- `PPColors.ppConfettiPink` (Bubblegum Pink)
- `PPColors.ppConfettiPurple` (Support Lavender)
- `PPColors.ppPlayfulOrange` (Playful Orange)

**Particle Sizes:** 8-16pt (randomized)

---

#### Accessibility

- ✅ **VoiceOver:** Confetti is decorative, `.allowsHitTesting(false)` ensures it doesn't block interactions
- ✅ **Reduce Motion:** Should disable animation if `UIAccessibility.isReduceMotionEnabled` is true (enhancement needed)
- ✅ **No Text:** Purely visual celebration, doesn't convey critical information
- ✅ **Non-Blocking:** Overlay doesn't interfere with screen content

**Accessibility Enhancement Recommendation:**
```swift
if !UIAccessibility.isReduceMotionEnabled {
    ConfettiView()
} else {
    // Show static celebration icon instead
    Text("🎉").font(.ppEmojiLarge)
}
```

---

#### Composition Patterns

**Achievement Unlock Flow:**
```swift
@State private var showAchievement = false
@State private var showConfetti = false

ZStack {
    MainContent()

    if showAchievement {
        AchievementCard(achievement: unlockedAchievement)
            .transition(.scale)
    }
}
.confetti(isActive: $showConfetti)
.onChange(of: viewModel.achievementUnlocked) { _, isUnlocked in
    if isUnlocked {
        showAchievement = true
        showConfetti = true
        HapticManager.shared.achievementUnlocked()
    }
}
```

**Milestone Celebration:**
```swift
.onAppear {
    if viewModel.isFirstLog {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showConfetti = true
        }
    }
}
```

---

### 6. ShareableAchievementCard

**Purpose:** Generate Instagram/TikTok-friendly achievement card images for social sharing.

**Visual Description:** 400x600pt vertical card with gradient background, achievement icon, title, description, optional streak count, and PoopyPals branding footer.

#### When to Use
- ✅ Achievement unlocks with share action
- ✅ Milestone celebrations (30-day streak, 100th log)
- ✅ Leaderboard highlights
- ✅ Social media marketing content

#### When NOT to Use
- ❌ In-app UI (use GlossyCard instead - this is for image export)
- ❌ Non-shareable content

---

#### Code Examples

**Basic Usage:**
```swift
ShareableAchievementCard(
    achievement: unlockedAchievement,
    streakCount: nil  // No streak count
)
```

**With Streak Count:**
```swift
ShareableAchievementCard(
    achievement: streakAchievement,
    streakCount: 30  // Shows "🔥 30" prominently
)
```

**Generate Image for Sharing:**
```swift
let card = ShareableAchievementCard(
    achievement: achievement,
    streakCount: currentStreak
)
let image = card.asImage()  // UIImage

// Share via UIActivityViewController
let activityVC = UIActivityViewController(
    activityItems: [image],
    applicationActivities: nil
)
present(activityVC, animated: true)
```

**Real-World Example:**
```swift
Button("Share Achievement") {
    let shareImage = ShareableAchievementCard(
        achievement: viewModel.latestAchievement,
        streakCount: viewModel.currentStreak
    ).asImage()

    shareSheet = ShareSheet(items: [shareImage])
}
.sheet(item: $shareSheet) { sheet in
    ActivityView(items: sheet.items)
}
```

---

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `achievement` | `Achievement` | Required | Achievement entity (title, description, iconName) |
| `streakCount` | `Int?` | `nil` | Optional streak number to display (shows flame icon + number) |

**Achievement Model Requirements:**
```swift
struct Achievement {
    let title: String           // e.g., "Century Club"
    let description: String     // e.g., "Log 100 bathroom visits"
    let iconName: String        // SF Symbol name (e.g., "star.fill")
}
```

---

#### Design Token Usage

**Colors:**
- `PPGradients.peachPink` - Card background (hardcoded, could be parameterized)
- `PPColors.ppTextPrimary` - Title and icon
- `PPColors.ppTextSecondary` - Description
- `PPColors.ppTextTertiary` - Footer branding

**Typography:**
- `Font.ppEmojiLarge` (64pt) - Achievement icon
- `Font.ppTitle1` (34pt Bold) - Achievement title
- `Font.ppNumberMedium` (32pt Bold) - Streak count icon
- `Font.ppNumberLarge` (48pt Bold) - Streak number
- `Font.ppBody` (15pt Regular) - Description
- `Font.ppTitle2` (28pt Semibold) - "PoopyPals" branding
- `Font.ppCaption` (11pt Regular) - Footer text

**Spacing:**
- `PPSpacing.xs/lg/xl/xxl` - Internal card padding

**Dimensions:**
- Fixed: 400x600pt (9:16 aspect ratio for social media)

---

#### Accessibility

- ⚠️ **Not for On-Screen Display:** This component is designed for image export, not live UI
- ✅ **Text on Gradient:** Uses dark `ppTextPrimary` on pastel gradient for readability
- ✅ **Alt Text for Social:** When sharing, consider adding descriptive text: "I earned the Century Club achievement in PoopyPals! 💩 30-day streak!"

---

#### Composition Patterns

**Share Sheet Integration:**
```swift
struct ShareSheet: Identifiable {
    let id = UUID()
    let items: [Any]
}

@State private var shareSheet: ShareSheet?

Button("Share") {
    let card = ShareableAchievementCard(
        achievement: achievement,
        streakCount: streak
    )
    shareSheet = ShareSheet(items: [card.asImage()])
}
.sheet(item: $shareSheet) { sheet in
    ActivityViewController(activityItems: sheet.items)
}
```

**Preview in UI Before Sharing:**
```swift
NavigationLink("Preview Share Card") {
    ShareableAchievementCard(
        achievement: achievement,
        streakCount: streak
    )
    .padding()
}
```

---

### 7. StreakCard

**Purpose:** Reusable streak summary card with flame emoji, count, and CTA button.

**Visual Description:** Vertical card with coral-orange gradient, large 🔥 emoji, bold streak number, "DAY(S) STREAK" label, and "Don't break the chain!" button.

#### When to Use
- ✅ Streak overview on dashboard
- ✅ Motivation reminders
- ✅ Streak-specific navigation (link to streak details)

#### When NOT to Use
- ❌ Inline stats (too prominent - use AnimatedFlame instead)
- ❌ Non-streak related features

---

#### Code Examples

**Basic Usage:**
```swift
StreakCard(
    streakCount: 7,
    onBreakStreak: {
        // Navigate to streak details
        navigationPath.append(.streakDetails)
    }
)
```

**Real-World Example:**
```swift
StreakCard(
    streakCount: viewModel.currentStreak,
    onBreakStreak: {
        HapticManager.shared.impact()
        viewModel.showStreakDetails()
    }
)
.padding(.horizontal, PPSpacing.lg)
```

---

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `streakCount` | `Int` | Required | Current streak length |
| `onBreakStreak` | `() -> Void` | Required | Action when button is tapped (usually navigation) |

---

#### Design Token Usage

**Colors:**
- `PPGradients.coralOrange` - Card background
- `PPColors.ppTextPrimary` - Streak number and button text
- `PPColors.ppTextSecondary` - "DAYS STREAK" label
- `PPColors.ppSurface.opacity(0.3)` - Button background (subtle)

**Typography:**
- `Font.ppEmojiLarge` (64pt) - Flame emoji
- `Font.ppNumberHero` (64pt Bold) - Streak count
- `Font.ppLabelLarge` (13pt Medium) - "DAYS STREAK" label (uppercase)
- `Font.ppButton` (15pt Semibold) - Button text

**Spacing:**
- `PPSpacing.xl` (32pt) - Section spacing
- `PPSpacing.xs` (8pt) - Button icon-to-text gap
- `PPSpacing.md` (16pt) - Button horizontal padding
- `PPSpacing.sm` (12pt) - Button vertical padding
- `PPSpacing.xxl` (48pt) - Card padding

**Other:**
- `PPCornerRadius.pill` (9999) - Fully rounded button
- `PPCornerRadius.xl` (24pt) - Card corners
- `.ppShadow(.hover)` - Card shadow
- `PPMaxWidth.card` - Max card width

---

#### Accessibility

- ✅ **VoiceOver:** Reads "7 Days Streak, Don't break the chain! Button"
- ✅ **Dynamic Type:** All text scales
- ✅ **Contrast:** Dark text on pastel gradient (WCAG AA compliant)
- ✅ **Touch Target:** Button meets 44pt minimum

---

#### Composition Patterns

**Dashboard Streak Section:**
```swift
VStack(spacing: PPSpacing.lg) {
    Text("Your Progress")
        .font(.ppTitle2)
        .foregroundColor(.ppTextPrimary)

    StreakCard(
        streakCount: viewModel.currentStreak,
        onBreakStreak: {
            navigationPath.append(.streakDetails)
        }
    )
}
```

**With AnimatedFlame Upgrade:**
```swift
// Replace static emoji with animated flame:
GlossyCard(gradient: PPGradients.coralOrange) {
    VStack(spacing: PPSpacing.xl) {
        AnimatedFlame(streakCount: streak, size: 80)  // Instead of Text("🔥")

        AnimatedNumber(value: streak, font: .ppNumberHero)

        Text(streak == 1 ? "DAY STREAK" : "DAYS STREAK")
            .font(.ppLabelLarge)
            .textCase(.uppercase)

        Button("View Details") { }
    }
    .padding(PPSpacing.xxl)
}
```

---

## Quick Reference Table

| Component | Primary Use Case | Key Props | Design Tokens | File Size |
|-----------|------------------|-----------|---------------|-----------|
| **PPBounceButton** | Interactive actions | `title`, `style`, `action` | ppMain, ppLabelLarge, PPSpacing | 121 lines |
| **GlossyCard** | Elevated content | `gradient`, `@ViewBuilder content` | PPGradients, PPCornerRadius | 141 lines |
| **AnimatedNumber** | Stat displays | `value`, `font`, `color` | ppNumberMedium, ppTextPrimary | 241 lines |
| **AnimatedFlame** | Streak visualization | `streakCount`, `size` | ppPlayfulOrange, ppFlameOrange | 208 lines |
| **ConfettiView** | Celebrations | `particleCount`, `duration` | ppMain, ppSecondary, ppAccent | 176 lines |
| **ShareableAchievementCard** | Social sharing | `achievement`, `streakCount?` | PPGradients.peachPink, ppTitle1 | 100 lines |
| **StreakCard** | Streak overview | `streakCount`, `onBreakStreak` | PPGradients.coralOrange, ppNumberHero | 62 lines |

---

## Component Decision Tree

**Need an interactive button?**
- → Use **PPBounceButton**

**Need an elevated container?**
- → Use **GlossyCard**

**Need to display a number that updates?**
- → Use **AnimatedNumber** (or AnimatedCurrency for Flush Funds)

**Need to show streak status?**
- Simple icon: → Use **AnimatedFlame**
- Complete card: → Use **StreakCard**

**Need to celebrate an event?**
- → Use **ConfettiView**

**Need to generate a shareable image?**
- → Use **ShareableAchievementCard**

---

## Common Composition Patterns

### Pattern 1: Stats Card with Animation
```swift
GlossyCard(gradient: PPGradients.sunnyMint) {
    VStack(spacing: PPSpacing.lg) {
        Text("Flush Funds")
            .font(.ppLabelLarge)
            .foregroundColor(.ppTextSecondary)

        AnimatedCurrency(value: flushFunds)

        PPBounceButton(title: "Earn More", style: .ghost) {
            // Action
        }
    }
    .padding(PPSpacing.xl)
}
```

### Pattern 2: Achievement Unlock Flow
```swift
@State private var showConfetti = false
@State private var showCard = false

VStack { }
    .onReceive(viewModel.$newAchievement) { achievement in
        guard achievement != nil else { return }

        // 1. Show confetti
        showConfetti = true
        HapticManager.shared.achievementUnlocked()

        // 2. Show achievement card after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showCard = true
        }
    }
    .confetti(isActive: $showConfetti)
    .sheet(isPresented: $showCard) {
        AchievementDetailView(achievement: viewModel.newAchievement!)
    }
```

### Pattern 3: Gamified Action with Feedback
```swift
@State private var floatingTrigger: Int? = nil

PPBounceButton(title: "Quick Log", icon: "plus.circle.fill", style: .primary) {
    viewModel.logVisit()
    floatingTrigger = 10  // Show "+10 Flush Funds"
}
.floatingNumber(trigger: $floatingTrigger, prefix: "+", color: .ppAccent)
```

---

## Design System Compliance Checklist

When creating new components, ensure:

- ✅ **All colors** use `PPColors.*` or `PPGradients.*` (no hardcoded hex codes)
- ✅ **All fonts** use `Font.pp*` typography scale (no `.system(size:)`)
- ✅ **All spacing** uses `PPSpacing.*` tokens (no hardcoded numbers)
- ✅ **All corner radii** use `PPCornerRadius.*` (no magic numbers)
- ✅ **All shadows** use `.ppShadow(.)` (no custom shadows)
- ✅ **VoiceOver support** via `.accessibilityLabel()` where needed
- ✅ **Dynamic Type support** (avoid fixed `.frame(height:)`)
- ✅ **Contrast compliance** (WCAG AA 4.5:1 minimum for text)
- ✅ **Preview included** with interactive examples
- ✅ **Documentation** in this file with usage examples

---

## Resources

**Design System Files:**
- `PPColors.swift` - Color palette (354 lines)
- `PPTypography.swift` - Typography scale (264 lines)
- `PPSpacing.swift` - Spacing system (360 lines)
- `PPGradients.swift` - Gradient library (333 lines)

**Documentation:**
- `docs/04-design-system.md` - Complete design system guide
- `docs/MEMEVERSE_MIGRATION.md` - Migration history and color mappings
- `CLAUDE.md` - Development conventions and architecture

**Related:**
- `HapticManager.swift` - Haptic feedback utility
- `View+Animations.swift` - Animation extensions

---

**Questions?** Check `docs/04-design-system.md` for design principles or `CLAUDE.md` for development conventions.

**Found a bug?** Components live in `poopypals/Core/DesignSystem/Components/` - file an issue or fix directly.

**Need a new component?** Follow the Design System Compliance Checklist above and add documentation here.
