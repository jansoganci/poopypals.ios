# Design Tokens Quick Reference

**PoopyPals Design System - Memeverse Edition**
**Version:** 1.0.0
**Last Updated:** 2025-11-25

> **Fast-lookup reference** for developers. Copy-paste token names directly into code.

---

## 📖 How to Use This Guide

```swift
// Import SwiftUI (tokens auto-available)
import SwiftUI

// Use tokens directly
Text("Hello")
    .foregroundColor(.ppTextPrimary)      // ✅ Color token
    .font(.ppTitle1)                       // ✅ Typography token
    .padding(PPSpacing.md)                 // ✅ Spacing token
    .background(
        LinearGradient.ppGradient(PPGradients.peachPink)  // ✅ Gradient token
    )
    .cornerRadius(PPCornerRadius.md)       // ✅ Corner radius token
    .ppShadow(.lift)                       // ✅ Shadow token
```

**Files:** `PPColors.swift`, `PPTypography.swift`, `PPSpacing.swift`, `PPGradients.swift`

---

## 🎨 Colors

### Core Pastels (Primary Brand Colors)

| Token | Hex | RGB | Usage | Notes |
|-------|-----|-----|-------|-------|
| `.ppMain` | `#FFB8A0` | 255, 184, 160 | Primary brand color | Soft Peach - main CTAs, highlights |
| `.ppBubblegum` | `#FFB3D9` | 255, 179, 217 | Alternative highlight | Bubblegum Pink - stickers, badges |
| `.ppSecondary` | `#B4E7CE` | 180, 231, 206 | Secondary actions | Mint - cards, secondary buttons |
| `.ppAccent` | `#FFEC5C` | 255, 236, 92 | Emphasis, sparkles | Sunshine Yellow - streaks, highlights |
| `.ppPlayfulOrange` | `#FF9B50` | 255, 155, 80 | Hover accents | Playful Orange - callouts, hovers |
| `.ppSupportLavender` | `#C7AFFF` | 199, 175, 255 | Tertiary backgrounds | Support Lavender - tooltips, info |

**Legacy Aliases (backward compatibility):**
- `.ppPrimary` = `.ppMain` (use `.ppMain` in new code)
- `.ppDanger` = `#FF6B6B` (Friendly Coral - errors)

---

### Interactive States

**Main (Peach) States:**
| Token | Hex | Usage | Lightness |
|-------|-----|-------|-----------|
| `.ppMain` | `#FFB8A0` | Default | 0% |
| `.ppMainHover` | `#FF9F87` | Hover | -15% |
| `.ppMainPressed` | `#FF866D` | Pressed | -25% |
| `.ppMainDisabled` | `ppMain.opacity(0.4)` | Disabled | 40% opacity |

**Secondary (Mint) States:**
| Token | Hex | Usage | Lightness |
|-------|-----|-------|-----------|
| `.ppSecondary` | `#B4E7CE` | Default | 0% |
| `.ppSecondaryHover` | `#9AD9B9` | Hover | -15% |
| `.ppSecondaryPressed` | `#7DC9A0` | Pressed | -25% |
| `.ppSecondaryDisabled` | `ppSecondary.opacity(0.4)` | Disabled | 40% opacity |

**Accent (Yellow) States:**
| Token | Hex | Usage | Lightness |
|-------|-----|-------|-----------|
| `.ppAccent` | `#FFEC5C` | Default | 0% |
| `.ppAccentHover` | `#FFE338` | Hover | -15% |
| `.ppAccentPressed` | `#FFDA1A` | Pressed | -25% |
| `.ppAccentDisabled` | `ppAccent.opacity(0.4)` | Disabled | 40% opacity |

---

### Surfaces & Backgrounds

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `.ppBackground` | `#FFF8F3` | 255, 248, 243 | Main app canvas (Warm White) |
| `.ppSurface` | `#FFFFFF` | 255, 255, 255 | Card/sheet backgrounds (Pure White) |
| `.ppSurfaceAlt` | `#FEEAF5` | 254, 234, 245 | Alternative surface (Blush Pink) |
| `.ppSurfaceElevated` | System | - | Modals, popovers (iOS secondarySystemBackground) |
| `.ppSurfaceModal` | System | - | Modal backgrounds (iOS tertiarySystemBackground) |

---

### Borders & Dividers

| Token | Hex | Usage | Width |
|-------|-----|-------|-------|
| `.ppOutline` | `#FFCCE1` | 2-3pt outlines, dividers (Pink Outline) | 2-3pt |
| `.ppBorderFocused` | `ppMain` | Focused input borders | 2pt |
| `.ppDivider` | `ppOutline` | Divider lines | 1pt |

