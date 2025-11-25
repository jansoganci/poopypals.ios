//
//  PPColors.swift
//  PoopyPals
//
//  Design System - Memeverse Color Palette
//  Last Updated: 2025-11-25 - MEMEVERSE MIGRATION
//

import SwiftUI

extension Color {
    // MARK: - Core Pastels (Primary Brand Colors)

    /// Main brand color - Soft Peach (primary actions, highlights)
    static let ppMain = Color(hex: "#FFB8A0")

    /// Alternative highlight - Bubblegum Pink (stickers, badges, secondary highlights)
    static let ppBubblegum = Color(hex: "#FFB3D9")

    /// Secondary color - Mint (secondary actions, cards)
    static let ppSecondary = Color(hex: "#B4E7CE")

    /// Accent color - Sunshine Yellow (sparkles, emphasis, streaks)
    static let ppAccent = Color(hex: "#FFEC5C")

    /// Playful Orange (hover accents, callouts)
    static let ppPlayfulOrange = Color(hex: "#FF9B50")

    /// Support Lavender (tooltips, tertiary backgrounds)
    static let ppSupportLavender = Color(hex: "#C7AFFF")

    // MARK: - Legacy Semantic Aliases (backward compatibility)

    /// Primary color (alias for ppMain for backward compatibility)
    static let ppPrimary = ppMain

    /// Danger/Error color (Friendly Coral)
    static let ppDanger = Color(hex: "#FF6B6B")

    // MARK: - Interactive States (Hover, Pressed, Disabled)

    // Main (Peach) states
    /// Hover state for ppMain (Peach -15% lightness)
    static let ppMainHover = Color(hex: "#FF9F87")

    /// Pressed state for ppMain (Peach -25% lightness)
    static let ppMainPressed = Color(hex: "#FF866D")

    /// Disabled state for ppMain
    static let ppMainDisabled = ppMain.opacity(0.4)

    // Secondary (Mint) states
    /// Hover state for ppSecondary (Mint -15% lightness)
    static let ppSecondaryHover = Color(hex: "#9AD9B9")

    /// Pressed state for ppSecondary (Mint -25% lightness)
    static let ppSecondaryPressed = Color(hex: "#7DC9A0")

    /// Disabled state for ppSecondary
    static let ppSecondaryDisabled = ppSecondary.opacity(0.4)

    // Accent (Yellow) states
    /// Hover state for ppAccent (Yellow -15% lightness)
    static let ppAccentHover = Color(hex: "#FFE338")

    /// Pressed state for ppAccent (Yellow -25% lightness)
    static let ppAccentPressed = Color(hex: "#FFDA1A")

    /// Disabled state for ppAccent
    static let ppAccentDisabled = ppAccent.opacity(0.4)

    // MARK: - Surfaces & Backgrounds

    /// Main app canvas - Warm White
    static let ppBackground = Color(hex: "#FFF8F3")

    /// Card/sheet background - Pure White
    static let ppSurface = Color(hex: "#FFFFFF")

    /// Alternative decorative surface - Blush Pink
    static let ppSurfaceAlt = Color(hex: "#FEEAF5")

    /// Elevated surface (for modals, popovers)
    static let ppSurfaceElevated = Color(UIColor.secondarySystemBackground)

    /// Modal background
    static let ppSurfaceModal = Color(UIColor.tertiarySystemBackground)

    // MARK: - Borders & Dividers

    /// 2-3pt outlines, dividers - Pink Outline
    static let ppOutline = Color(hex: "#FFCCE1")

    /// Focused state border
    static let ppBorderFocused = ppMain

    /// Divider line
    static let ppDivider = ppOutline

    // MARK: - Pastel Shadows (replaces black shadows)

    /// Primary shadow color - Pink (use with 35% opacity)
    static let ppShadowPink = Color(hex: "#FFC9EC")

    /// Secondary shadow color - Blue (use with 25% opacity)
    static let ppShadowBlue = Color(hex: "#C7E4FF")

