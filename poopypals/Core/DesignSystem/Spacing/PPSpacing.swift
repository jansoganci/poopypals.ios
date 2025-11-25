//
//  PPSpacing.swift
//  PoopyPals
//
//  Design System - Spacing, Dimensions, Shadows (8pt Grid + Memeverse Pastels)
//  Last Updated: 2025-11-25 - MEMEVERSE MIGRATION
//

import SwiftUI

// MARK: - Spacing Tokens (8pt grid)

enum PPSpacing {
    static let xxxs: CGFloat = 2      // Tight spacing (sparkle gaps)
    static let xxs: CGFloat = 4       // Very small gaps
    static let xs: CGFloat = 8        // Small gaps
    static let sm: CGFloat = 12       // Compact spacing
    static let md: CGFloat = 16       // Default spacing ⭐ Most common
    static let lg: CGFloat = 24       // Section spacing
    static let xl: CGFloat = 32       // Large spacing
    static let xxl: CGFloat = 48      // Extra large spacing
    static let xxxl: CGFloat = 64     // Hero spacing
    static let jumbo: CGFloat = 72    // Celebration modals (NEW)
}

// MARK: - Corner Radius

enum PPCornerRadius {
    static let xs: CGFloat = 4        // Small elements
    static let sm: CGFloat = 8        // Buttons, inputs
    static let md: CGFloat = 12       // Cards
    static let lg: CGFloat = 16       // Large cards
    static let xl: CGFloat = 24       // Hero elements
    static let pill: CGFloat = 20     // Pill-shaped buttons (NEW)
    static let bubble: CGFloat = 40   // Speech bubbles (NEW)
    static let full: CGFloat = 9999   // Circular
}

// MARK: - Component Heights (NEW)

enum PPHeight {
    /// Small button height
    static let buttonSmall: CGFloat = 36

    /// Standard button height (iOS HIG: 44pt minimum touch target)
    static let button: CGFloat = 48

    /// Large button height
    static let buttonLarge: CGFloat = 56

    /// Input field height
    static let input: CGFloat = 48

    /// Navigation bar height (iOS standard)
    static let navigationBar: CGFloat = 44

    /// Quick log rating button height (from NewHomeView)
    static let quickLogButton: CGFloat = 90

    /// Stat card height (from NewHomeView)
    static let statCard: CGFloat = 140
}

// MARK: - Component Widths & Sizes (NEW)

enum PPWidth {
    /// Small icon size
    static let iconSmall: CGFloat = 20

    /// Standard icon size (SF Symbols recommended)
    static let icon: CGFloat = 24

    /// Large icon size
    static let iconLarge: CGFloat = 32

    /// Small avatar size
    static let avatarSmall: CGFloat = 40

    /// Standard avatar size
    static let avatar: CGFloat = 60

    /// Large avatar size (from analysis)
    static let avatarLarge: CGFloat = 120
}

enum PPSize {
    /// Loading dot size (from ChatView violation)
    static let loadingDot: CGFloat = 8

    /// Badge size
    static let badge: CGFloat = 16

    /// Checkmark size
    static let checkmark: CGFloat = 20
}

enum PPMaxWidth {
    /// Card max width (from StreakCard violation)
    static let card: CGFloat = 350

    /// Form max width
    static let form: CGFloat = 600

    /// Content max width (for readability)
    static let content: CGFloat = 1200
}

// MARK: - Pastel Shadow System (IMPROVED - enum-based, chainable)

/// Memeverse pastel shadow system with predefined elevation levels
enum PPShadow {
    /// Subtle lift - small shadow for minimal elevation
    case sm

    /// Standard cards - medium shadow for normal elevation
    case md

    /// Prominent elements - large shadow for high elevation
    case lg

    /// Hero elements - extra large shadow for maximum elevation
    case xl

    /// Hover state - lift shadow from Memeverse docs
    case lift

    /// Enhanced hover - hover shadow from Memeverse docs
    case hover

    /// Achievement unlock - celebration shadow from Memeverse docs
    case celebration

    /// Custom shadow - specify your own values
    case custom(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)