---

### Text Colors

| Token | Hex | RGB | Usage | Contrast on White |
|-------|-----|-----|-------|-------------------|
| `.ppTextPrimary` | `#2E1135` | 46, 17, 53 | Body text, headings | 12.3:1 (AAA) ✅ |
| `.ppTextSecondary` | `#5C3A63` | 92, 58, 99 | Secondary text, labels | 6.8:1 (AA) ✅ |
| `.ppTextTertiary` | `#8C6C92` | 140, 108, 146 | Tertiary text, hints | 4.2:1 (AA-) ⚠️ |

**⚠️ CRITICAL ACCESSIBILITY NOTE:**
- ✅ **ALWAYS use `.ppTextPrimary` on pastel backgrounds** (5.2:1 on peach = AA Pass)
- ❌ **NEVER use white text on `.ppMain`** (2.3:1 = FAIL WCAG)

---

### Feedback & Status Colors

| Token | Hex | Usage | Icon |
|-------|-----|-------|------|
| `.ppPositive` (`.ppSuccess`) | `#8BE5A8` | Success states | ✅ |
| `.ppWarning` | `#FFCF6B` | Warning states | ⚠️ |
| `.ppFunAlert` (`.ppError`) | `#FF6B6B` | Error states (Friendly Coral) | ❌ |
| `.ppInfo` | `ppSupportLavender` | Info states | ℹ️ |

---

### Rating Colors (5-Point Scale)

| Token | Hex | Rating | Emoji |
|-------|-----|--------|-------|
| `.ppRatingGreat` | `#8BE5A8` | 5/5 Great | 😃 |
| `.ppRatingGood` | `#B4E7CE` | 4/5 Good | 🙂 |
| `.ppRatingOkay` | `#FFEC5C` | 3/5 Okay | 😐 |
| `.ppRatingBad` | `#FF9B50` | 2/5 Bad | 😟 |
| `.ppRatingTerrible` | `#FF6B6B` | 1/5 Terrible | 😫 |

---

### Decorative & Special Purpose

| Token | Hex | Usage |
|-------|-----|-------|
| `.ppFlameOrange` | `#FF6B35` | Flame animation primary |
| `.ppFlameRed` | `#8B0000` | Flame animation ember |
| `.ppConfettiPink` | `ppBubblegum` | Confetti particles |
| `.ppConfettiPurple` | `ppSupportLavender` | Confetti particles |
| `.ppConfettiYellow` | `ppAccent` | Confetti particles |
| `.ppConfettiMint` | `ppSecondary` | Confetti particles |

---

### Pastel Shadows

| Token | Hex | RGB | Opacity | Usage |
|-------|-----|-----|---------|-------|
| `.ppShadowPink` | `#FFC9EC` | 255, 201, 236 | 15-40% | Primary shadows |
| `.ppShadowBlue` | `#C7E4FF` | 199, 228, 255 | 25-28% | Secondary shadows (hover) |

