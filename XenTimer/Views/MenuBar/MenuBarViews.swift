import SwiftUI
import SwiftData

// MARK: - Label (what appears in the menu bar itself)

struct MenuBarLabelView: View {
    @Environment(TimerService.self) private var timer
    @Environment(BreathingController.self) private var breathing

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: iconName)
                .font(.system(size: 12, weight: .regular))
            if !labelText.isEmpty {
                Text(labelText)
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
            }
        }
    }

    private var iconName: String {
        switch timer.mode {
        case .focus:     "circle.fill"
        case .break:     "leaf.fill"
        case .breathing: "wind"
        case .idle:      "moon.zzz"
        }
    }

    private var labelText: String {
        switch timer.mode {
        case .focus:     "Focus \(TimeFormatting.clock(timer.remaining))"
        case .break:     "Break \(TimeFormatting.clock(timer.remaining))"
        case .breathing: "Breathing \(TimeFormatting.clock(timer.remaining))"
        case .idle:      ""
        }
    }
}

// MARK: - Dropdown content

struct MenuBarContentView: View {
    @Environment(TimerService.self) private var timer
    @Environment(BreathingController.self) private var breathing
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var context

    @Query(sort: \FocusSession.startTime, order: .reverse) private var allFocus: [FocusSession]
    @Query(sort: \BreathingSession.startTime, order: .reverse) private var allBreathing: [BreathingSession]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if timer.isActive {
                activeSection
            } else {
                idleSection
            }

            Divider().padding(.vertical, Theme.Space.s2)

            sectionLabel("Today")
            todayStats
                .padding(.bottom, Theme.Space.s2)

            Divider().padding(.vertical, Theme.Space.s2)

            menuItem(icon: "macwindow", title: "Open XenTimer", shortcut: "⌘O") {
                openWindow(id: WindowID.main)
                NSApp.activate(ignoringOtherApps: true)
            }
            menuItem(icon: "power", title: "Quit XenTimer", shortcut: "⌘Q", destructive: true) {
                NSApp.terminate(nil)
            }
        }
        .padding(Theme.Space.s3)
        .frame(width: 280)
    }

    // MARK: - Active section

    private var activeSection: some View {
        VStack(alignment: .leading, spacing: Theme.Space.s2) {
            HStack(spacing: 6) {
                Circle()
                    .fill(modeColor)
                    .frame(width: 6, height: 6)
                Text(activeEyebrow.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(Theme.Palette.inkMuted)
            }
            Text(TimeFormatting.clock(timer.remaining))
                .font(.system(size: 28, weight: .light, design: .default))
                .monospacedDigit()
                .foregroundStyle(Theme.Palette.ink)

            if let endsAt = timer.endsAt {
                Text("\(TimeFormatting.humanDuration(timer.elapsed)) elapsed · ends \(TimeFormatting.wallClock(endsAt))")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.Palette.inkMuted)
            } else if timer.isPaused {
                Text("Paused")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.Palette.warn)
            }

            ProgressView(value: timer.progress)
                .progressViewStyle(.linear)
                .tint(modeColor)
                .padding(.top, 2)

            HStack(spacing: 6) {
                Button {
                    timer.togglePause()
                } label: {
                    Label(timer.isPaused ? "Resume" : "Pause",
                          systemImage: timer.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Theme.Palette.surface2)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                Button {
                    timer.stop()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Theme.Palette.surface2)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
    }

    private var activeEyebrow: String {
        var parts = [timer.mode.displayName]
        if let label = timer.label, !label.isEmpty { parts.append(label) }
        return parts.joined(separator: " · ")
    }

    private var modeColor: Color {
        switch timer.mode {
        case .focus:     Theme.Palette.focus
        case .break:     Theme.Palette.warn
        case .breathing: Theme.Palette.breath
        case .idle:      Theme.Palette.inkSoft
        }
    }

    // MARK: - Idle section

    private var idleSection: some View {
        VStack(alignment: .leading, spacing: Theme.Space.s2) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Theme.Palette.inkSoft)
                    .frame(width: 6, height: 6)
                Text("IDLE")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(Theme.Palette.inkMuted)
            }
            Text("XenTimer")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.Palette.ink)
            Text("Open the main window to start a session.")
                .font(.system(size: 11))
                .foregroundStyle(Theme.Palette.inkMuted)
        }
    }

    // MARK: - Today

    private var todayStats: some View {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        let focusToday = allFocus.filter { $0.startTime >= start && $0.completed }
        let breathToday = allBreathing.filter { $0.startTime >= start && $0.completed }
        let totalFocus = focusToday.reduce(0) { $0 + $1.actualDuration }

        return HStack {
            Text("\(focusToday.count) focus · \(breathToday.count) breathing")
                .font(.system(size: 12))
                .foregroundStyle(Theme.Palette.ink)
            Spacer()
            Text(TimeFormatting.humanDuration(totalFocus))
                .font(.system(size: 12))
                .foregroundStyle(Theme.Palette.inkMuted)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .medium))
            .tracking(0.5)
            .foregroundStyle(Theme.Palette.inkSoft)
            .padding(.horizontal, 4).padding(.bottom, 4)
    }

    private func menuItem(icon: String, title: String, shortcut: String? = nil, destructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.Space.s2) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .frame(width: 16)
                Text(title)
                    .font(.system(size: 13))
                Spacer()
                if let shortcut {
                    Text(shortcut)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.Palette.inkSoft)
                }
            }
            .padding(.horizontal, 8).padding(.vertical, 6)
            .foregroundStyle(destructive ? Color.red : Theme.Palette.ink)
            .background(Color.clear)
        }
        .buttonStyle(.plain)
    }
}
