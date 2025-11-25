//
//  PPTypography.swift
//  PoopyPals
//
//  Design System - Typography (Memeverse Kawaii Style)
//  Last Updated: 2025-11-25 - MEMEVERSE MIGRATION
//

import SwiftUI

extension Font {
    // MARK: - Display (Large Headings) - ROUNDED for kawaii feel

    /// Display large - 34pt bold rounded (hero sections)
    static let ppDisplayLarge = Font.system(size: 34, weight: .bold, design: .rounded)

    /// Display medium - 28pt bold rounded (major headings)
    static let ppDisplayMedium = Font.system(size: 28, weight: .bold, design: .rounded)

    /// Display small - 22pt semibold rounded (section headings)
    static let ppDisplaySmall = Font.system(size: 22, weight: .semibold, design: .rounded)

    // MARK: - Titles - ROUNDED

    /// Title 1 - 28pt semibold rounded
    static let ppTitle1 = Font.system(size: 28, weight: .semibold, design: .rounded)

    /// Title 2 - 22pt semibold rounded
    static let ppTitle2 = Font.system(size: 22, weight: .semibold, design: .rounded)

    /// Title 3 - 20pt semibold rounded
    static let ppTitle3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // MARK: - Body Text - ROUNDED for consistency

    /// Body large - 17pt regular rounded
    static let ppBodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)

    /// Body - 15pt regular rounded (default body text)
    static let ppBody = Font.system(size: 15, weight: .regular, design: .rounded)

    /// Body small - 13pt regular rounded
    static let ppBodySmall = Font.system(size: 13, weight: .regular, design: .rounded)

    // MARK: - Labels - ROUNDED

    /// Label large - 15pt medium rounded
    static let ppLabelLarge = Font.system(size: 15, weight: .medium, design: .rounded)

    /// Label - 13pt medium rounded (standard UI labels)
    static let ppLabel = Font.system(size: 13, weight: .medium, design: .rounded)

    /// Label small - 11pt medium rounded
    static let ppLabelSmall = Font.system(size: 11, weight: .medium, design: .rounded)

    // MARK: - Captions - ROUNDED

    /// Caption - 12pt regular rounded
    static let ppCaption = Font.system(size: 12, weight: .regular, design: .rounded)

    /// Caption small - 10pt regular rounded
    static let ppCaptionSmall = Font.system(size: 10, weight: .regular, design: .rounded)

    // MARK: - Numbers (for stats display) - ROUNDED

    /// Number hero - 72pt bold rounded (large streak displays, hero stats)
    static let ppNumberHero = Font.system(size: 72, weight: .bold, design: .rounded)

    /// Number large - 48pt bold rounded (prominent numbers)
    static let ppNumberLarge = Font.system(size: 48, weight: .bold, design: .rounded)

    /// Number medium - 32pt bold rounded (standard stat displays)
    static let ppNumberMedium = Font.system(size: 32, weight: .bold, design: .rounded)

    /// Number small - 24pt semibold rounded (compact stats)
    static let ppNumberSmall = Font.system(size: 24, weight: .semibold, design: .rounded)

    // MARK: - Buttons (NEW - dedicated button text styles)

    /// Button large - 17pt semibold rounded (primary CTAs)
    static let ppButtonLarge = Font.system(size: 17, weight: .semibold, design: .rounded)

    /// Button - 15pt semibold rounded (standard buttons)
    static let ppButton = Font.system(size: 15, weight: .semibold, design: .rounded)

    /// Button small - 13pt medium rounded (compact buttons)
    static let ppButtonSmall = Font.system(size: 13, weight: .medium, design: .rounded)

    // MARK: - Emoji & Icons (NEW - for decorative elements)

    /// Small emoji - 44pt (e.g., in rating buttons)
    static let ppEmojiSmall = Font.system(size: 44, weight: .regular, design: .default)

    /// Medium emoji - 60pt (e.g., in cards)
    static let ppEmojiMedium = Font.system(size: 60, weight: .regular, design: .default)

    /// Large emoji - 80pt (e.g., streak flame displays)
    static let ppEmojiLarge = Font.system(size: 80, weight: .regular, design: .default)

    /// Extra large emoji - 100pt (e.g., hero sections, celebrations)
    static let ppEmojiXL = Font.system(size: 100, weight: .regular, design: .default)

    // MARK: - Input Fields (NEW)

    /// Input field text - 16pt regular rounded (optimal for text input)
    static let ppInput = Font.system(size: 16, weight: .regular, design: .rounded)

    /// Input field label - 12pt medium rounded (field labels)
    static let ppInputLabel = Font.system(size: 12, weight: .medium, design: .rounded)

    /// Input field placeholder - 16pt regular rounded (placeholder text)
    static let ppInputPlaceholder = Font.system(size: 16, weight: .regular, design: .rounded)

    // MARK: - Links & Special (NEW)

    /// Clickable link text - 15pt medium rounded
    static let ppLink = Font.system(size: 15, weight: .medium, design: .rounded)

    /// Meme/sticker caption text - 24pt bold rounded (fun, playful text)
    static let ppMeme = Font.system(size: 24, weight: .bold, design: .rounded)
}

