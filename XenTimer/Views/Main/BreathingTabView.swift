import SwiftUI
import SwiftData

struct BreathingTabView: View {

    @Environment(TimerService.self) private var timer
    @Environment(BreathingController.self) private var breathing
    @Environment(AudioService.self) private var audio
    @Environment(FullScreenPresenter.self) private var presenter
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var context

    @Query(sort: \BreathingPattern.sortOrder) private var patterns: [BreathingPattern]
    @Query private var settingsRows: [AppSettings]

    @State private var selectedPatternID: UUID?
    @State private var customInhale: Int = 4
    @State private var customHoldIn: Int = 4
    @State private var customExhale: Int = 4
    @State private var customHoldOut: Int = 4
    @State private var useCustom: Bool = false

    @State private var durationMinutes: Int = 10
    @State private var ambientSound: String = "Silence"
    @State private var guideMode: BreathingGuideMode = .bell

    private let durationOptions: [(label: String, minutes: Int)] = [
        ("3 min · Quick reset", 3),
        ("5 min · Standard", 5),
        ("10 min · Long", 10),
        ("15 min · Meditation", 15),
        ("20 min · Deep relaxation", 20)
    ]

    private var settings: AppSettings? { settingsRows.first }

    private var selectedPattern: BreathingPattern? {
        patterns.first(where: { $0.id == selectedPatternID })
    }

    private var effectivePattern: BreathingPattern? {
        if useCustom {
            return BreathingPattern(
                name: "Custom",
                inhale: customInhale,
                holdAfterInhale: customHoldIn,
                exhale: customExhale,
                holdAfterExhale: customHoldOut,
                purpose: "User-defined",
                isCustom: true
            )
        }
        return selectedPattern ?? patterns.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Space.s5) {

                // Quick-start preset grid
                VStack(alignment: .leading, spacing: Theme.Space.s3) {
                    HStack {
                        FieldLabel(text: "Quick start")
                        Spacer()
                        Text("Pick a pattern")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.Palette.inkSoft)
                    }
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: Theme.Space.s2), count: 2),
                        spacing: Theme.Space.s2
                    ) {
                        ForEach(patterns) { pattern in
                            PatternCard(
                                pattern: pattern,
                                isActive: !useCustom && selectedPatternID == pattern.id,
                                action: {
                                    useCustom = false
                                    selectedPatternID = pattern.id
                                }
                            )
                        }
                    }
                }

                // Custom pattern card
                CardContainer(inset: true) {
                    VStack(alignment: .leading, spacing: Theme.Space.s4) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Custom pattern")
                                    .font(Theme.Typography.h3)
                                    .foregroundStyle(Theme.Palette.ink)
                                Text("Tune the rhythm to your preference")
                                    .font(Theme.Typography.small)
                                    .foregroundStyle(Theme.Palette.inkMuted)
                            }
                            Spacer()
                            Toggle("Use custom", isOn: $useCustom)
                                .toggleStyle(.switch)
                                .controlSize(.small)
                                .labelsHidden()
                                .tint(Theme.Palette.breath)
                        }
                        HStack(spacing: Theme.Space.s3) {
                            CustomStepperField(label: "Inhale", value: $customInhale, range: 1...20)
                            CustomStepperField(label: "Hold", value: $customHoldIn, range: 0...20)
                            CustomStepperField(label: "Exhale", value: $customExhale, range: 1...20)
                            CustomStepperField(label: "Rest", value: $customHoldOut, range: 0...20)
                        }
                        .disabled(!useCustom)
                        .opacity(useCustom ? 1 : 0.55)
                    }
                }

                // Length / sound / guide
                HStack(spacing: Theme.Space.s4) {
                    VStack(alignment: .leading, spacing: Theme.Space.s2) {
                        FieldLabel(text: "Session length")
                        Picker("", selection: $durationMinutes) {
                            ForEach(durationOptions, id: \.minutes) { opt in
                                Text(opt.label).tag(opt.minutes)
                            }
                        }
                        .labelsHidden()
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: Theme.Space.s2) {
                        FieldLabel(text: "Ambient sound")
                        Picker("", selection: $ambientSound) {
                            ForEach(SeedData.breathingSounds, id: \.self) { Text($0).tag($0) }
                        }
                        .labelsHidden()
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: Theme.Space.s2) {
                        FieldLabel(text: "Guide")
                        Picker("", selection: $guideMode) {
                            ForEach(BreathingGuideMode.allCases) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .labelsHidden()
                    }
                    .frame(maxWidth: .infinity)
                }

                Spacer(minLength: Theme.Space.s4)

                HStack {
                    Spacer()
                    PrimaryActionButton(
                        label: "Begin breathing · \(durationMinutes) min",
                        icon: "play.fill",
                        tone: .breath,
                        action: startBreathing
                    )
                    Spacer()
                }
            }
        }
        .onAppear { syncFromSettings() }
    }

    private func syncFromSettings() {
        guard let settings else { return }
        if selectedPatternID == nil {
            selectedPatternID = settings.defaultBreathingPatternID ?? patterns.first?.id
        }
        if durationMinutes == 10 {
            let m = max(3, Int(settings.defaultStandaloneBreathingDuration / 60))
            if durationOptions.map(\.minutes).contains(m) {
                durationMinutes = m
            }
        }
        guideMode = settings.defaultBreathingGuide
    }

    private func startBreathing() {
        guard let pattern = effectivePattern, pattern.cycleLength > 0 else { return }
        let duration = TimeInterval(durationMinutes * 60)
        timer.startStandaloneBreathing(duration: duration, patternName: pattern.name, sound: ambientSound)
        breathing.start(pattern: pattern, duration: duration, ambientSound: ambientSound)
        audio.playAmbient(ambientSound)
        presenter.requestOpen()
        openWindow(id: WindowID.fullScreenBreathing)
    }
}

// MARK: - Pattern card

private struct PatternCard: View {
    let pattern: BreathingPattern
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Space.s3) {
                ZStack {
                    Circle()
                        .fill(isActive ? Theme.Palette.breath : Theme.Palette.breathBg)
                        .frame(width: 36, height: 36)
                    Image(systemName: iconName)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(isActive ? .white : Theme.Palette.breath)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(pattern.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.Palette.ink)
                    Text("\(pattern.compactDescription) — \(pattern.purpose)")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.Palette.inkMuted)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(Theme.Space.s4)
            .background(isActive ? Theme.Palette.breathBg : Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .strokeBorder(isActive ? Theme.Palette.breath : Theme.Palette.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var iconName: String {
        switch pattern.name {
        case "Box Breathing":      "circle"
        case "Relax Breathing":    "waveform.path"
        case "4-7-8 Breathing":    "plus.circle"
        case "Coherent Breathing": "circle.dotted"
        default:                   "wind"
        }
    }
}

// MARK: - Stepper field

private struct CustomStepperField: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.Palette.inkMuted)
            HStack(spacing: 4) {
                Stepper(value: $value, in: range) {
                    Text("\(value)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.Palette.ink)
                        .frame(minWidth: 24, alignment: .trailing)
                        .monospacedDigit()
                }
                .labelsHidden()
                Text("\(value)s")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.Palette.ink)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