**Usage:** See [Shadows](#shadows) section below for complete shadow system.

---

### Dark Mode Variants

| Token | Hex | Light Mode Equivalent |
|-------|-----|----------------------|
| `.ppMainDark` | `#FF8E6F` | `.ppMain` (darker peach) |
| `.ppSecondaryDark` | `#7DD9B0` | `.ppSecondary` (darker mint) |
| `.ppAccentDark` | `#FFD84D` | `.ppAccent` (darker yellow) |
| `.ppBackgroundDark` | `#1C1A24` | `.ppBackground` (dark purple) |
| `.ppSurfaceDark` | `#2A2635` | `.ppSurface` |
| `.ppSurfaceAltDark` | `#352F43` | `.ppSurfaceAlt` |
| `.ppOutlineDark` | `#4C3C57` | `.ppOutline` |

**Adaptive Functions:**
```swift
@Environment(\.colorScheme) var colorScheme

// Use adaptive color
.background(Color.ppMainAdaptive(for: colorScheme))
.background(Color.ppSecondaryAdaptive(for: colorScheme))
.background(Color.ppAccentAdaptive(for: colorScheme))
.background(Color.ppBackgroundAdaptive(for: colorScheme))
```

---

## 📝 Typography

### Display Fonts (Hero Headlines)

| Token | Size | Weight | Design | Usage |
|-------|------|--------|--------|-------|
| `.ppDisplayLarge` | 34pt | Bold | Rounded | Large hero titles |
| `.ppDisplayMedium` | 28pt | Bold | Rounded | Medium hero titles |
| `.ppDisplaySmall` | 22pt | Bold | Rounded | Small hero titles |

---

### Title Fonts

| Token | Size | Weight | Design | Usage |
|-------|------|--------|--------|-------|
| `.ppTitle1` | 34pt | Semibold | Rounded | Main page titles |
| `.ppTitle2` | 28pt | Semibold | Rounded | Section titles |
| `.ppTitle3` | 22pt | Semibold | Rounded | Subsection titles |

---

### Body Fonts

| Token | Size | Weight | Design | Usage |
|-------|------|--------|--------|-------|
| `.ppBodyLarge` | 17pt | Regular | Default | Large body text |
| `.ppBody` | 15pt | Regular | Default | Standard body text ⭐ |
| `.ppBodySmall` | 13pt | Regular | Default | Small body text |

---

### Label Fonts

| Token | Size | Weight | Design | Usage |
|-------|------|--------|--------|-------|
| `.ppLabelLarge` | 15pt | Medium | Default | Large labels |
| `.ppLabel` | 13pt | Medium | Default | Standard labels |
| `.ppLabelMedium` | 12pt | Medium | Default | Medium labels |
| `.ppLabelSmall` | 11pt | Medium | Default | Small labels |

---

### Caption Fonts

| Token | Size | Weight | Design | Usage |
|-------|------|--------|--------|-------|
| `.ppCaption` | 11pt | Regular | Default | Standard captions |
| `.ppCaptionSmall` | 9pt | Regular | Default | Fine print |

---

### Number Fonts (Stats, Metrics)

| Token | Size | Weight | Design | Usage |
|-------|------|--------|--------|-------|
| `.ppNumberHero` | 64pt | Bold | Rounded | Hero numbers (large stats) |
| `.ppNumberLarge` | 48pt | Bold | Rounded | Large numbers |
| `.ppNumberMedium` | 32pt | Bold | Rounded | Medium numbers ⭐ |
| `.ppNumberSmall` | 24pt | Bold | Rounded | Small numbers |

---

### Icon Fonts (SF Symbols)

| Token | Size | Weight | Design | Usage |
|-------|------|--------|--------|-------|
| `.ppIconLarge` | 36pt | Regular | Default | Large icons, hero sections |
| `.ppIconMedium` | 24pt | Regular | Default | Standard icons ⭐ |
| `.ppIconSmall` | 16pt | Regular | Default | Small icons, compact UI |

---

### Emoji Fonts

| Token | Size | Usage |
|-------|------|-------|
| `.ppEmojiXL` | 96pt | Hero emojis |
| `.ppEmojiLarge` | 64pt | Large emojis |
| `.ppEmojiMedium` | 48pt | Medium emojis |
| `.ppEmojiSmall` | 32pt | Small emojis |

---

### Button Fonts

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `.ppButtonLarge` | 17pt | Semibold | Large buttons |
| `.ppButton` | 15pt | Semibold | Standard buttons ⭐ |
| `.ppButtonSmall` | 13pt | Semibold | Small buttons |

---

### Input Fonts

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `.ppInput` | 15pt | Regular | Input field text |
| `.ppInputLabel` | 13pt | Medium | Input field labels |

---

## 📏 Spacing

### Base Spacing Scale (8pt Grid)

| Token | Value | Usage | Example |
|-------|-------|-------|---------|
| `PPSpacing.xxxs` | 2pt | Tight spacing (sparkles) | Icon gaps |
| `PPSpacing.xxs` | 4pt | Very small gaps | Badge padding |
| `PPSpacing.xs` | 8pt | Small gaps | Icon-to-text gap |
| `PPSpacing.sm` | 12pt | Compact spacing | Button vertical padding |
| `PPSpacing.md` | 16pt | **Default spacing** ⭐ | Standard padding |
| `PPSpacing.lg` | 24pt | Section spacing | Between sections |
| `PPSpacing.xl` | 32pt | Large spacing | Card padding |
| `PPSpacing.xxl` | 48pt | Extra large spacing | Hero section padding |
| `PPSpacing.xxxl` | 64pt | Hero spacing | Large hero elements |
| `PPSpacing.jumbo` | 72pt | Celebration modals | Achievement cards |

---

### Corner Radius

| Token | Value | Usage |
|-------|-------|-------|
| `PPCornerRadius.xs` | 4pt | Small elements (badges) |
| `PPCornerRadius.sm` | 8pt | Buttons, inputs ⭐ |
| `PPCornerRadius.md` | 12pt | Cards ⭐ |
| `PPCornerRadius.lg` | 16pt | Large cards |
| `PPCornerRadius.xl` | 24pt | Hero elements |
| `PPCornerRadius.pill` | 20pt | Pill-shaped buttons |
| `PPCornerRadius.bubble` | 40pt | Speech bubbles |
| `PPCornerRadius.full` | 9999pt | Circular (avatars, dots) |

---

### Component Heights

| Token | Value | Usage | iOS HIG Compliance |
|-------|-------|-------|--------------------|
| `PPHeight.buttonSmall` | 36pt | Small buttons | Below minimum (36pt < 44pt) |
| `PPHeight.button` | 48pt | **Standard buttons** ⭐ | ✅ Exceeds 44pt minimum |
| `PPHeight.buttonLarge` | 56pt | Large buttons | ✅ Exceeds 44pt minimum |
| `PPHeight.input` | 48pt | Input fields | ✅ Exceeds 44pt minimum |
| `PPHeight.navigationBar` | 44pt | Navigation bar | ✅ iOS standard |
| `PPHeight.quickLogButton` | 90pt | Quick log action | ✅ Generous touch target |
| `PPHeight.statCard` | 140pt | Stat display cards | N/A (decorative) |

---

### Component Widths & Sizes

**Icon Sizes:**
| Token | Value | Usage |
|-------|-------|-------|
| `PPWidth.iconSmall` | 20pt | Small icons |
| `PPWidth.icon` | 24pt | **Standard icons** ⭐ |
| `PPWidth.iconLarge` | 32pt | Large icons |

**Avatar Sizes:**
| Token | Value | Usage |
|-------|-------|-------|
| `PPWidth.avatarSmall` | 40pt | Small avatars (list rows) |
| `PPWidth.avatar` | 60pt | **Standard avatars** ⭐ |
| `PPWidth.avatarLarge` | 120pt | Large avatars (profile) |

**Misc Sizes:**
| Token | Value | Usage |
|-------|-------|-------|
| `PPSize.loadingDot` | 8pt | Loading indicator dots |
| `PPSize.badge` | 16pt | Notification badges |
| `PPSize.checkmark` | 20pt | Checkmark icons |

---

### Max Widths (Responsive)

| Token | Value | Usage |
|-------|-------|-------|
| `PPMaxWidth.card` | 350pt | Card max width (from StreakCard) |
| `PPMaxWidth.form` | 600pt | Form max width (readability) |
| `PPMaxWidth.content` | 1200pt | Content max width (iPad) |

---

### Shadows

**Predefined Shadow Levels:**

| Token | Color | Opacity | Radius | Y Offset | Usage |
|-------|-------|---------|--------|----------|-------|
| `.sm` | `ppShadowPink` | 15% | 4pt | 2pt | Subtle elevation |
| `.md` | `ppShadowPink` | 25% | 8pt | 4pt | Standard cards ⭐ |
| `.lg` | `ppShadowPink` | 35% | 14pt | 6pt | Prominent elements |
| `.xl` | `ppShadowPink` | 40% | 20pt | 10pt | Hero elements |
| `.lift` | `ppShadowPink` | 35% | 14pt | 6pt | Card elevation (Memeverse) |
| `.hover` | `ppShadowBlue` | 28% | 20pt | 12pt | Hover state (Memeverse) |
| `.celebration` | `ppAccent` | 40% | 30pt | 16pt | Achievement unlock |

**Usage:**
```swift
// Single shadow
VStack { }
    .ppShadow(.lift)

// Multiple shadows (layered depth)
VStack { }
    .ppShadows([.md, .hover])

// Custom shadow
VStack { }
    .ppShadow(.custom(color: .ppShadowPink, radius: 10, x: 0, y: 5))
```

---

## 🌈 Gradients

### Primary Gradients (Core Brand)

| Name | Colors | Usage | Example |
|------|--------|-------|---------|
| `.peachPink` | Peach → Bubblegum Pink | Primary cards, main CTAs | Hero sections, primary buttons |
| `.mintLavender` | Mint → Lavender | Streak cards, secondary elements | Streak displays, info cards |
| `.peachYellow` | Peach → Sunshine Yellow | Primary actions, CTAs | Quick log button, important CTAs |

---

### Feedback & Status Gradients

| Name | Colors | Usage | Example |
|------|--------|-------|---------|
| `.coralOrange` | Friendly Coral → Playful Orange | Alerts, warnings | Error banners (friendly, not harsh) |
| `.mintSuccess` | Mint → Success Green | Success states | Success messages, achievements |
| `.yellowOrange` | Sunshine Yellow → Playful Orange | Mild warnings | Progress indicators, cautions |

---

### Celebration Gradients

| Name | Colors | Stops | Usage |
|------|--------|-------|-------|
| `.rainbow` | Peach → Yellow → Mint | 3 | Fun moments, variety |
| `.celebration` | Pink → Peach → Yellow → Mint → Lavender | 5 | Major achievements, milestones |

---

### Surface Gradients (Subtle Backgrounds)

| Name | Colors | Usage |
|------|--------|-------|
| `.surfaceSubtle` | White → Blush Pink | Card backgrounds, subtle elevation |
| `.backgroundPastel` | Warm White → Blush Pink | Section backgrounds, decorative panels |

---

### Legacy Mappings (Backward Compatibility)

| Old Name | New Name | Status |
|----------|----------|--------|
| `.purple` | `.peachPink` | ⚠️ Deprecated |
| `.ocean` | `.mintLavender` | ⚠️ Deprecated |
| `.fire` | `.coralOrange` | ⚠️ Deprecated |
| `.sunset` | `.rainbow` | ⚠️ Deprecated |
| `.mint` | `.mintSuccess` | ⚠️ Deprecated |
| `.poopy` | ❌ **REMOVED** | - |

---

### Gradient Usage Examples

**Linear Gradient (Default):**
```swift
.background(LinearGradient.ppGradient(PPGradients.peachPink))
// topLeading → bottomTrailing (default)
```

**Custom Direction:**
```swift
.background(
    LinearGradient.ppGradient(
        PPGradients.mintLavender,
        startPoint: .leading,
        endPoint: .trailing
    )
)
```

**Radial Gradient (Glows, Highlights):**
```swift
Circle()
    .fill(RadialGradient.ppGradient(PPGradients.peachPink, endRadius: 100))
```

**Angular Gradient (Loading Spinners):**
```swift
Circle()
    .stroke(
        AngularGradient.ppGradient(PPGradients.rainbow, angle: .degrees(rotation)),
        lineWidth: 5
    )
```

---

## 🧑‍💻 Common Usage Patterns

### Pattern 1: Standard Button
```swift
Button("Quick Log") {
    // action
}
.frame(height: PPHeight.button)
.frame(maxWidth: .infinity)
.background(Color.ppMain)
.foregroundColor(.ppTextPrimary)  // NOT white!
.cornerRadius(PPCornerRadius.sm)
.ppShadow(.md)
```

### Pattern 2: Card with Gradient
```swift
VStack(spacing: PPSpacing.lg) {
    Text("Stat Title")
        .font(.ppLabel)
        .foregroundColor(.ppTextSecondary)

    Text("47")
        .font(.ppNumberLarge)
        .foregroundColor(.ppTextPrimary)
}
.padding(PPSpacing.xl)
.background(LinearGradient.ppGradient(PPGradients.mintLavender))
.cornerRadius(PPCornerRadius.md)
.ppShadow(.lift)
```

### Pattern 3: Icon with Text
```swift
HStack(spacing: PPSpacing.xs) {
    Image(systemName: "flame.fill")
        .font(.ppIconMedium)
        .foregroundColor(.ppPlayfulOrange)

    Text("7 Day Streak")
        .font(.ppBody)
        .foregroundColor(.ppTextPrimary)
}
```

### Pattern 4: Input Field
```swift
VStack(alignment: .leading, spacing: PPSpacing.xxs) {
    Text("Notes")
        .font(.ppInputLabel)
        .foregroundColor(.ppTextSecondary)

    TextField("Add notes...", text: $notes)
        .font(.ppInput)
        .padding(PPSpacing.sm)
        .frame(height: PPHeight.input)
        .background(Color.ppSurface)
        .cornerRadius(PPCornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: PPCornerRadius.sm)
                .stroke(Color.ppOutline, lineWidth: 2)
        )
}
```

### Pattern 5: Avatar with Badge
```swift
ZStack(alignment: .topTrailing) {
    Circle()
        .fill(LinearGradient.ppGradient(PPGradients.peachPink))
        .frame(width: PPWidth.avatar, height: PPWidth.avatar)

    Circle()
        .fill(Color.ppFunAlert)
        .frame(width: PPSize.badge, height: PPSize.badge)
        .overlay(
            Text("3")
                .font(.ppCaptionSmall)
                .foregroundColor(.white)
        )
        .offset(x: -4, y: 4)
}
```

---

## ⚠️ Important Rules

### ❌ Never Do This

```swift
// ❌ Hardcoded colors
.foregroundColor(.blue)
.background(Color(hex: "#FFB8A0"))

// ❌ Hardcoded fonts
.font(.system(size: 16))
.font(.title)

// ❌ Hardcoded spacing
.padding(16)
.frame(height: 48)
.cornerRadius(12)

// ❌ Hardcoded shadows
.shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)

// ❌ White text on pastel (FAILS WCAG)
Text("Button")
    .foregroundColor(.white)
    .background(Color.ppMain)  // 2.3:1 contrast = FAIL
```

### ✅ Always Do This

```swift
// ✅ Use design tokens
.foregroundColor(.ppTextPrimary)
.background(Color.ppMain)

// ✅ Use typography scale
.font(.ppBody)
.font(.ppTitle1)

// ✅ Use spacing tokens
.padding(PPSpacing.md)
.frame(height: PPHeight.button)
.cornerRadius(PPCornerRadius.sm)

// ✅ Use pastel shadows
.ppShadow(.lift)

// ✅ Dark text on pastel (PASSES WCAG)
Text("Button")
    .foregroundColor(.ppTextPrimary)
    .background(Color.ppMain)  // 5.2:1 contrast = AA Pass ✅
```

---

## 📐 8pt Grid Compliance

All spacing tokens follow the 8pt grid system:

- ✅ **Multiples of 8:** `xs (8), md (16), lg (24), xl (32), xxl (48), xxxl (64), jumbo (72)`
- ✅ **Multiples of 4:** `sm (12), xxs (4)`
- ⚠️ **Exception:** `xxxs (2pt)` - use sparingly for tight sparkle gaps

**Why 8pt Grid?**
- Consistent visual rhythm
- Easier responsive scaling (2x, 4x, 8x)
- Aligns with iOS design standards
- Reduces decision fatigue

---

## ♿ Accessibility Quick Reference

### WCAG Contrast Ratios

**Text on Backgrounds:**

| Text Color | Background | Ratio | Result |
|------------|------------|-------|--------|
| `ppTextPrimary` | `ppSurface` (white) | 12.3:1 | ✅ AAA |
| `ppTextPrimary` | `ppMain` (peach) | 5.2:1 | ✅ AA |
| `ppTextPrimary` | `ppAccent` (yellow) | 7.1:1 | ✅ AA |
| `ppTextPrimary` | `ppSecondary` (mint) | 4.8:1 | ✅ AA |
| White | `ppMain` (peach) | 2.3:1 | ❌ **FAIL** |
| `ppAccent` | `ppBackground` | 1.3:1 | ❌ **FAIL** (decorative only) |

**Touch Target Sizes:**
- ✅ Minimum: 44pt (iOS HIG standard)
- ✅ Standard button: 48pt (`PPHeight.button`)
- ✅ Quick log button: 90pt (`PPHeight.quickLogButton`)

**Dynamic Type:**
- All typography tokens scale with system font size settings
- Avoid fixed `.frame(height:)` on text elements
- Test with Accessibility Inspector

---

## 🔗 Related Documentation

- **Component Usage:** `docs/COMPONENT_LIBRARY.md` - How to use components with these tokens
- **Design Principles:** `docs/04-design-system.md` - Complete design system guide
- **Migration History:** `docs/MEMEVERSE_MIGRATION.md` - Color migration details
- **Developer Guide:** `CLAUDE.md` - Architecture and conventions

---

## 🛠️ Token Files Location

```
poopypals/Core/DesignSystem/
├── Colors/
│   ├── PPColors.swift       (354 lines - 60+ color tokens)
│   └── PPGradients.swift    (333 lines - 9 gradient definitions)
├── Typography/
│   └── PPTypography.swift   (264 lines - 40+ font tokens)
└── Spacing/
    └── PPSpacing.swift      (360 lines - spacing, dimensions, shadows)
```

---

**Questions?** Check component usage in `docs/COMPONENT_LIBRARY.md` or design principles in `docs/04-design-system.md`.

**Found a bug?** Design tokens live in `poopypals/Core/DesignSystem/` - file an issue or fix directly.

**Need a new token?** Follow the 8pt grid, test WCAG contrast, and update this reference doc.
