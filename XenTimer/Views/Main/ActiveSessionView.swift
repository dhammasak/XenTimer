import SwiftUI
import SwiftData

/// Shown inside MainWindowView while a focus / break / breathing session is running.
/// Commits the SwiftData record on natural finish or meaningful early stop, and
/// presents the rating sheet after a focus session completes.
struct ActiveSessionView: View {

    @Environment(TimerService.self) private var timer
    @Environment(BreathingController.self) private var breathing
    @Environment(AudioService.self) private var audio
    @Environment(NotificationService.self) private var notifications
    @Environment(FullScreenPresenter.self) private var presenter
    @Environment(\.modelContext) private var context
    @Environment(\.openWindow) private var openWindow

    @Query private var settingsRows: [AppSettings]
    @Query(sort: \BreathingPattern.sortOrder) private var patterns: [BreathingPattern]

    @State private var sessionToRate: FocusSession?
    @State private var showRatingSheet: Bool = false
    @State private var lastHandledFinishedTick: Int = 0

    /// Treat any session shorter than this as a no-op when user stops early.
    private let meaningfulSessionFloor: TimeInterval = 60

    private var tone: ModeBanner.Tone {
        timer.mode == .focus ? .focus : .breath
    }

    private var ringColor: Color {
        timer.mode == .focus ? Theme.Palette.focus : Theme.Palette.breath
    }

    private var bannerLabel: String {
        let mode = timer.mode.displayName
        if let label = timer.label, !label.isEmpty {
            return "\(mode) session — \(label)"
        }
        return "\(mode) session"
    }

