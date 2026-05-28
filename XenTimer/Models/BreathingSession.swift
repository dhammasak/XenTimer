import Foundation
import SwiftData

enum BreathingSessionType: String, Codable, CaseIterable {
    case standalone
    case pomodoroBreak

    var displayName: String {
        switch self {
        case .standalone:    "Standalone"
        case .pomodoroBreak: "Pomodoro break"
        }
    }
}

@Model
final class BreathingSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date
    var plannedDuration: TimeInterval
    var actualDuration: TimeInterval
    var ambientSound: String?
    var reflectionNote: String?
    var sessionTypeRaw: String
    var completed: Bool

    // Snapshot of the pattern at session time (so editing a pattern later doesn't rewrite history).
    var patternName: String
    var patternInhale: Int
    var patternHoldAfterInhale: Int
    var patternExhale: Int
    var patternHoldAfterExhale: Int

    init(
        id: UUID = UUID(),
        startTime: Date = .now,
        endTime: Date = .now,
        plannedDuration: TimeInterval,
        actualDuration: TimeInterval = 0,
        ambientSound: String? = nil,
        reflectionNote: String? = nil,
        sessionType: BreathingSessionType = .standalone,
        completed: Bool = false,
        patternName: String,
        patternInhale: Int,
        patternHoldAfterInhale: Int,
        patternExhale: Int,
        patternHoldAfterExhale: Int
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.ambientSound = ambientSound
        self.reflectionNote = reflectionNote
        self.sessionTypeRaw = sessionType.rawValue
        self.completed = completed
        self.patternName = patternName
        self.patternInhale = patternInhale
        self.patternHoldAfterInhale = patternHoldAfterInhale
        self.patternExhale = patternExhale
        self.patternHoldAfterExhale = patternHoldAfterExhale
    }

    var sessionType: BreathingSessionType {
        get { BreathingSessionType(rawValue: sessionTypeRaw) ?? .standalone }
        set { sessionTypeRaw = newValue.rawValue }
    }

    var patternDescription: String {
        "\(patternInhale) · \(patternHoldAfterInhale) · \(patternExhale) · \(patternHoldAfterExhale)"
    }
}
