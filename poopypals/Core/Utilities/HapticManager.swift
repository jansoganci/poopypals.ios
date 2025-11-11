//
//  HapticManager.swift
//  PoopyPals
//
//  Haptic Feedback Manager - Makes interactions feel premium
//

import UIKit

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    // MARK: - Impact Feedback

    /// Light impact (button taps, selections)
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact (log creation, navigation)
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact (achievement unlock, challenge complete)
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Rigid impact (errors, warnings)
    func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }

    /// Soft impact (subtle interactions)
    func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success notification (achievement, challenge won)
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification (failed action)
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed (scrolling through options)
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Contextual Haptics (App-specific)

    /// Achievement unlocked - celebration pattern
    func achievementUnlocked() {
        // Triple heavy impact with delays
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.medium()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.light()
        }
    }

    /// Log created successfully
    func logCreated() {
        success()
    }

    /// Streak milestone reached
    func streakMilestone() {
        // Two quick impacts
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.medium()
        }
    }

    /// Button tapped
    func buttonTapped() {
        light()
    }

    /// Rank changed in challenge
    func rankChanged(up: Bool) {
        if up {
            // Positive rank change
            success()
        } else {
            // Negative rank change
            soft()
        }
    }

    /// Challenge completed
    func challengeCompleted(won: Bool) {
        if won {
            // Victory pattern
            heavy()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.heavy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.success()
            }
        } else {
            soft()
        }
    }
}
