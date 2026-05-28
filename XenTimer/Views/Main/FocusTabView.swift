import SwiftUI
import SwiftData

struct FocusTabView: View {

    @Environment(TimerService.self) private var timer
    @Environment(AudioService.self) private var audio
    @Environment(\.modelContext) private var context
    @Query private var settingsRows: [AppSettings]

    @State private var durationMinutes: Int = 25
    @State private var customMinutes: Int = 25
    @State private var selectedTag: String = "Writing"
    @State private var selectedSound: String = "Silence"
    @State private var autoStartBreak: Bool = true

    private let presets: [(name: String, minutes: Int)] = [
        ("Short", 15), ("Classic", 25), ("Deep Work", 45)
    ]

    private var settings: AppSettings? { settingsRows.first }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Space.s6) {

            todayChips

            VStack(alignment: .leading, spacing: Theme.Space.s2) {
                FieldLabel(text: "Duration")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Theme.Space.s2), count: 4)) {
                    ForEach(presets, id: \.name) { preset in
                        PresetSegment(
                            isActive: durationMinutes == preset.minutes,
                            action: { durationMinutes = preset.minutes }
                        ) {
                            Text(preset.name)
                        } meta: {
                            Text("\(preset.minutes) min")
                        }
                    }
                    PresetSegment(
                        isActive: !presets.map(\.minutes).contains(durationMinutes),
                        action: { durationMinutes = customMinutes }
                    ) {
                        Text("Custom")
                    } meta: {
                        if presets.map(\.minutes).contains(durationMinutes) {
                            Text("– – min")
                        } else {
                            Text("\(durationMinutes) min")
                        }
                    }
                }

                if !presets.map(\.minutes).contains(durationMinutes) {
                    HStack {
                        Spacer()
                        Stepper(value: Binding(get: { durationMinutes }, set: {
                            durationMinutes = $0
                            customMinutes = $0
                        }), in: 5...180, step: 5) {
                            Text("Custom: \(durationMinutes) min")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.Palette.inkMuted)
                        }
                        .controlSize(.small)
                    }
                }
            }

            HStack(spacing: Theme.Space.s4) {
                VStack(alignment: .leading, spacing: Theme.Space.s2) {
                    FieldLabel(text: "Session label")
                    Picker("", selection: $selectedTag) {
                        ForEach(SeedData.focusTags, id: \.self) { Text($0).tag($0) }
                    }
                    .labelsHidden()
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: Theme.Space.s2) {
                    FieldLabel(text: "Background sound")
                    Picker("", selection: $selectedSound) {
                        ForEach(SeedData.focusSounds, id: \.self) { Text($0).tag($0) }
                    }
                    .labelsHidden()
                }
                .frame(maxWidth: .infinity)
            }

            CardContainer(inset: true) {
                HStack(spacing: Theme.Space.s4) {
                    Image(systemName: "speaker.wave.2")
                        .foregroundStyle(Theme.Palette.inkMuted)
                    Slider(value: Binding(get: { audio.volume * 100 }, set: { audio.volume = Float($0/100) }), in: 0...100)
                        .tint(Theme.Palette.focus)
                    Text("\(Int(audio.volume * 100))")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Palette.inkMuted)
                        .frame(width: 28, alignment: .trailing)

                    Divider().frame(height: 18)

                    Toggle(isOn: $autoStartBreak) {
                        Text("Auto-start break after focus")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.Palette.inkMuted)
                    }
                    .toggleStyle(.checkbox)
                }
            }

            Spacer(minLength: Theme.Space.s2)

            HStack {
                Spacer()
                PrimaryActionButton(
                    label: "Start Focus · \(durationMinutes) min",
                    icon: "play.fill",
                    tone: .focus,
                    action: startFocus
                )
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { syncFromSettings() }
    }

    private var todayChips: some View {
        HStack(spacing: Theme.Space.s3) {
            Text(makeTodayLine())
                .font(.system(size: 12))
                .foregroundStyle(Theme.Palette.inkMuted)
        }
    }

    private func makeTodayLine() -> AttributedString {
        var s = AttributedString("Set a focus duration, label your work, and begin.")
        s.foregroundColor = Theme.Palette.inkMuted
        return s
    }

    private func syncFromSettings() {
        guard let settings else { return }
        durationMinutes = max(5, Int(settings.defaultFocusDuration / 60))
        customMinutes = durationMinutes
        selectedSound = settings.defaultFocusSound
        autoStartBreak = settings.autoStartBreakAfterFocus
        audio.volume = Float(settings.volume)
    }

    private func startFocus() {
        let duration = TimeInterval(durationMinutes * 60)
        timer.startFocus(duration: duration, tag: selectedTag, sound: selectedSound)
        audio.playAmbient(selectedSound)
    }
}
