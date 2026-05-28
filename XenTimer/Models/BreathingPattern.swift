import Foundation
import SwiftData

@Model
final class BreathingPattern {
    @Attribute(.unique) var id: UUID
    var name: String
    var inhale: Int
    var holdAfterInhale: Int
    var exhale: Int
    var holdAfterExhale: Int
    var purpose: String
    var isCustom: Bool
    var sortOrder: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        inhale: Int,
        holdAfterInhale: Int,
        exhale: Int,
        holdAfterExhale: Int,
        purpose: String = "",
        isCustom: Bool = false,
        sortOrder: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.inhale = inhale
        self.holdAfterInhale = holdAfterInhale
        self.exhale = exhale
        self.holdAfterExhale = holdAfterExhale
        self.purpose = purpose
        self.isCustom = isCustom
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }

    /// Total seconds for one breathing cycle.
    var cycleLength: Int {
        inhale + holdAfterInhale + exhale + holdAfterExhale
    }

    /// Concise pattern string e.g. "4 · 4 · 4 · 4".
    var compactDescription: String {
        "\(inhale) · \(holdAfterInhale) · \(exhale) · \(holdAfterExhale)"
    }
}
