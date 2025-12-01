//
//  SkeletonView.swift
//  PoopyPals
//
//  Skeleton Loading Components - Shimmer Effect
//

import SwiftUI

// MARK: - Base Skeleton View

struct SkeletonView: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat
    
    @State private var phase: CGFloat = 0
    
    init(
        width: CGFloat? = nil,
        height: CGFloat = 20,
        cornerRadius: CGFloat = PPCornerRadius.sm
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.ppSurfaceAlt)
            .frame(width: width, height: height)
            .shimmer(isActive: true)
    }
}

// MARK: - Skeleton Card

struct SkeletonCard: View {
    var body: some View {
        GlossyCard(gradient: PPGradients.surfaceSubtle, shadowIntensity: 0.2) {
            VStack(alignment: .leading, spacing: PPSpacing.md) {
                SkeletonView(width: 60, height: 60, cornerRadius: PPCornerRadius.full)
                
                SkeletonView(width: nil, height: 16)
                SkeletonView(width: 120, height: 12)
            }
            .padding(PPSpacing.md)
        }
        .frame(height: 140)
    }
}

// MARK: - Skeleton Stat Card

struct SkeletonStatCard: View {
    var body: some View {
        GlossyCard(gradient: PPGradients.surfaceSubtle, shadowIntensity: 0.2) {
            VStack(spacing: PPSpacing.sm) {
                SkeletonView(width: 40, height: 40, cornerRadius: PPCornerRadius.full)
                SkeletonView(width: 60, height: 24)
                SkeletonView(width: 80, height: 12)
            }
            .padding(PPSpacing.md)
        }
        .frame(height: 140)
    }
}

// MARK: - Skeleton Log Row

struct SkeletonLogRow: View {
    var body: some View {
        GlossyCard(gradient: PPGradients.surfaceSubtle, shadowIntensity: 0.2) {
            HStack(spacing: PPSpacing.md) {
                SkeletonView(width: 50, height: 50, cornerRadius: PPCornerRadius.full)
                
                VStack(alignment: .leading, spacing: PPSpacing.xs) {
                    SkeletonView(width: 100, height: 16)
                    SkeletonView(width: 150, height: 12)
                }
                
                Spacer()
                
                SkeletonView(width: 50, height: 20)
            }
            .padding(PPSpacing.md)
        }
    }
}

// MARK: - Skeleton Leaderboard Row

struct SkeletonLeaderboardRow: View {
    var body: some View {
        HStack(spacing: PPSpacing.md) {
            SkeletonView(width: 30, height: 20)
            SkeletonView(width: 50, height: 50, cornerRadius: PPCornerRadius.full)
            VStack(alignment: .leading, spacing: PPSpacing.xs) {
                SkeletonView(width: 120, height: 16)
                SkeletonView(width: 80, height: 12)
            }
            Spacer()
            SkeletonView(width: 60, height: 20)
        }
        .padding(PPSpacing.md)
        .background(
            GlossyCard(gradient: PPGradients.surfaceSubtle, shadowIntensity: 0.1) {
                EmptyView()
            }
        )
        .cornerRadius(PPCornerRadius.md)
    }
}

// MARK: - Skeleton Podium Card

struct SkeletonPodiumCard: View {
    var body: some View {
        VStack(spacing: PPSpacing.sm) {
            SkeletonView(width: 80, height: 80, cornerRadius: PPCornerRadius.full)
            SkeletonView(width: 100, height: 16)
            SkeletonView(width: 60, height: 20)
            SkeletonView(width: 80, height: 12)
        }
        .padding(PPSpacing.md)
        .background(
            GlossyCard(gradient: PPGradients.surfaceSubtle, shadowIntensity: 0.2) {
                EmptyView()
            }
        )
        .cornerRadius(PPCornerRadius.md)
    }
}

// MARK: - Skeleton Profile Header

struct SkeletonProfileHeader: View {
    var body: some View {
        VStack(spacing: PPSpacing.md) {
            SkeletonView(width: 100, height: 100, cornerRadius: PPCornerRadius.full)
            SkeletonView(width: 200, height: 20)
            SkeletonView(width: 150, height: 14)
        }
        .frame(maxWidth: .infinity)
        .padding(PPSpacing.xl)
        .background(
            GlossyCard(gradient: PPGradients.surfaceSubtle, shadowIntensity: 0.2) {
                EmptyView()
            }
        )
        .cornerRadius(PPCornerRadius.md)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: PPSpacing.lg) {
        SkeletonStatCard()
        SkeletonLogRow()
        SkeletonLeaderboardRow()
        SkeletonPodiumCard()
    }
    .padding()
    .background(LinearGradient.ppGradient(PPGradients.lavenderPeach))
}

