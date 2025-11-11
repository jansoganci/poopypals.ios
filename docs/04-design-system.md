# PoopyPals Memeverse Design System

## 🎨 Design Philosophy

PoopyPals is evolving into a meme-forward, kawaii social playground. Every pixel should spark joy, invite creativity, and feel instantly shareable. Aim for:

- **Playful-cute hybrid:** Soft, rounded, huggable surfaces with cheeky meme energy.
- **Accessible fun:** Friendly copy, readable type, WCAG AA contrast, and intuitive flows.
- **Instant delight:** Animations, micro-interactions, and easter eggs that reward curiosity.
- **Cultural fluency:** Confident, viral tone for US users; warm, community-centric tone for Turkey, including support for Turkish characters.
- **Modular craft:** Tokens feed components, components feed patterns, patterns feed features. Keep boundaries clean across frontend, backend, and shared services.

Always ask: “Would Gen Z screenshot this and share it?” If not, dial up the quirky charm before shipping.

---

## 🌈 Color System

We are moving from a corporate palette to cotton-candy gradients, pastel outlines, and plush shadows. Colors must support Light, Dark, High-Contrast, and animation states.

### Brand & Semantic Tokens

| Token | Light Mode | Dark Mode | Usage |
| --- | --- | --- | --- |
| `ppMain` | `#FFB8A0` (Soft Peach) | `#FF8E6F` | Primary actions, highlights |
| `ppBubblegum` | `#FFB3D9` (Bubblegum Pink) | `#FF7FC4` | Alternative highlight, stickers |
| `ppSecondary` | `#B4E7CE` (Mint) | `#7DD9B0` | Secondary actions, cards |
| `ppAccent` | `#FFEC5C` (Sunshine Yellow) | `#FFD84D` | Sparkles, emphasis, streaks |
| `ppPlayfulOrange` | `#FF9B50` | `#FF7A1F` | Hover accents, callouts |
| `ppSupportLavender` | `#C7AFFF` | `#A98CFC` | Tooltips, tertiary backgrounds |
| `ppBackground` | `#FFF8F3` | `#1C1A24` | App canvas |
| `ppSurface` | `#FFFFFF` | `#2A2635` | Cards, sheets |
| `ppSurfaceAlt` | `#FEEAF5` | `#352F43` | Decorative surfaces |
| `ppOutline` | `#FFCCE1` | `#4C3C57` | 2-3pt outlines, dividers |
| `ppShadowPink` | `#FFC9EC` @ 35% | `#39263F` @ 45% | Primary shadows |
| `ppShadowBlue` | `#C7E4FF` @ 25% | `#002A57` @ 45% | Secondary shadows |
| `ppTextPrimary` | `#2E1135` | `#FDF7FF` | Primary copy |
| `ppTextSecondary` | `#5C3A63` | `#D8C6FF` | Body/support copy |
| `ppTextTertiary` | `#8C6C92` | `#B59CE0` | Meta labels, disabled |
| `ppPositive` | `#8BE5A8` | `#63D48A` | Success states, gamification |
| `ppWarning` | `#FFCF6B` | `#FFB347` | Mild alerts, progress cues |
| `ppFunAlert` | `#FF6B6B` (Coral) | `#FF5A5A` | Errors, but keep friendly |

### SwiftUI Tokens

```swift
extension Color {
    // MARK: - Core Pastels
    static let ppMain = Color("PPMain")
    static let ppSecondary = Color("PPSecondary")
    static let ppAccent = Color("PPAccent")
    static let ppPlayfulOrange = Color("PPPlayfulOrange")
    static let ppBubblegum = Color("PPBubblegum")
    static let ppSupportLavender = Color("PPSupportLavender")

    // MARK: - Surfaces & Structure
    static let ppBackground = Color("PPBackground")
    static let ppSurface = Color("PPSurface")
    static let ppSurfaceAlt = Color("PPSurfaceAlt")
    static let ppOutline = Color("PPOutline")

    // MARK: - Shadows (use with gradients)
    static let ppShadowPink = Color("PPShadowPink")
    static let ppShadowBlue = Color("PPShadowBlue")

    // MARK: - Text & Feedback
    static let ppTextPrimary = Color("PPTextPrimary")
    static let ppTextSecondary = Color("PPTextSecondary")
    static let ppTextTertiary = Color("PPTextTertiary")
    static let ppPositive = Color("PPPositive")
    static let ppWarning = Color("PPWarning")
    static let ppFunAlert = Color("PPFunAlert")
}
```

