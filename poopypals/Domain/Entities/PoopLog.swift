//
//  PoopLog.swift
//  PoopyPals
//
//  Domain Entity - Core business model
//

import Foundation
import SwiftUI

struct PoopLog: Identifiable, Codable {
    let id: UUID
    let loggedAt: Date
    let durationSeconds: Int
    let rating: Rating
    let consistency: Int  // Bristol Scale 1-7
    let notes: String?
    let flushFundsEarned: Int
    let localId: String?

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        loggedAt: Date = Date(),
        durationSeconds: Int,
        rating: Rating,
        consistency: Int,
        notes: String? = nil,
        flushFundsEarned: Int = 10,
        localId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.loggedAt = loggedAt
        self.durationSeconds = durationSeconds
        self.rating = rating
        self.consistency = consistency
        self.notes = notes
        self.flushFundsEarned = flushFundsEarned
        self.localId = localId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties

    var durationMinutes: Int {
        return durationSeconds / 60
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: loggedAt)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: loggedAt)
    }

    // MARK: - Rating Enum

    enum Rating: String, Codable, CaseIterable {
        case great
        case good
        case okay
        case bad
        case terrible

        var emoji: String {
            switch self {
            case .great: return "😄"
            case .good: return "🙂"
            case .okay: return "😐"
            case .bad: return "☹️"
            case .terrible: return "😫"
            }
        }

        var color: Color {
            switch self {
            case .great: return .ppRatingGreat
            case .good: return .ppRatingGood
            case .okay: return .ppRatingOkay
            case .bad: return .ppRatingBad
            case .terrible: return .ppRatingTerrible
            }
        }

        var displayName: String {
            return rawValue.capitalized
        }
    }
}

// MARK: - Consistency Helpers

extension PoopLog {
    var consistencyDescription: String {
        switch consistency {
        case 1: return "Separate hard lumps"
        case 2: return "Lumpy and sausage-like"
        case 3: return "Sausage with cracks"
        case 4: return "Smooth sausage (ideal)"
        case 5: return "Soft blobs"
        case 6: return "Mushy"
        case 7: return "Liquid"
        default: return "Unknown"
        }
    }

    var isIdealConsistency: Bool {
        return consistency == 3 || consistency == 4
    }
}

// MARK: - Sample Data (for previews)

extension PoopLog {
    static let sample = PoopLog(
        durationSeconds: 180,
        rating: .great,
        consistency: 4,
        notes: "Morning coffee works every time! ☕️"
    )

    static let samples: [PoopLog] = [
        PoopLog(durationSeconds: 120, rating: .great, consistency: 4, notes: "Perfect start to the day"),
        PoopLog(durationSeconds: 240, rating: .good, consistency: 3, notes: nil),
        PoopLog(durationSeconds: 180, rating: .okay, consistency: 5, notes: "Too much coffee"),
        PoopLog(durationSeconds: 300, rating: .bad, consistency: 6, notes: "Not feeling great"),
    ]
}
