//
//  ShareSheet.swift
//  PoopyPals
//
//  Helper for iOS native share sheet
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let excludedActivityTypes: [UIActivity.ActivityType]?

    init(items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        self.items = items
        self.excludedActivityTypes = excludedActivityTypes
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - View Extension for Easy Sharing

extension View {
    func shareSheet(isPresented: Binding<Bool>, items: [Any]) -> some View {
        self.sheet(isPresented: isPresented) {
            ShareSheet(items: items)
        }
    }
}

// MARK: - Share Helper Functions

struct ShareHelper {
    /// Share achievement with image and text
    static func shareAchievement(_ achievement: Achievement, streakCount: Int? = nil) -> [Any] {
        let card = ShareableAchievementCard(achievement: achievement, streakCount: streakCount)
        let image = card.asImage()

        return [
            image,
            achievement.shareableText
        ]
    }

    /// Share simple text (for challenges)
    static func shareText(_ text: String) -> [Any] {
        return [text]
    }

    /// Share URL (for invite links)
    static func shareURL(_ url: URL, message: String) -> [Any] {
        return [message, url]
    }
}