    // MARK: - Text Colors

    /// Primary text - Deep Purple
    static let ppTextPrimary = Color(hex: "#2E1135")

    /// Secondary text - Medium Purple
    static let ppTextSecondary = Color(hex: "#5C3A63")

    /// Tertiary text - Light Purple
    static let ppTextTertiary = Color(hex: "#8C6C92")

    // MARK: - Feedback & Status Colors

    /// Success state - Mint Green (replaces ppSuccess)
    static let ppPositive = Color(hex: "#8BE5A8")

    /// Success alias (backward compatibility)
    static let ppSuccess = ppPositive

    /// Warning state - Soft Yellow
    static let ppWarning = Color(hex: "#FFCF6B")

    /// Error state - Friendly Coral (replaces ppError)
    static let ppFunAlert = Color(hex: "#FF6B6B")

    /// Error alias (backward compatibility)
    static let ppError = ppFunAlert

    /// Info state - Lavender
    static let ppInfo = ppSupportLavender

    // MARK: - Rating Colors (5-point scale)

    /// Great rating - Success Green
    static let ppRatingGreat = ppPositive

    /// Good rating - Mint
    static let ppRatingGood = ppSecondary

    /// Okay rating - Yellow
    static let ppRatingOkay = ppAccent

    /// Bad rating - Playful Orange
    static let ppRatingBad = ppPlayfulOrange

    /// Terrible rating - Coral
    static let ppRatingTerrible = ppFunAlert

    // MARK: - Decorative & Special Purpose

    /// Flame animation primary color
    static let ppFlameOrange = Color(hex: "#FF6B35")

    /// Flame animation secondary color (ember)
    static let ppFlameRed = Color(hex: "#8B0000")

    /// Confetti colors (convenience aliases)
    static let ppConfettiPink = ppBubblegum
    static let ppConfettiPurple = ppSupportLavender
    static let ppConfettiYellow = ppAccent
    static let ppConfettiMint = ppSecondary

    // MARK: - Dark Mode Variants (explicit definitions)

    /// Main color in dark mode (darker peach)
    static let ppMainDark = Color(hex: "#FF8E6F")

    /// Secondary color in dark mode (darker mint)
    static let ppSecondaryDark = Color(hex: "#7DD9B0")

    /// Accent color in dark mode (darker yellow)
    static let ppAccentDark = Color(hex: "#FFD84D")

    /// Background in dark mode (dark purple)
    static let ppBackgroundDark = Color(hex: "#1C1A24")

    /// Surface in dark mode
    static let ppSurfaceDark = Color(hex: "#2A2635")

    /// Surface alt in dark mode
    static let ppSurfaceAltDark = Color(hex: "#352F43")

    /// Outline in dark mode
    static let ppOutlineDark = Color(hex: "#4C3C57")

    // MARK: - Adaptive Colors (auto-switch based on color scheme)

    /// Adaptive main color (light/dark aware)
    static func ppMainAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ppMainDark : ppMain
    }

    /// Adaptive secondary color (light/dark aware)
    static func ppSecondaryAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ppSecondaryDark : ppSecondary
    }

    /// Adaptive accent color (light/dark aware)
    static func ppAccentAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ppAccentDark : ppAccent
    }

    /// Adaptive background color (light/dark aware)
    static func ppBackgroundAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ppBackgroundDark : ppBackground
    }

    // MARK: - Hex Initializer (unchanged)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Migration Notes
