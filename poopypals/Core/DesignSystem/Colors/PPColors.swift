//
//  PPColors.swift
//  PoopyPals
//
//  Design System - Color Palette
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    static let ppPrimary = Color(hex: "#6366F1")        // Indigo
    static let ppSecondary = Color(hex: "#10B981")      // Green
    static let ppAccent = Color(hex: "#F59E0B")         // Amber
    static let ppDanger = Color(hex: "#EF4444")         // Red

    // MARK: - Backgrounds
    static let ppBackground = Color(UIColor.systemBackground)
    static let ppBackgroundSecondary = Color(UIColor.secondarySystemBackground)
    static let ppBackgroundTertiary = Color(UIColor.tertiarySystemBackground)

    // MARK: - Text
    static let ppTextPrimary = Color(UIColor.label)
    static let ppTextSecondary = Color(UIColor.secondaryLabel)
    static let ppTextTertiary = Color(UIColor.tertiaryLabel)

    // MARK: - Borders & Dividers
    static let ppBorder = Color(UIColor.separator)
    static let ppBorderFocused = Color(hex: "#6366F1")
    static let ppDivider = Color(UIColor.separator)

    // MARK: - Status Colors
    static let ppSuccess = Color(hex: "#10B981")
    static let ppWarning = Color(hex: "#F59E0B")
    static let ppError = Color(hex: "#EF4444")
    static let ppInfo = Color(hex: "#3B82F6")

    // MARK: - Rating Colors (for emoji ratings)
    static let ppRatingGreat = Color(hex: "#10B981")       // Green
    static let ppRatingGood = Color(hex: "#3B82F6")        // Blue
    static let ppRatingOkay = Color(hex: "#F59E0B")        // Amber
    static let ppRatingBad = Color(hex: "#F97316")         // Orange
    static let ppRatingTerrible = Color(hex: "#EF4444")    // Red

    // MARK: - Hex Initializer
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
