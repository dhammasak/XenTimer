import Foundation
import SwiftData

@Model
final class FocusSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date
    var plannedDuration: TimeInterval
    var actualDuration: TimeInterval
    var tag: String?
    var backgroundSound: String?
    var rating: Int?
    var note: String?
    var completed: Bool
    /// Optional ID of the breathing break that followed this session.
    var followedByBreathingSessionID: UUID?

    init(
        id: UUID = UUID(),
        startTime: Date = .now,
        endTime: Date = .now,
        plannedDuration: TimeInterval,
        actualDuration: TimeInterval = 0,
        tag: String? = nil,
        backgroundSound: String? = nil,
        rating: Int? = nil,
        note: String? = nil,
        completed: Bool = false,
        followedByBreathingSessionID: UUID? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.tag = tag
        self.backgroundSound = backgroundSound
        self.rating = rating
        self.note = note
        self.completed = completed
        self.followedByBreathingSessionID = followedByBreathingSessionID
    }
}