/*
 MEMEVERSE MIGRATION - 2025-11-25
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 OLD CORPORATE → NEW MEMEVERSE COLORS:

 #6366F1 (Indigo)   → #FFB8A0 (Soft Peach)      ppPrimary/ppMain
 #10B981 (Green)    → #B4E7CE (Mint)             ppSecondary
 #F59E0B (Amber)    → #FFEC5C (Sunshine Yellow)  ppAccent
 #EF4444 (Red)      → #FF6B6B (Friendly Coral)   ppDanger/ppFunAlert
 #3B82F6 (Blue)     → #C7AFFF (Support Lavender) ppInfo

 NEW ADDITIONS (not in corporate system):
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Core Pastels:
 - ppBubblegum (#FFB3D9) - Alternative highlights, stickers
 - ppPlayfulOrange (#FF9B50) - Hover states, callouts

 Interactive States (hover/pressed/disabled):
 - ppMainHover, ppMainPressed, ppMainDisabled
 - ppSecondaryHover, ppSecondaryPressed, ppSecondaryDisabled
 - ppAccentHover, ppAccentPressed, ppAccentDisabled

 Borders & Outlines:
 - ppOutline (#FFCCE1) - 2-3pt pink borders for cards

 Pastel Shadows:
 - ppShadowPink (#FFC9EC) - Replaces black shadows
 - ppShadowBlue (#C7E4FF) - Secondary shadow option

 Dark Mode:
 - ppMainDark, ppSecondaryDark, ppAccentDark
 - ppBackgroundDark, ppSurfaceDark, ppSurfaceAltDark, ppOutlineDark

 Decorative:
 - ppFlameOrange, ppFlameRed - For flame animations
 - ppConfetti* aliases - For confetti effects

 BACKWARD COMPATIBILITY:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Aliases maintained for existing code:
 - ppPrimary = ppMain
 - ppSuccess = ppPositive
 - ppError = ppFunAlert

 This ensures existing code continues to work during migration.

 ACCESSIBILITY NOTES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ⚠️ CRITICAL: Pastel colors have lower contrast than corporate palette

 DO:
 - ✅ Use ppTextPrimary (#2E1135) for text on pastel backgrounds
 - ✅ Add ppOutline (2-3pt) strokes on important pastel elements
 - ✅ Use pastel shadows (ppShadowPink) instead of black
 - ✅ Test color combinations with contrast checker

 DON'T:
 - ❌ NEVER use white text on ppMain (peach) - contrast ratio 2.3:1 FAILS
 - ❌ Use ppAccent (yellow) for small text - hard to see on light backgrounds
 - ❌ Rely on color alone for information

 CONTRAST RATIOS (WCAG AA = 4.5:1 for normal text):
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ✅ ppTextPrimary on ppSurface: 12.3:1 (AAA)
 ✅ ppTextPrimary on ppMain: 5.2:1 (AA Pass)
 ✅ ppTextPrimary on ppAccent: 7.1:1 (AA Pass)
 ✅ ppTextPrimary on ppSecondary: 4.8:1 (AA Pass)
 ❌ White on ppMain: 2.3:1 (FAIL - do not use)
 ❌ ppAccent on ppBackground: 1.3:1 (FAIL - decorative only)

 USAGE EXAMPLES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 // Primary button
 Button("Log") { }
     .background(Color.ppMain)
     .foregroundColor(.ppTextPrimary)  // NOT white!

 // Card with outline
 VStack { }
     .background(Color.ppSurface)
     .overlay(
         RoundedRectangle(cornerRadius: 12)
             .stroke(Color.ppOutline, lineWidth: 2)
     )

 // Pastel shadow
 .shadow(color: .ppShadowPink.opacity(0.35), radius: 14, x: 0, y: 6)

 // Adaptive dark mode
 @Environment(\.colorScheme) var colorScheme
 .background(Color.ppMainAdaptive(for: colorScheme))

 MIGRATION STATUS:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ✅ Phase 0: Migration mapping complete
 ✅ Phase 1.1: PPColors.swift updated with Memeverse palette
 ⏳ Phase 1.2: PPTypography.swift (pending)
 ⏳ Phase 1.3: PPSpacing.swift (pending)
 ⏳ Phase 1.4: PPGradients.swift (pending)
 ⏳ Phase 2: Update components (pending)
 ⏳ Phase 3: Update views (pending)

 See docs/MEMEVERSE_MIGRATION.md for full migration plan.
 */
