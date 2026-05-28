import Foundation
import SwiftData

/// Pure aggregation helpers — no SwiftUI, no IO. Used by Dashboard and Exporter.
enum DailyAggregator {

    struct DailyStats {
        var date: Date
        var focusSessions: [FocusSession]
        var breathingSessions: [BreathingSession]

        var focusCompleted: Int { focusSessions.filter(\.completed).count }
        var totalFocusTime: TimeInterval { focusSessions.reduce(0) { $0 + $1.actualDuration } }
        var standaloneBreathingCount: Int {
            breathingSessions.filter { $0.sessionType == .standalone }.count
        }
        var breakBreathingCount: Int {
            breathingSessions.filter { $0.sessionType == .pomodoroBreak }.count
        }
        var totalBreathingTime: TimeInterval { breathingSessions.reduce(0) { $0 + $1.actualDuration } }
        var totalBreakTime: TimeInterval {
            breathingSessions
                .filter { $0.sessionType == .pomodoroBreak }
                .reduce(0) { $0 + $1.actualDuration }
        }

        var averageRating: Double? {
            let ratings = focusSessions.compactMap(\.rating)
            guard !ratings.isEmpty else { return nil }
            return Double(ratings.reduce(0, +)) / Double(ratings.count)
        }

        var mostUsedTag: String? {
            let tags = focusSessions.compactMap(\.tag).filter { !$0.isEmpty }
            return Self.mostFrequent(tags)
        }

        var mostUsedBreathingPattern: String? {
            let names = breathingSessions.map(\.patternName).filter { !$0.isEmpty }
            return Self.mostFrequent(names)
        }

        private static func mostFrequent<T: Hashable>(_ items: [T]) -> T? {
            var counts: [T: Int] = [:]
            for item in items { counts[item, default: 0] += 1 }
            return counts.max(by: { $0.value < $1.value })?.key
        }
    }

    static func stats(for day: Date, context: ModelContext) throws -> DailyStats {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: day)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
            return DailyStats(date: day, focusSessions: [], breathingSessions: [])
        }

        let focusPredicate = #Predicate<FocusSession> {
            $0.startTime >= start && $0.startTime < end
        }
        let breathingPredicate = #Predicate<BreathingSession> {
            $0.startTime >= start && $0.startTime < end
        }

        let focusDesc = FetchDescriptor<FocusSession>(
            predicate: focusPredicate,
            sortBy: [SortDescriptor(\.startTime)]
        )
        let breathingDesc = FetchDescriptor<BreathingSession>(
            predicate: breathingPredicate,
            sortBy: [SortDescriptor(\.startTime)]
        )

        let focus = try context.fetch(focusDesc)
        let breathing = try context.fetch(breathingDesc)

        return DailyStats(date: day, focusSessions: focus, breathingSessions: breathing)
    }
}
