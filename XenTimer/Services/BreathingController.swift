import Foundation
import Observation

enum BreathingPhase: String, Equatable {
    case inhale
    case holdAfterInhale
    case exhale
    case holdAfterExhale

    var displayLabel: String {
        switch self {
        case .inhale:           "Breathe in"
        case .holdAfterInhale:  "Hold"
        case .exhale:           "Breathe out"
        case .holdAfterExhale:  "Rest"
        }
    }

    /// Whether the breathing circle is at its full size during this phase.
    var atFullSize: Bool {
        switch self {
        case .holdAfterInhale: true
        default:               false
        }
    }
}

@Observable
final class BreathingController {

    // MARK: - State

    private(set) var isActive: Bool = false
    private(set) var currentPhase: BreathingPhase = .inhale
    private(set) var phaseStartedAt: Date?
    private(set) var phaseDuration: TimeInterval = 0
    private(set) var cycleNumber: Int = 0
    private(set) var totalCycles: Int = 0

    private(set) var patternName: String = ""
    private(set) var patternInhale: Int = 0
    private(set) var patternHoldAfterInhale: Int = 0
    private(set) var patternExhale: Int = 0
    private(set) var patternHoldAfterExhale: Int = 0

    private(set) var totalDuration: TimeInterval = 0
    private(set) var startedAt: Date?
    private(set) var endsAt: Date?

    private(set) var ambientSound: String?

    /// Bumped each time a phase begins — views can react to play guide sounds.
    private(set) var phaseTick: Int = 0

    // MARK: - Derived

    var remaining: TimeInterval {
        guard let endsAt else { return 0 }
        return max(0, endsAt.timeIntervalSinceNow)
    }

    /// 0…1 progress within the current phase.
    var phaseProgress: Double {
        guard phaseDuration > 0, let phaseStartedAt else { return 0 }
        let elapsed = Date().timeIntervalSince(phaseStartedAt)
        return min(1, max(0, elapsed / phaseDuration))
    }

    var targetScale: Double {
        switch currentPhase {
        case .inhale:           1.0
        case .holdAfterInhale:  1.0
        case .exhale:           0.55
        case .holdAfterExhale:  0.55
        }
    }

    var cycleLength: Int {
        patternInhale + patternHoldAfterInhale + patternExhale + patternHoldAfterExhale
    }

    var patternDescription: String {
        "\(patternInhale) · \(patternHoldAfterInhale) · \(patternExhale) · \(patternHoldAfterExhale)"
    }

    // MARK: - Private

    private var phaseTimer: Timer?
    private var endTimer: Timer?

    // MARK: - Start / Stop

    func start(pattern: BreathingPattern, duration: TimeInterval, ambientSound: String? = nil) {
        stop()

        guard pattern.cycleLength > 0 else { return }

        self.patternName = pattern.name
        self.patternInhale = pattern.inhale
        self.patternHoldAfterInhale = pattern.holdAfterInhale
        self.patternExhale = pattern.exhale
        self.patternHoldAfterExhale = pattern.holdAfterExhale

        self.totalDuration = max(1, duration)
        self.startedAt = .now
        self.endsAt = Date().addingTimeInterval(self.totalDuration)
        self.totalCycles = Int(self.totalDuration) / pattern.cycleLength
        self.cycleNumber = 1
        self.ambientSound = ambientSound
        self.isActive = true

        startPhase(.inhale)
        scheduleEndTimer()
    }

    func stop() {
        phaseTimer?.invalidate()
        endTimer?.invalidate()
        phaseTimer = nil
        endTimer = nil
        isActive = false
        currentPhase = .inhale
        phaseStartedAt = nil
        phaseDuration = 0
        cycleNumber = 0
        totalCycles = 0
        patternName = ""
        patternInhale = 0
        patternHoldAfterInhale = 0
        patternExhale = 0
        patternHoldAfterExhale = 0
        totalDuration = 0
        startedAt = nil
        endsAt = nil
        ambientSound = nil
    }

    // MARK: - Phase progression

    private func startPhase(_ phase: BreathingPhase) {
        currentPhase = phase
        let d = TimeInterval(seconds(for: phase))
        phaseDuration = d
        phaseStartedAt = .now
        phaseTick &+= 1

        phaseTimer?.invalidate()
        guard d > 0 else {
            // Skip zero-length phases on next runloop to avoid deep recursion.
            DispatchQueue.main.async { [weak self] in self?.advancePhase() }
            return
        }
        let t = Timer(timeInterval: d, repeats: false) { [weak self] _ in
            self?.advancePhase()
        }
        phaseTimer = t
        RunLoop.main.add(t, forMode: .common)
    }

    private func seconds(for phase: BreathingPhase) -> Int {
        switch phase {
        case .inhale:           patternInhale
        case .holdAfterInhale:  patternHoldAfterInhale
        case .exhale:           patternExhale
        case .holdAfterExhale:  patternHoldAfterExhale
        }
    }

    private func advancePhase() {
        guard isActive else { return }
        switch currentPhase {
        case .inhale:          startPhase(.holdAfterInhale)
        case .holdAfterInhale: startPhase(.exhale)
        case .exhale:          startPhase(.holdAfterExhale)
        case .holdAfterExhale:
            cycleNumber += 1
            startPhase(.inhale)
        }
    }

    private func scheduleEndTimer() {
        guard let endsAt else { return }
        let delay = max(0, endsAt.timeIntervalSinceNow)
        let t = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
            self?.stop()
        }
        endTimer = t
        RunLoop.main.add(t, forMode: .common)
    }
}
