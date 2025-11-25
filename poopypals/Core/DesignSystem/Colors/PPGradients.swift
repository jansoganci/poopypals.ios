//
//  PPGradients.swift
//  PoopyPals
//
//  Design System - Memeverse Gradient Definitions
//  Created: 2025-11-25 - MEMEVERSE MIGRATION
//

import SwiftUI

/// Predefined gradient combinations for Memeverse aesthetic
///
/// All gradients use pastel colors from the Memeverse palette to maintain
/// visual consistency and kawaii feel across the app.
enum PPGradients {

    // MARK: - Primary Gradients (Core Brand)

    /// Peach → Bubblegum Pink (Primary cards, buttons)
    /// Use for: Main CTAs, primary cards, hero sections
    static let peachPink: [Color] = [
        .ppMain,        // #FFB8A0 Soft Peach
        .ppBubblegum    // #FFB3D9 Bubblegum Pink
    ]

    /// Mint → Lavender (Streak cards, secondary elements)
    /// Use for: Streak displays, secondary cards, info sections
    static let mintLavender: [Color] = [
        .ppSecondary,          // #B4E7CE Mint
        .ppSupportLavender     // #C7AFFF Support Lavender
    ]

    /// Peach → Yellow (Primary actions, CTAs)
    /// Use for: Quick log buttons, important CTAs
    static let peachYellow: [Color] = [
        .ppMain,     // #FFB8A0 Soft Peach
        .ppAccent    // #FFEC5C Sunshine Yellow
    ]

    // MARK: - Feedback & Status Gradients

    /// Coral → Orange (Alerts, warnings)
    /// Use for: Error states, warning banners (friendly, not harsh)
    static let coralOrange: [Color] = [
        .ppFunAlert,        // #FF6B6B Friendly Coral
        .ppPlayfulOrange    // #FF9B50 Playful Orange
    ]

    /// Mint → Success Green (Success states, achievements)
    /// Use for: Success messages, completed achievements
    static let mintSuccess: [Color] = [
        .ppSecondary,   // #B4E7CE Mint
        .ppPositive     // #8BE5A8 Success Green
    ]

    /// Yellow → Orange (Warning states)
    /// Use for: Mild warnings, progress indicators
    static let yellowOrange: [Color] = [
        .ppAccent,          // #FFEC5C Sunshine Yellow
        .ppPlayfulOrange    // #FF9B50 Playful Orange
    ]

    // MARK: - Rainbow & Celebration Gradients

    /// Peach → Yellow → Mint (3-stop rainbow)
    /// Use for: Celebrations, festive moments, variety
    static let rainbow: [Color] = [
        .ppMain,        // #FFB8A0 Soft Peach
        .ppAccent,      // #FFEC5C Sunshine Yellow
        .ppSecondary    // #B4E7CE Mint
    ]

    /// Full spectrum celebration gradient (5-stop - achievement unlocks)
    /// Use for: Major achievements, milestone celebrations
    static let celebration: [Color] = [
        .ppBubblegum,       // #FFB3D9 Bubblegum Pink
        .ppMain,            // #FFB8A0 Soft Peach
        .ppAccent,          // #FFEC5C Sunshine Yellow
        .ppSecondary,       // #B4E7CE Mint
        .ppSupportLavender  // #C7AFFF Support Lavender
    ]

    // MARK: - Surface Gradients (Subtle backgrounds)

    /// Subtle background gradient (light surfaces)
    /// Use for: Card backgrounds, modal backgrounds
    static let surfaceSubtle: [Color] = [
        .ppSurface,      // #FFFFFF Pure White
        .ppSurfaceAlt    // #FEEAF5 Blush Pink
    ]

    /// Pastel background (decorative sections)
    /// Use for: Section backgrounds, decorative panels
    static let backgroundPastel: [Color] = [
        .ppBackground,   // #FFF8F3 Warm White
        .ppSurfaceAlt    // #FEEAF5 Blush Pink
    ]

    // MARK: - Legacy Mappings (backward compatibility during migration)

    /// OLD: PPGradients.purple → NEW: peachPink
    /// @deprecated Use peachPink instead
    static let purple = peachPink

    /// OLD: PPGradients.ocean → NEW: mintLavender
    /// @deprecated Use mintLavender instead
    static let ocean = mintLavender

    /// OLD: PPGradients.fire → NEW: coralOrange
    /// @deprecated Use coralOrange instead
    static let fire = coralOrange

    /// OLD: PPGradients.sunset → NEW: rainbow
    /// @deprecated Use rainbow instead
    static let sunset = rainbow

    /// OLD: PPGradients.mint → NEW: mintSuccess
    /// @deprecated Use mintSuccess instead
    static let mint = mintSuccess

    // Note: PPGradients.poopy (brown gradient) has been REMOVED
    // It doesn't fit the Memeverse pastel aesthetic
}

// MARK: - Gradient Helper Extensions