    /// Get shadow values as tuple
    var values: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        switch self {
        case .sm:
            return (.ppShadowPink.opacity(0.15), 4, 0, 2)
        case .md:
            return (.ppShadowPink.opacity(0.25), 8, 0, 4)
        case .lg:
            return (.ppShadowPink.opacity(0.35), 14, 0, 6)
        case .xl:
            return (.ppShadowPink.opacity(0.40), 20, 0, 10)
        case .lift:
            // From Memeverse docs: lift = Shadow(color: .ppShadowPink.opacity(0.35), radius: 14, x: 0, y: 6)
            return (.ppShadowPink.opacity(0.35), 14, 0, 6)
        case .hover:
            // From Memeverse docs: hover = Shadow(color: .ppShadowBlue.opacity(0.28), radius: 20, x: 0, y: 12)
            return (.ppShadowBlue.opacity(0.28), 20, 0, 12)
        case .celebration:
            // From Memeverse docs: celebration = Shadow(color: .ppAccent.opacity(0.4), radius: 30, x: 0, y: 16)
            return (.ppAccent.opacity(0.40), 30, 0, 16)
        case .custom(let color, let radius, let x, let y):
            return (color, radius, x, y)
        }
    }

    // MARK: - Legacy Compatibility (old tuple format)

    /// Legacy small shadow (for backward compatibility during migration)
    static let smLegacy = (color: Color.black.opacity(0.05), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))

    /// Legacy medium shadow
    static let mdLegacy = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))

    /// Legacy large shadow
    static let lgLegacy = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))

    /// Legacy extra large shadow
    static let xlLegacy = (color: Color.black.opacity(0.2), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
}

// MARK: - View Extensions

extension View {
    /// Apply a predefined pastel shadow
    /// - Parameter shadow: The shadow level to apply (default: .md)
    /// - Returns: View with shadow applied
    ///
    /// Example:
    /// ```swift
    /// VStack { }
    ///     .ppShadow(.lift)  // Standard card elevation
    /// ```
    func ppShadow(_ shadow: PPShadow = .md) -> some View {
        let v = shadow.values
        return self.shadow(color: v.color, radius: v.radius, x: v.x, y: v.y)
    }

    /// Apply multiple shadows for depth effect
    /// - Parameter shadows: Array of shadows to layer
    /// - Returns: View with multiple shadows applied
    ///
    /// Example:
    /// ```swift
    /// VStack { }
    ///     .ppShadows([.md, .hover])  // Layered depth
    /// ```
    func ppShadows(_ shadows: [PPShadow]) -> some View {
        var view: AnyView = AnyView(self)
        for shadow in shadows {
            let v = shadow.values
            view = AnyView(view.shadow(color: v.color, radius: v.radius, x: v.x, y: v.y))
        }
        return view
    }

