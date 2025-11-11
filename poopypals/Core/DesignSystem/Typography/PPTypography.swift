//
//  PPTypography.swift
//  PoopyPals
//
//  Design System - Typography
//

import SwiftUI

extension Font {
    // MARK: - Display (Large Headings)
    static let ppDisplayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let ppDisplayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
    static let ppDisplaySmall = Font.system(size: 22, weight: .semibold, design: .rounded)

    // MARK: - Titles
    static let ppTitle1 = Font.system(size: 28, weight: .semibold, design: .default)
    static let ppTitle2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let ppTitle3 = Font.system(size: 20, weight: .semibold, design: .default)

    // MARK: - Body Text
    static let ppBodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let ppBody = Font.system(size: 15, weight: .regular, design: .default)
    static let ppBodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Labels
    static let ppLabelLarge = Font.system(size: 15, weight: .medium, design: .default)
    static let ppLabel = Font.system(size: 13, weight: .medium, design: .default)
    static let ppLabelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Captions
    static let ppCaption = Font.system(size: 12, weight: .regular, design: .default)
    static let ppCaptionSmall = Font.system(size: 10, weight: .regular, design: .default)

    // MARK: - Numbers (for stats display)
    static let ppNumberLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let ppNumberMedium = Font.system(size: 32, weight: .bold, design: .rounded)
    static let ppNumberSmall = Font.system(size: 24, weight: .semibold, design: .rounded)
}