### Implementation Notes

- **Outlines:** Use `ppOutline` for 2pt strokes; 3pt for primary callouts. Ensure strokes tint adaptively to Dark Mode.
- **Gradients:** Prefer two-stop gradients (e.g., `ppMain` → `ppBubblegum`) with 35° angle or radial center-left. Use `ppMain` → `ppAccent` for primary actions.
- **Shadows:** Replace black shadows with pastel ones. Example: `.shadow(color: .ppShadowPink.opacity(0.35), radius: 12, x: 0, y: 6)`.
- **Assets setup:** Create color sets in `Assets.xcassets/Colors/`, adding light, dark, and high-contrast variants. Keep hex codes documented in `Contents.json`.

---

## 📝 Typography

### Font Stack

- **Display / Headlines:** `Baloo 2` (Bold) with a 6° rotation applied via transforms for hero sections; fallback to `Fredoka`, `Cooper Black`, then `SF Pro Rounded`.
- **Body & UI Copy:** `SF Pro Rounded` Regular/Medium. Ensure Turkish glyph support (ı, ş, ğ).
- **Meme Text:** `Baloo 2` SemiBold with pastel outline and drop shadow for sticker captions.

Load custom fonts via bundle and register in `Info.plist`. Provide font files in `Resources/Fonts/`.

### Scale

```swift
extension Font {
    // MARK: - Display
    static let ppDisplayXL = Font.custom("Baloo2-Bold", size: 48, relativeTo: .largeTitle)
    static let ppDisplayL = Font.custom("Baloo2-Bold", size: 40, relativeTo: .title)
    static let ppDisplayM = Font.custom("Baloo2-Semibold", size: 32, relativeTo: .title2)

    // MARK: - Titles
    static let ppTitleL = Font.custom("Baloo2-Semibold", size: 26, relativeTo: .title2)
    static let ppTitleM = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let ppTitleS = Font.system(size: 20, weight: .medium, design: .rounded)

    // MARK: - Body
    static let ppBodyL = Font.system(size: 18, weight: .regular, design: .rounded)
    static let ppBody = Font.system(size: 16, weight: .regular, design: .rounded)
    static let ppBodyS = Font.system(size: 14, weight: .regular, design: .rounded)

    // MARK: - Labels
    static let ppLabel = Font.system(size: 13, weight: .medium, design: .rounded)
    static let ppLabelS = Font.system(size: 11, weight: .medium, design: .rounded)

    // MARK: - Meme & Stats
    static let ppMeme = Font.custom("Baloo2-Bold", size: 24, relativeTo: .title3)
    static let ppNumber = Font.custom("Baloo2-Bold", size: 36, relativeTo: .title2)
}
```

### Text Modifiers

```swift
enum PPTextStyle {
    case displayXL, displayL, displayM
    case titleL, titleM, titleS
    case bodyL, body, bodyS
    case label, labelS
    case meme, number
}

struct PPTextStyleModifier: ViewModifier {
    let style: PPTextStyle
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        switch style {
        case .displayXL:
            content
                .font(.ppDisplayXL)
                .foregroundColor(.ppTextPrimary)
                .rotationEffect(.degrees(6))
        case .meme:
            content
                .font(.ppMeme)
                .foregroundColor(.ppTextPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.ppAccent.opacity(colorScheme == .dark ? 0.25 : 0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.ppOutline, lineWidth: 3)
                )
        default:
            content
                .font(font(for: style))
                .foregroundColor(.ppTextPrimary)
        }
    }

    private func font(for style: PPTextStyle) -> Font {
        switch style {
        case .displayL: return .ppDisplayL
        case .displayM: return .ppDisplayM
        case .titleL: return .ppTitleL
        case .titleM: return .ppTitleM
        case .titleS: return .ppTitleS
        case .bodyL: return .ppBodyL
        case .body: return .ppBody
        case .bodyS: return .ppBodyS
        case .label: return .ppLabel
        case .labelS: return .ppLabelS
        case .number: return .ppNumber
        default: return .ppBody
        }
    }
}

extension View {
    func ppStyle(_ style: PPTextStyle) -> some View {
        modifier(PPTextStyleModifier(style: style))
    }
}
```

