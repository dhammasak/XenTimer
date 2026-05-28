import Foundation
import SwiftData

enum SeedData {

    static let defaultPatterns: [(name: String, inhale: Int, holdIn: Int, exhale: Int, holdOut: Int, purpose: String)] = [
        ("Box Breathing",     4, 4, 4, 4, "Calm & focus"),
        ("Relax Breathing",   4, 0, 6, 0, "Wind down"),
        ("4-7-8 Breathing",   4, 7, 8, 0, "Stress relief"),
        ("Coherent Breathing", 5, 0, 5, 0, "Balanced rhythm")
    ]

    static let focusTags: [String] = [
        "Writing", "Reading", "Strategy", "Study",
        "Planning", "Deep Work", "Admin", "Meeting Prep"
    ]

    static let focusSounds: [String] = [
        "Silence", "Rain", "Forest", "Ocean", "Stream",
        "White noise", "Brown noise", "Pink noise", "Lo-fi"
    ]

    static let breathingSounds: [String] = [
        "Silence", "Ocean", "Soft rain", "Meditation bell", "Breath ambient"
    ]

    /// Ensures default breathing patterns and an AppSettings row exist.
    static func ensureSeeded(in context: ModelContext) {
        seedPatternsIfNeeded(in: context)
        seedSettingsIfNeeded(in: context)
    }

    private static func seedPatternsIfNeeded(in context: ModelContext) {
        let descriptor = FetchDescriptor<BreathingPattern>(predicate: #Predicate { !$0.isCustom })
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        for (i, p) in defaultPatterns.enumerated() {
            let pattern = BreathingPattern(
                name: p.name,
                inhale: p.inhale,
                holdAfterInhale: p.holdIn,
                exhale: p.exhale,
                holdAfterExhale: p.holdOut,
                purpose: p.purpose,
                isCustom: false,
                sortOrder: i
            )
            context.insert(pattern)
        }
        try? context.save()
    }

    private static func seedSettingsIfNeeded(in context: ModelContext) {
        let descriptor = FetchDescriptor<AppSettings>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let patterns = (try? context.fetch(FetchDescriptor<BreathingPattern>())) ?? []
        let box = patterns.first(where: { $0.name == "Box Breathing" })

        let settings = AppSettings(defaultBreathingPatternID: box?.id)
        context.insert(settings)
        try? context.save()
    }
}