    var body: some View {
        VStack(spacing: Theme.Space.s7) {

            ModeBanner(label: bannerLabel, tone: tone)

            // Big clock
            Text(TimeFormatting.clock(timer.remaining))
                .font(.system(size: 84, weight: .ultraLight, design: .default))
                .monospacedDigit()
                .foregroundStyle(Theme.Palette.ink)
                .padding(.top, Theme.Space.s5)

            // Progress + caption
            VStack(spacing: Theme.Space.s2) {
                ProgressView(value: timer.progress)
                    .progressViewStyle(.linear)
                    .tint(ringColor)
                    .frame(width: 320)
                Text(progressCaption)
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkMuted)
            }

            // Controls
            HStack(spacing: Theme.Space.s3) {
                Button {
                    timer.togglePause()
                } label: {
                    Label(timer.isPaused ? "Resume" : "Pause",
                          systemImage: timer.isPaused ? "play.fill" : "pause.fill")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(role: .destructive) {
                    handleEarlyStop()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                if timer.mode == .focus {
                    Button {
                        handleSkipToBreak()
                    } label: {
                        Label("Skip to break", systemImage: "forward.fill")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }

            // Sound caption
            if let sound = timer.backgroundSound, sound != "Silence" {
                HStack(spacing: Theme.Space.s2) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 11))
                    Text("\(sound) · \(Int(audio.volume * 100))%")
                        .font(Theme.Typography.small)
                }
                .foregroundStyle(Theme.Palette.inkSoft)
                .padding(.top, Theme.Space.s2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Theme.Space.s6)
        .onChange(of: timer.finishedTick) { _, newValue in
            guard newValue != lastHandledFinishedTick else { return }
            lastHandledFinishedTick = newValue
            handleNaturalFinish()
        }
        .sheet(isPresented: $showRatingSheet, onDismiss: {
            sessionToRate = nil
        }) {
            if let session = sessionToRate {
                FocusCompleteSheet(session: session) { startBreak in
                    if startBreak { startBreakAfterFocus() }
                }
            }
        }
    }

    private var progressCaption: String {
        let elapsed = TimeFormatting.humanDuration(timer.elapsed)
        if let endsAt = timer.endsAt, !timer.isPaused {
            return "\(elapsed) elapsed · ends \(TimeFormatting.wallClock(endsAt))"
        }
        return "\(elapsed) elapsed"
    }

    // MARK: - Finish handlers

    private func handleNaturalFinish() {
        switch timer.lastFinishedMode {
        case .focus:
            let session = commitFocus(completed: true)
            notifications.focusCompleted(label: session?.tag)
            audio.playCompletion()
            audio.fadeOutAmbient()
            sessionToRate = session
            showRatingSheet = session != nil
            timer.stop()

        case .break:
            _ = commitBreathing(type: .pomodoroBreak, completed: true)
            notifications.breakCompleted()
            audio.playCompletion()
            audio.fadeOutAmbient()
            breathing.stop()
            presenter.requestClose()
            timer.stop()

        case .breathing:
            _ = commitBreathing(type: .standalone, completed: true)
            notifications.breathingCompleted(patternName: timer.label ?? "")
            audio.playCompletion()
            audio.fadeOutAmbient()
            breathing.stop()
            presenter.requestClose()
            timer.stop()

        default:
            break
        }
    }

    private func handleEarlyStop() {
        let elapsed = timer.elapsed
        let meaningful = elapsed >= meaningfulSessionFloor

        if meaningful {
            switch timer.mode {
            case .focus:     _ = commitFocus(completed: false)
            case .break:     _ = commitBreathing(type: .pomodoroBreak, completed: false)
            case .breathing: _ = commitBreathing(type: .standalone, completed: false)
            default:         break
            }
        }

        audio.fadeOutAmbient()
        if timer.mode == .breathing || timer.mode == .break {
            breathing.stop()
            presenter.requestClose()
        }
        timer.stop()
    }

    private func handleSkipToBreak() {
        guard timer.mode == .focus else { return }
        let session = commitFocus(completed: true)
        audio.fadeOutAmbient()
        // Show rating, then on dismiss the user may or may not start break.
        sessionToRate = session
        showRatingSheet = session != nil
        timer.stop()
    }

    // MARK: - Commit helpers

    @discardableResult
    private func commitFocus(completed: Bool) -> FocusSession? {
        guard let startedAt = timer.startedAt else { return nil }
        let session = FocusSession(
            startTime: startedAt,
            endTime: .now,
            plannedDuration: timer.totalDuration,
            actualDuration: timer.elapsed,
            tag: timer.label,
            backgroundSound: timer.backgroundSound,
            completed: completed
        )
        context.insert(session)
        try? context.save()
        return session
    }

    @discardableResult
    private func commitBreathing(type: BreathingSessionType, completed: Bool) -> BreathingSession? {
        guard let startedAt = timer.startedAt else { return nil }
        let session = BreathingSession(
            startTime: startedAt,
            endTime: .now,
            plannedDuration: timer.totalDuration,
            actualDuration: timer.elapsed,
            ambientSound: timer.backgroundSound,
            sessionType: type,
            completed: completed,
            patternName: breathing.patternName.isEmpty ? (timer.label ?? "") : breathing.patternName,
            patternInhale: breathing.patternInhale,
            patternHoldAfterInhale: breathing.patternHoldAfterInhale,
            patternExhale: breathing.patternExhale,
            patternHoldAfterExhale: breathing.patternHoldAfterExhale
        )
        context.insert(session)
        try? context.save()
        return session
    }

    // MARK: - Break flow

    private func startBreakAfterFocus() {
        guard let settings = settingsRows.first else { return }
        let pattern = defaultBreakPattern(settings: settings)
        guard let pattern else { return }

        let breakDuration = settings.defaultBreakDuration
        timer.startBreak(duration: breakDuration, patternName: pattern.name, sound: settings.defaultBreakSound)
        breathing.start(pattern: pattern, duration: breakDuration, ambientSound: settings.defaultBreakSound)
        audio.playAmbient(settings.defaultBreakSound)
        notifications.breakStarted(patternName: pattern.name)
        presenter.requestOpen()
        openWindow(id: WindowID.fullScreenBreathing)
    }

    private func defaultBreakPattern(settings: AppSettings) -> BreathingPattern? {
        if let id = settings.defaultBreathingPatternID,
           let found = patterns.first(where: { $0.id == id }) {
            return found
        }
        return patterns.first
    }
}