### Accessibility

- Support Dynamic Type by preferring system text styles where possible.
- Provide `minimumScaleFactor(0.85)` on headings to handle long translations.
- Memetic outlines should pass contrast when combined with interior text; test with `UIColorContrast` audits.

---

## 📏 Layout & Spacing

We still follow an 8pt grid but lean into squishy geometry.

### Spacing Tokens

```swift
enum PPSpacing {
    static let nano: CGFloat = 4    // Sparkle gaps
    static let xs: CGFloat = 8      // Tight clusters
    static let sm: CGFloat = 12     // Compact padding
    static let md: CGFloat = 16     // Default padding
    static let lg: CGFloat = 24     // Section spacing
    static let xl: CGFloat = 32     // Hero breathing room
    static let xxl: CGFloat = 48    // Meme canvases
    static let jumbo: CGFloat = 72  // Celebration modals
}
```

### Corners & Outlines

```swift
enum PPCornerRadius {
    static let pill: CGFloat = 20     // Buttons
    static let card: CGFloat = 28     // Cards + sheets
    static let bubble: CGFloat = 40   // Speech bubbles
    static let full: CGFloat = 9999   // Avatars
}
```

- Apply 2pt `ppOutline` strokes to primary surfaces; 3pt for meme stickers.
- For speech bubbles, use asymmetric radii (e.g., 28/28/40/12) for charm.

### Pastel Shadows

```swift
struct PPShadow {
    static let lift = Shadow(color: .ppShadowPink.opacity(0.35), radius: 14, x: 0, y: 6)
    static let hover = Shadow(color: .ppShadowBlue.opacity(0.28), radius: 20, x: 0, y: 12)
    static let celebration = Shadow(color: .ppAccent.opacity(0.4), radius: 30, x: 0, y: 16)

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

extension View {
    func ppShadow(_ shadow: PPShadow.Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
```

---

## 🧱 Component Library

### Buttons

**Principles:** pill-shaped, gradient fills, bouncy on hover, squishy on press, accessible text labels.

```swift
struct PPPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: PPSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(title)
                    .font(.ppLabel)
                    .padding(.horizontal, PPSpacing.sm)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                LinearGradient(
                    colors: [.ppMain, .ppAccent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(PPCornerRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: PPCornerRadius.pill)
                    .stroke(Color.white.opacity(0.35), lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.94 : 1.0)
            .animation(.ppButtonSpring, value: isPressed)
            .ppShadow(.init(color: .ppShadowPink.opacity(isDisabled ? 0.0 : 0.35),
                            radius: 18, x: 0, y: isPressed ? 4 : 10))
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in guard !isDisabled else { return }; isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .disabled(isDisabled || isLoading)
        .opacity((isDisabled || isLoading) ? 0.6 : 1)
        .accessibilityLabel(title)
        .accessibilityHint("Activates the action with a joyful bounce.")
    }
}
```

Provide secondary (`.ppSecondary → .ppSupportLavender`) and ghost variants with pastel outlines and transparent fills.

### Cards & Surfaces

- Rounded rectangles (`PPCornerRadius.card`), pastel border, drop shadow, optional doodles.
- Use floating animation on hover or scroll idle (`animation(.ppHoverLoop)`).
- Add decorative layers (sparkles, hearts) via overlay assets positioned in corners.

```swift
struct PPCard<Content: View>: View {
    let content: Content
    var outlineColor: Color = .ppOutline
    var background: LinearGradient = LinearGradient(
        colors: [.ppSurface, .ppSurfaceAlt.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(PPSpacing.lg)
            .background(background)
            .cornerRadius(PPCornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: PPCornerRadius.card)
                    .stroke(outlineColor, lineWidth: 2)
            )
            .ppShadow(.lift)
            .modifier(PPHoverFloat())
    }
}
```

`PPHoverFloat` applies a gentle up-down motion (2-4pt) using `.ppHoverLoop`.

### Meme Canvas

- Provide reusable component for meme creation: background gradient, draggable stickers, caption text with outline.
- Stickers reside in `Assets/Stickers/` and should include US & Turkish meme packs.

### Inputs

- **Text fields:** pastel backgrounds, 2pt outlines, inner shadow on focus, pillow squish effect.
- **Emoji selectors:** grid of kawaii icons with bounce on selection.
- **Sliders:** creature-based progress (e.g., worm stretching with value).