extension LinearGradient {
    /// Create a gradient from PPGradients with default parameters
    /// - Parameters:
    ///   - colors: Array of colors from PPGradients
    ///   - startPoint: Starting point (default: topLeading)
    ///   - endPoint: Ending point (default: bottomTrailing)
    /// - Returns: LinearGradient configured with Memeverse colors
    ///
    /// Example:
    /// ```swift
    /// .background(LinearGradient.ppGradient(PPGradients.peachPink))
    /// ```
    static func ppGradient(
        _ colors: [Color],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) -> LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

extension RadialGradient {
    /// Create a radial gradient from PPGradients
    /// - Parameters:
    ///   - colors: Array of colors from PPGradients
    ///   - center: Center point (default: center)
    ///   - startRadius: Starting radius (default: 0)
    ///   - endRadius: Ending radius (default: 200)
    /// - Returns: RadialGradient configured with Memeverse colors
    ///
    /// Example:
    /// ```swift
    /// .background(RadialGradient.ppGradient(PPGradients.celebration, endRadius: 300))
    /// ```
    static func ppGradient(
        _ colors: [Color],
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 200
    ) -> RadialGradient {
        RadialGradient(
            colors: colors,
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }
}

extension AngularGradient {
    /// Create an angular gradient from PPGradients
    /// - Parameters:
    ///   - colors: Array of colors from PPGradients
    ///   - center: Center point (default: center)
    ///   - angle: Starting angle (default: 0°)
    /// - Returns: AngularGradient configured with Memeverse colors
    ///
    /// Example:
    /// ```swift
    /// .background(AngularGradient.ppGradient(PPGradients.rainbow, angle: .degrees(45)))
    /// ```
    static func ppGradient(
        _ colors: [Color],
        center: UnitPoint = .center,
        angle: Angle = .degrees(0)
    ) -> AngularGradient {
        AngularGradient(
            colors: colors,
            center: center,
            angle: angle
        )
    }
}

// MARK: - Usage Examples
/*
 USAGE EXAMPLES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 // Standard card background
 VStack { }
     .background(LinearGradient.ppGradient(PPGradients.peachPink))

 // Custom start/end points
 VStack { }
     .background(
         LinearGradient.ppGradient(
             PPGradients.mintLavender,
             startPoint: .leading,
             endPoint: .trailing
         )
     )

 // Streak card
 VStack { }
     .background(LinearGradient.ppGradient(PPGradients.mintLavender))

 // Primary button
 Button("Quick Log") { }
     .background(LinearGradient.ppGradient(PPGradients.peachYellow))

 // Achievement unlock
 VStack { }
     .background(LinearGradient.ppGradient(PPGradients.celebration))

 // Radial gradient (for glows, highlights)
 Circle()
     .fill(RadialGradient.ppGradient(PPGradients.peachPink, endRadius: 100))

 // Angular gradient (for loading spinners, circular progress)
 Circle()
     .fill(AngularGradient.ppGradient(PPGradients.rainbow, angle: .degrees(rotation)))

 // Legacy compatibility (old code still works during migration)
 VStack { }
     .background(LinearGradient.ppGradient(PPGradients.purple))  // Maps to peachPink
 */

// MARK: - Migration Notes
/*
 GRADIENT MIGRATION - 2025-11-25
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 MOVED FROM: GlossyCard.swift (hardcoded in component)
 MOVED TO: PPGradients.swift (centralized design tokens)

 OLD CORPORATE → NEW MEMEVERSE:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 purple (#667EEA → #764BA2)      → peachPink (#FFB8A0 → #FFB3D9)
 ocean (#4E54C8 → #8F94FB)       → mintLavender (#B4E7CE → #C7AFFF)
 fire (#FF416C → #FF4B2B)        → coralOrange (#FF6B6B → #FF9B50)
 sunset (3-stop vibrant)         → rainbow (3-stop pastel)
 mint (dark green/blue)          → mintSuccess (pastel mint/green)
 poopy (brown gradient)          → REMOVED (doesn't fit aesthetic)

 NEW MEMEVERSE GRADIENTS:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 - peachYellow (#FFB8A0 → #FFEC5C) - Primary actions
 - yellowOrange (#FFEC5C → #FF9B50) - Warnings
 - celebration (5-stop pastel rainbow) - Achievement unlocks
 - surfaceSubtle (white → blush) - Subtle card backgrounds
 - backgroundPastel (warm white → blush) - Decorative sections

 GRADIENT USAGE PATTERNS:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Primary Brand:
 - peachPink: Main CTAs, hero cards, primary actions
 - peachYellow: Important buttons, quick actions

 Secondary/Info:
 - mintLavender: Streak displays, stats, info cards
 - mintSuccess: Success states, completed items

 Feedback:
 - coralOrange: Friendly errors, warnings
 - yellowOrange: Mild warnings, progress

 Celebration:
 - rainbow: Fun moments, variety
 - celebration: Major achievements, milestones

 Subtle:
 - surfaceSubtle: Card backgrounds
 - backgroundPastel: Decorative sections

 GRADIENT DIRECTION GUIDELINES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 - Cards: topLeading → bottomTrailing (default, adds depth)
 - Buttons: leading → trailing (horizontal flow)
 - Headers: top → bottom (vertical gradient)
 - Backgrounds: topLeading → bottomTrailing (subtle, non-distracting)
 - Highlights: Use radial gradients (center-out glow effect)

 HELPER EXTENSIONS:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 LinearGradient.ppGradient(_:startPoint:endPoint:)
 - Quick gradient creation with sensible defaults

 RadialGradient.ppGradient(_:center:startRadius:endRadius:)
 - For glows, highlights, circular effects

 AngularGradient.ppGradient(_:center:angle:)
 - For loading spinners, circular progress indicators

 MIGRATION STATUS:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ✅ Phase 0: Migration mapping complete
 ✅ Phase 1.1: PPColors.swift updated with Memeverse palette
 ✅ Phase 1.2: PPTypography.swift updated with kawaii rounded style
 ✅ Phase 1.3: PPSpacing.swift updated with dimensions & pastel shadows
 ✅ Phase 1.4: PPGradients.swift created with Memeverse gradients
 ✅ PHASE 1 COMPLETE! 🎉
 ⏳ Phase 2: Update components (next)
 ⏳ Phase 3: Update views (pending)

 See docs/MEMEVERSE_MIGRATION.md for full migration plan.
 */
