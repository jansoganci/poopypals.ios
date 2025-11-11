//
//  ShareableAchievementCard.swift
//  PoopyPals
//
//  VIRAL FEATURE: Generate shareable achievement cards
//

import SwiftUI

struct ShareableAchievementCard: View {
    let achievement: Achievement
    let streakCount: Int?  // Optional streak number to display

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.ppPrimary, .ppSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: PPSpacing.lg) {
                // Achievement Icon
                Image(systemName: achievement.iconName)
                    .font(.system(size: 80))
                    .foregroundColor(.white)

                // Achievement Title
                Text(achievement.title)
                    .font(.ppTitle1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Streak Count (if applicable)
                if let streak = streakCount {
                    HStack(spacing: PPSpacing.xs) {
                        Image(systemName: "flame.fill")
                            .font(.ppNumberMedium)
                        Text("\(streak)")
                            .font(.ppNumberLarge)
                    }
                    .foregroundColor(.white)
                }

                // Achievement Description
                Text(achievement.description)
                    .font(.ppBody)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PPSpacing.xl)

                Spacer()

                // App Branding
                VStack(spacing: PPSpacing.xxs) {
                    Text("Track with")
                        .font(.ppCaption)
                        .foregroundColor(.white.opacity(0.7))

                    Text("PoopyPals")
                        .font(.ppTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("💩 Available on App Store")
                        .font(.ppCaptionSmall)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(PPSpacing.xl)
        }
        .frame(width: 400, height: 600)  // Instagram/TikTok friendly dimensions
        .cornerRadius(PPCornerRadius.lg)
    }
}

// MARK: - Image Generation for Sharing

extension ShareableAchievementCard {
    /// Convert SwiftUI view to UIImage for sharing
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = CGSize(width: 400, height: 600)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

// MARK: - Preview

#Preview {
    ShareableAchievementCard(
        achievement: .sample,
        streakCount: 30
    )
}