### Indicators & Gamification

- Progress bars morph into animated characters (e.g., `PPProgressCritter` that grows cheeks as progress increases).
- Streak counters displayed as balloon stacks; every 7-day streak adds a special balloon with sparkle animation.
- Badges must include playful illustrations and celebratory confetti triggered on unlock.

---

## 🎛 Animation Language

### Timing & Curves

```swift
enum PPAnimation {
    static let snap: Animation = .interpolatingSpring(stiffness: 180, damping: 14)
    static let bounce: Animation = .spring(response: 0.45, dampingFraction: 0.55, blendDuration: 0.2)
    static let jelly: Animation = .spring(response: 0.7, dampingFraction: 0.45, blendDuration: 0.4)
    static let hover: Animation = .easeInOut(duration: 2.4).repeatForever(autoreverses: true)
    static let sparkle: Animation = .easeOut(duration: 0.35)
}

extension Animation {
    static let ppButtonSpring = PPAnimation.bounce
    static let ppHoverLoop = PPAnimation.hover
    static let ppCelebration = PPAnimation.sparkle
}
```

- **Squash & stretch:** Scale buttons to 0.94 on press, 1.05 on release, then settle at 1.0.
- **Micro-interactions:** Add `UINotificationFeedbackGenerator` calls for success, warning, and meme reactions.
- **Modals:** Implement jelly-like open/close using `.ppJellyModifier` (scale 0.8 → 1.05 → 1.0).
- **Sound cues:** Encourage subtle pop or sparkle sounds; keep volume low and optional.

---

## ♿ Accessibility

- Maintain WCAG AA contrast; pastel outlines must meet contrast when combined with surfaces.
- Provide voiceover hints with friendly tone (e.g., “Oops! Our pancake stack toppled—try again.”).
- Support Dynamic Type, Large Content Viewer, and custom actions for meme templates.
- For motion sensitivity, respect `UIAccessibility.isReduceMotionEnabled` by switching to fade/scale transitions.
- Localize all strings for English and Turkish; verify diacritics render cleanly in `Baloo 2` (fallback to system where necessary).

---

## 🌍 Cultural & Market Notes

- **US:** Embrace bold humor, trending meme references, TikTok aesthetic (split gradients, neon outlines). Surface sharing tools prominently.
- **Turkey:** Prioritize warm copy (“Merhaba arkadaşım!”), community prompts, and local meme packs. Ensure `Baloo 2` fallback handles Turkish glyphs gracefully.

---

## 🎁 Delight & Easter Eggs

- Long-press avatars to trigger wobble loops and secret reactions.
- Shake device to spawn floating stickers; allow save/share.
- Celebrate achievements with full-screen confetti, sound pop, and `PPStreakBadge` glow.
- Add contextual emoji reactions (e.g., 😂, 😍) on content feed items with haptic taps.

---

## 📦 Asset Guidelines

- **Illustrations:** Round, big-eyed characters with expressive brows; maintain consistent stroke weight (2.5pt).
- **Icons:** Use custom icon set or SF Symbols with pastel backgrounds and outlines.
- **Stickers:** Provide vector assets in PDF optimized for SwiftUI; ensure each has Light/Dark mode variants.
- **Templates:** Store meme templates under `Resources/Templates/`; include metadata for localization.

---

## 🛠 Technical Specs

- **Platform:** iOS 17+, SwiftUI-first, MVVM architecture, offline-first caching.
- **Performance:** Keep animated surfaces under 60fps; use `.drawingGroup()` for complex composites.
- **Modularity:** Keep design tokens in `Core/DesignSystem`, components in `Core/DesignSystem/Components`, animations in `Core/DesignSystem/Animations`.
- **Testing:** Snapshot tests for Light/Dark/High-Contrast, UI tests for accessibility flows.

---

## 📚 Reference Implementation

See:
- `Core/DesignSystem/Colors/PPColors.swift`
- `Core/DesignSystem/Typography/PPTypography.swift`
- `Core/DesignSystem/Layout/PPLayout.swift`
- `Core/DesignSystem/Animations/PPAnimations.swift`
- `Core/DesignSystem/Components/`

---

**Last Updated:** 2025-11-11  
**Version:** 2.0.0
