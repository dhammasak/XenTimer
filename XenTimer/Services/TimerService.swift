import Foundation
import Observation

enum TimerMode: String, Equatable {
    case idle
    case focus
    case `break`
    case breathing

    var displayName: String {
        switch self {
        case .idle:      "Idle"
        case .focus:     "Focus"
        case .break:     "Break"
        case .breathing: "Breathing"
        }
    }
}

enum TimerState: String, Equatable {
    case idle
    case running
    case paused
    case finished
}

@Observable
final class TimerService {

    // MARK: - Public state

    private(set) var mode: TimerMode = .idle
    private(set) var state: TimerState = .idle

    private(set) var totalDuration: TimeInterval = 0
    private(set) var remaining: TimeInterval = 0

    private(set) var startedAt: Date?
    private(set) var endsAt: Date?

    /// Tag for focus, or pattern name for breathing/break.
    var label: String?
    var backgroundSound: String?

    /// Notifies observers when a focus session finishes naturally (not stopped).
    /// Views read this with `.onChange(of: timerService.finishedTick)` and respond
    /// (e.g. show rating sheet, start break).
    private(set) var finishedTick: Int = 0
    private(set) var lastFinishedMode: TimerMode = .idle

    // MARK: - Derived

    var elapsed: TimeInterval { max(0, totalDuration - remaining) }

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return min(1, max(0, elapsed / totalDuration))
    }

    var isRunning: Bool { state == .running }
    var isPaused: Bool  { state == .paused }
    var isActive: Bool  { state == .running || state == .paused }

    // MARK: - Private

    private var ticker: Timer?

    // MARK: - Start

    func startFocus(duration: TimeInterval, tag: String?, sound: String?) {
        beginSession(mode: .focus, duration: duration, label: tag, sound: sound)
    }

    func startBreak(duration: TimeInterval, patternName: String?, sound: String?) {
        beginSession(mode: .break, duration: duration, label: patternName, sound: sound)
    }

    func startStandaloneBreathing(duration: TimeInterval, patternName: String?, sound: String?) {
        beginSession(mode: .breathing, duration: duration, label: patternName, sound: sound)
    }

    private func beginSession(mode: TimerMode, duration: TimeInterval, label: String?, sound: String?) {
        stopTicker()
        self.mode = mode
        self.totalDuration = max(1, duration)
        self.remaining = self.totalDuration
        self.startedAt = .now
        self.endsAt = Date().addingTimeInterval(self.totalDuration)
        self.label = label
        self.backgroundSound = sound
        self.state = .running
        startTicker()
    }

    // MARK: - Control

    func togglePause() {
        switch state {
        case .running: pause()
        case .paused:  resume()
        default:       break
        }
    }

    func pause() {
        guard state == .running else { return }
        // Freeze remaining at current value, drop endsAt.
        state = .paused
        endsAt = nil
        stopTicker()
    }

    func resume() {
        guard state == .paused else { return }
        endsAt = Date().addingTimeInterval(remaining)
        state = .running
        startTicker()
    }

    /// User cancels the session early.
    func stop() {
        stopTicker()
        resetState()
    }

    /// Skip the current session to next phase. Caller handles "what next".
    func skip() {
        stopTicker()
        remaining = 0
        state = .finished
        lastFinishedMode = mode
        finishedTick &+= 1
        resetState()
    }

    private func resetState() {
        state = .idle
        mode = .idle
        totalDuration = 0
        remaining = 0
        startedAt = nil
        endsAt = nil
        label = nil
        backgroundSound = nil
    }

    // MARK: - Ticker

    private func startTicker() {
        stopTicker()
        let t = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        ticker = t
        RunLoop.main.add(t, forMode: .common)
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }

    private func tick() {
        guard state == .running, let endsAt else { return }
        let rem = max(0, endsAt.timeIntervalSinceNow)
        remaining = rem
        if rem <= 0.05 {
            finishNaturally()
        }
    }

    private func finishNaturally() {
        stopTicker()
        let finishedMode = mode
        remaining = 0
        state = .finished
        lastFinishedMode = finishedMode
        finishedTick &+= 1
        // Hold the session details until the view layer commits them; caller
        // will call `stop()` after writing to SwiftData.
    }
}