// MARK: - Migration Notes
/*
 MEMEVERSE TYPOGRAPHY MIGRATION - 2025-11-25
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 MAJOR CHANGES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 1. ALL fonts now use .design(.rounded) for kawaii aesthetic
    - Before: .system(size: X, weight: Y, design: .default)
    - After:  .system(size: X, weight: Y, design: .rounded)

 2. Added emoji size tokens (addresses 13 violations)
    - ppEmojiSmall (44pt) - Rating buttons
    - ppEmojiMedium (60pt) - Cards, avatars
    - ppEmojiLarge (80pt) - Streak displays
    - ppEmojiXL (100pt) - Hero sections

 3. Added button text styles
    - ppButtonLarge (17pt semibold)
    - ppButton (15pt semibold)
    - ppButtonSmall (13pt medium)

 4. Added input field styles
    - ppInput (16pt regular) - Text input
    - ppInputLabel (12pt medium) - Field labels
    - ppInputPlaceholder (16pt regular) - Placeholder text

 5. Added ppNumberHero (72pt) for large streak displays

 6. Added ppLink and ppMeme styles for special text

 BEFORE → AFTER EXAMPLES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Display:
 - .system(size: 34, design: .default) → .ppDisplayLarge (.rounded)

 Body:
 - .system(size: 15, design: .default) → .ppBody (.rounded)

 Hardcoded emoji (VIOLATION):
 - .system(size: 44) → .ppEmojiSmall
 - .system(size: 60) → .ppEmojiMedium
 - .system(size: 72) → .ppNumberHero (for numbers) or .ppEmojiLarge (for emoji)
 - .system(size: 80) → .ppEmojiLarge
 - .system(size: 100) → .ppEmojiXL

 Hardcoded button text (VIOLATION):
 - Label text in buttons → .ppButton or .ppButtonLarge

 TYPOGRAPHY SCALE:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Display:  34pt → 28pt → 22pt (1.21x ratio)
 Title:    28pt → 22pt → 20pt (1.27x ratio)
 Body:     17pt → 15pt → 13pt (1.15x ratio)
 Label:    15pt → 13pt → 11pt (1.18x ratio)
 Numbers:  72pt → 48pt → 32pt → 24pt (1.5x ratio)
 Emoji:    100pt → 80pt → 60pt → 44pt (1.36x ratio)

 All ratios follow best practices for visual hierarchy.

 CUSTOM FONT SUPPORT (FUTURE):
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Documentation (docs/04-design-system.md) mentions custom font "Baloo 2"
 for display text. This can be added later with:

 static let ppDisplayLarge = Font.custom("Baloo2-Bold", size: 34, relativeTo: .largeTitle)

 For now, SF Pro Rounded provides excellent kawaii aesthetic.

 DYNAMIC TYPE SUPPORT (FUTURE ENHANCEMENT):
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Current: Fixed sizes
 Future: Add .scaledMetric(relativeTo:) for accessibility

 Example:
 static let ppBody = Font.system(size: 15, weight: .regular, design: .rounded)
     .scaledMetric(relativeTo: .body)

 USAGE EXAMPLES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 // Display text
 Text("Welcome!")
     .font(.ppDisplayLarge)

 // Body text
 Text("Track your bathroom habits")
     .font(.ppBody)

 // Button text
 Button("Quick Log") { }
     .font(.ppButton)

 // Emoji in rating button
 Text("😊")
     .font(.ppEmojiSmall)

 // Hero streak number
 Text("47")
     .font(.ppNumberHero)

 // Input field
 TextField("Enter notes", text: $notes)
     .font(.ppInput)

 ACCESSIBILITY NOTES:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 - Minimum body text size: 15pt (meets accessibility guidelines)
 - Caption text at 10pt may be too small for some users
 - Rounded design improves readability and friendliness
 - Consider adding Dynamic Type support in future updates

 MIGRATION STATUS:
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ✅ Phase 0: Migration mapping complete
 ✅ Phase 1.1: PPColors.swift updated
 ✅ Phase 1.2: PPTypography.swift updated with kawaii rounded style
 ⏳ Phase 1.3: PPSpacing.swift (next)
 ⏳ Phase 1.4: PPGradients.swift (pending)
 ⏳ Phase 2: Update components (pending)
 ⏳ Phase 3: Update views (pending)

 See docs/MEMEVERSE_MIGRATION.md for full migration plan.
 */
