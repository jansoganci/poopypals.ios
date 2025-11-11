//
//  PPSpacing.swift
//  PoopyPals
//
//  Design System - Spacing (8pt grid)
//

import SwiftUI

enum PPSpacing {
    static let xxxs: CGFloat = 2      // Tight spacing
    static let xxs: CGFloat = 4       // Very small gaps
    static let xs: CGFloat = 8        // Small gaps
    static let sm: CGFloat = 12       // Compact spacing
    static let md: CGFloat = 16       // Default spacing
    static let lg: CGFloat = 24       // Section spacing
    static let xl: CGFloat = 32       // Large spacing
    static let xxl: CGFloat = 48      // Extra large spacing
    static let xxxl: CGFloat = 64     // Hero spacing
}

enum PPCornerRadius {
    static let xs: CGFloat = 4        // Small elements
    static let sm: CGFloat = 8        // Buttons, inputs
    static let md: CGFloat = 12       // Cards
    static let lg: CGFloat = 16       // Large cards
    static let xl: CGFloat = 24       // Hero elements
    static let full: CGFloat = 9999   // Circular
}

enum PPShadow {
    static let sm = (color: Color.black.opacity(0.05), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
    static let md = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
    static let lg = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    static let xl = (color: Color.black.opacity(0.2), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
}

extension View {
    func ppShadow(_ shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