    /// Legacy compatibility - tuple-based shadow (will be deprecated)
    func ppShadow(_ shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

// MARK: - Migration Notes
/*
 MEMEVERSE SPACING & SHADOWS MIGRATION - 2025-11-25
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 MAJOR ADDITIONS:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 1. Component Dimensions (NEW)
    - PPHeight: button, input, quickLogButton, statCard, etc.
    - PPWidth: icon, avatar sizes
    - PPSize: loadingDot, badge, checkmark
    - PPMaxWidth: card, form, content

 2. Corner Radius Additions
    - PPCornerRadius.pill (20pt) - For pill-shaped buttons
    - PPCornerRadius.bubble (40pt) - For speech bubbles

 3. Spacing Addition
    - PPSpacing.jumbo (72pt) - For celebration modals

 4. Pastel Shadow System (MAJOR IMPROVEMENT)
    - Changed from tuples to enum-based system
    - Now chainable and type-safe
    - Uses pastel shadows (ppShadowPink, ppShadowBlue) instead of black
    - Matches Memeverse docs specifications

 COMPONENT HEIGHTS RATIONALE:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 - button (48pt): iOS HIG minimum touch target is 44pt, we use 48pt for comfort
 - input (48pt): Same as button for consistency
 - quickLogButton (90pt): Large touch target for frequent action (from NewHomeView)
 - statCard (140pt): Optimal for displaying stat + icon + label (from NewHomeView)

 SHADOW SYSTEM MIGRATION:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 OLD (Corporate - Black Shadows):
 .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

 NEW (Memeverse - Pastel Shadows):
 .ppShadow(.md)  // Uses ppShadowPink with optimal opacity

 OLD (Tuple Access):
 .ppShadow(PPShadow.md)  // Awkward tuple syntax

 NEW (Enum Case):
 .ppShadow(.md)  // Clean, chainable

 PASTEL SHADOW VALUES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 .sm          → ppShadowPink @ 15%, radius 4, y 2
 .md          → ppShadowPink @ 25%, radius 8, y 4
 .lg          → ppShadowPink @ 35%, radius 14, y 6
 .xl          → ppShadowPink @ 40%, radius 20, y 10
 .lift        → ppShadowPink @ 35%, radius 14, y 6 (Memeverse docs)
 .hover       → ppShadowBlue @ 28%, radius 20, y 12 (Memeverse docs)
 .celebration → ppAccent @ 40%, radius 30, y 16 (Memeverse docs)

 USAGE EXAMPLES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 // Standard card with pastel shadow
 VStack { }
     .background(Color.ppSurface)
     .cornerRadius(PPCornerRadius.md)
     .ppShadow(.lift)

 // Button with hover state
 Button("Click") { }
     .frame(height: PPHeight.button)
     .cornerRadius(PPCornerRadius.pill)
     .ppShadow(isHovered ? .hover : .md)

 // Multiple shadows for depth
 VStack { }
     .ppShadows([.md, .hover])

 // Custom shadow
 VStack { }
     .ppShadow(.custom(color: .ppShadowPink, radius: 10, x: 0, y: 5))

 // Component dimensions
 Button("Log") { }
     .frame(height: PPHeight.quickLogButton)
     .frame(maxWidth: PPMaxWidth.card)
     .cornerRadius(PPCornerRadius.pill)

 // Loading indicator
 Circle()
     .frame(width: PPSize.loadingDot, height: PPSize.loadingDot)

 // Avatar
 Circle()
     .frame(width: PPWidth.avatar, height: PPWidth.avatar)

 BEFORE → AFTER EXAMPLES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Hardcoded dimensions (VIOLATIONS):
 .frame(height: 90) → .frame(height: PPHeight.quickLogButton)
 .frame(height: 140) → .frame(height: PPHeight.statCard)
 .frame(width: 8, height: 8) → .frame(width: PPSize.loadingDot, height: PPSize.loadingDot)
 .frame(maxWidth: 350) → .frame(maxWidth: PPMaxWidth.card)

 Hardcoded corner radius (VIOLATIONS):
 .cornerRadius(20) → .cornerRadius(PPCornerRadius.pill)
 .cornerRadius(24) → .cornerRadius(PPCornerRadius.xl)

 Black shadows (VIOLATIONS):
 .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3) → .ppShadow(.sm)
 .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 12) → .ppShadow(.hover)

 ACCESSIBILITY NOTES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 - Minimum touch target: 48pt (PPHeight.button) meets iOS HIG guidelines
 - quickLogButton (90pt) provides generous touch target for frequent action
 - Pastel shadows are subtle but provide depth cues
 - All spacing follows 8pt grid for consistency

 8PT GRID COMPLIANCE:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ✅ All base spacing tokens are multiples of 4 or 8
 ⚠️ xxxs (2pt) breaks the grid - use sparingly
 ✅ All corner radii are multiples of 4
 ✅ Component heights follow 4pt increments

 MIGRATION STATUS:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ✅ Phase 0: Migration mapping complete
 ✅ Phase 1.1: PPColors.swift updated with Memeverse palette
 ✅ Phase 1.2: PPTypography.swift updated with kawaii rounded style
 ✅ Phase 1.3: PPSpacing.swift updated with dimensions & pastel shadows
 ⏳ Phase 1.4: PPGradients.swift (next)
 ⏳ Phase 2: Update components (pending)
 ⏳ Phase 3: Update views (pending)

 See docs/MEMEVERSE_MIGRATION.md for full migration plan.
 */
