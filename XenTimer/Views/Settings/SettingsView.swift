import SwiftUI
import SwiftData

enum SettingsSection: String, CaseIterable, Identifiable {
    case general, notifications, markdown, audio, patterns, about
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .general:       "General"
        case .notifications: "Notifications"
        case .markdown:      "Markdown export"
        case .audio:         "Audio"
        case .patterns:      "Breathing patterns"
        case .about:         "About"
        }
    }

    var systemImage: String {
        switch self {
        case .general:       "gearshape"
        case .notifications: "bell"
        case .markdown:      "doc.text"
        case .audio:         "speaker.wave.2"
        case .patterns:      "wind"
        case .about:         "info.circle"
        }
    }
}

struct SettingsView: View {

    @State private var section: SettingsSection = .general
    @Query private var settingsRows: [AppSettings]
    @Environment(\.modelContext) private var context

    var body: some View {
        HStack(spacing: 0) {
            sidebar
                .frame(width: 200)
                .background(Theme.Palette.surface2)

            Divider()

            ScrollView {
                Group {
                    if let settings = settingsRows.first {
                        contentView(for: settings)
                    } else {
                        Text("Loading settings…")
                            .foregroundStyle(Theme.Palette.inkMuted)
                            .padding()
                    }
                }
                .padding(Theme.Space.s7)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Theme.Palette.bg)
        }
        .frame(minWidth: 720, minHeight: 520)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(SettingsSection.allCases) { item in
                Button {
                    section = item
                } label: {
                    HStack(spacing: Theme.Space.s3) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 13))
                            .frame(width: 16)
                        Text(item.displayName)
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                    }
                    .padding(.vertical, 8).padding(.horizontal, 12)
                    .foregroundStyle(section == item ? Theme.Palette.ink : Theme.Palette.inkMuted)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.md)
                            .fill(section == item ? Theme.Palette.surface : .clear)
                    )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(Theme.Space.s3)
        .padding(.top, Theme.Space.s5)
    }

    @ViewBuilder
    private func contentView(for settings: AppSettings) -> some View {
        @Bindable var s = settings
        VStack(alignment: .leading, spacing: Theme.Space.s5) {
            Text(section.displayName)
                .font(Theme.Typography.h1)
                .foregroundStyle(Theme.Palette.ink)

            switch section {
            case .general:       GeneralSettingsContent(settings: s)
            case .notifications: NotificationsSettingsContent(settings: s)
            case .markdown:      MarkdownExportSettingsContent(settings: s)
            case .audio:         AudioSettingsContent(settings: s)
            case .patterns:      BreathingPatternsSettingsContent()
            case .about:         AboutSettingsContent()
            }
        }
    }
}

// MARK: - General

private struct GeneralSettingsContent: View {
    @Bindable var settings: AppSettings

    private var focusMinutes: Binding<Int> {
        Binding(get: { Int(settings.defaultFocusDuration / 60) },
                set: { settings.defaultFocusDuration = TimeInterval($0 * 60) })
    }
    private var breakMinutes: Binding<Int> {
        Binding(get: { Int(settings.defaultBreakDuration / 60) },
                set: { settings.defaultBreakDuration = TimeInterval($0 * 60) })
    }
    private var standaloneMinutes: Binding<Int> {
        Binding(get: { Int(settings.defaultStandaloneBreathingDuration / 60) },
                set: { settings.defaultStandaloneBreathingDuration = TimeInterval($0 * 60) })
    }

    var body: some View {
        SettingsCard {
            SettingRow(title: "Default focus duration", description: "Pre-selected when opening the Focus tab") {
                Picker("", selection: focusMinutes) {
                    Text("15 min · Short").tag(15)
                    Text("25 min · Classic").tag(25)
                    Text("45 min · Deep Work").tag(45)
                    Text("90 min · Marathon").tag(90)
                }
                .labelsHidden()
                .frame(width: 200)
            }

            SettingRow(title: "Default break duration", description: "Used after each focus session") {
                Picker("", selection: breakMinutes) {
                    Text("3 min · Short").tag(3)
                    Text("5 min · Standard").tag(5)
                    Text("10 min · Long").tag(10)
                }
                .labelsHidden()
                .frame(width: 200)
            }

            SettingRow(title: "Default standalone breathing length", description: "Pre-selected on the Breathing tab") {
                Picker("", selection: standaloneMinutes) {
                    Text("5 min").tag(5)
                    Text("10 min").tag(10)
                    Text("15 min").tag(15)
                    Text("20 min").tag(20)
                }
                .labelsHidden()
                .frame(width: 200)
            }

            SettingRow(title: "Auto-start break after focus", description: "Suggest a guided breathing break when focus completes") {
                Toggle("", isOn: $settings.autoStartBreakAfterFocus).labelsHidden()
                    .toggleStyle(.switch).tint(Theme.Palette.focus)
            }

            SettingRow(title: "Prompt for focus rating", description: "Ask 1–10 after each focus session") {
                Toggle("", isOn: $settings.promptForRating).labelsHidden()
                    .toggleStyle(.switch).tint(Theme.Palette.focus)
            }
        }

        Text("Menu bar").font(Theme.Typography.h2).foregroundStyle(Theme.Palette.ink)

        SettingsCard {
            SettingRow(title: "Display style", description: "What appears in the macOS menu bar while a session runs") {
                Picker("", selection: Binding(
                    get: { settings.menuBarDisplayStyle },
                    set: { settings.menuBarDisplayStyle = $0 })
                ) {
                    ForEach(MenuBarDisplayStyle.allCases) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .labelsHidden()
                .frame(width: 200)
            }
        }
    }
}

// MARK: - Notifications

private struct NotificationsSettingsContent: View {
    @Bindable var settings: AppSettings

    var body: some View {
        SettingsCard {
            SettingRow(title: "Enable notifications", description: "Required for session events to appear in Notification Center") {
                Toggle("", isOn: $settings.notificationsEnabled).labelsHidden()
                    .toggleStyle(.switch).tint(Theme.Palette.focus)
            }
        }

        Text("Notifications include: focus complete, break started, break complete, breathing complete, daily goal.")
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Palette.inkMuted)
    }
}

// MARK: - Markdown export

private struct MarkdownExportSettingsContent: View {
    @Bindable var settings: AppSettings
    @Environment(\.modelContext) private var context
    @State private var lastExportedAt: Date?
    @State private var lastExportError: String?

    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: Theme.Space.s3) {
                FieldLabel(text: "Export folder")
                HStack(spacing: Theme.Space.s3) {
                    Image(systemName: "folder")
                        .foregroundStyle(Theme.Palette.inkMuted)
                    Text(settings.markdownExportPath ?? "No folder selected")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Theme.Palette.ink)
                        .lineLimit(2)
                        .truncationMode(.middle)
                    Spacer()
                    Button("Choose…") { chooseFolder() }
                        .buttonStyle(.bordered)
                }
                .padding(Theme.Space.s3)
                .background(Theme.Palette.surface2)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            }
        }

        SettingsCard {
            SettingRow(title: "Auto-export daily report", description: "Write today's Markdown report on quit and at end of day") {
                Toggle("", isOn: $settings.autoExportDaily).labelsHidden()
                    .toggleStyle(.switch).tint(Theme.Palette.focus)
            }

            SettingRow(title: "Include reflection prompts", description: "Add 'What went well / what interrupted / what to improve' template") {
                Toggle("", isOn: $settings.includeReflectionPrompts).labelsHidden()
                    .toggleStyle(.switch).tint(Theme.Palette.focus)
            }
        }

        HStack {
            Button {
                exportToday()
            } label: {
                Label("Export today now", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.Palette.focus)
            .disabled(settings.markdownExportBookmark == nil)

            if let date = lastExportedAt {
                Text("Last export: \(date.formatted(date: .omitted, time: .shortened))")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkMuted)
            }
        }

        if let err = lastExportError {
            Text(err)
                .font(Theme.Typography.small)
                .foregroundStyle(.red)
        }
    }

    private func chooseFolder() {
        guard let chosen = MarkdownExporter.chooseFolder() else { return }
        settings.markdownExportBookmark = chosen.bookmark
        settings.markdownExportPath = chosen.url.path(percentEncoded: false)
        try? context.save()
    }

    private func exportToday() {
        do {
            _ = try MarkdownExporter.writeDailyReport(for: .now, in: context, settings: settings)
            lastExportedAt = .now
            lastExportError = nil
        } catch {
            lastExportError = error.localizedDescription
        }
    }
}

// MARK: - Audio

private struct AudioSettingsContent: View {
    @Bindable var settings: AppSettings
    @Environment(AudioService.self) private var audio

    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: Theme.Space.s3) {
                FieldLabel(text: "Volume")
                HStack(spacing: Theme.Space.s3) {
                    Image(systemName: "speaker.wave.1")
                        .foregroundStyle(Theme.Palette.inkMuted)
                    Slider(value: Binding(
                        get: { settings.volume * 100 },
                        set: {
                            settings.volume = $0 / 100
                            audio.volume = Float(settings.volume)
                        }
                    ), in: 0...100)
                    .tint(Theme.Palette.focus)
                    Text("\(Int(settings.volume * 100))")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Palette.inkMuted)
                        .frame(width: 28, alignment: .trailing)
                }
            }
        }

        SettingsCard {
            SettingRow(title: "Default focus sound", description: "Ambient sound for focus sessions") {
                Picker("", selection: $settings.defaultFocusSound) {
                    ForEach(SeedData.focusSounds, id: \.self) { Text($0).tag($0) }
                }
                .labelsHidden()
                .frame(width: 200)
            }
            SettingRow(title: "Default break sound", description: "Ambient sound for breathing breaks") {
                Picker("", selection: $settings.defaultBreakSound) {
                    ForEach(SeedData.breathingSounds, id: \.self) { Text($0).tag($0) }
                }
                .labelsHidden()
                .frame(width: 200)
            }
            SettingRow(title: "Default breathing guide", description: "Voice / bell / visual only / silent") {
                Picker("", selection: Binding(
                    get: { settings.defaultBreathingGuide },
                    set: { settings.defaultBreathingGuide = $0 })
                ) {
                    ForEach(BreathingGuideMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .labelsHidden()
                .frame(width: 200)
            }
        }
    }
}

// MARK: - Breathing patterns

private struct BreathingPatternsSettingsContent: View {
    @Query(sort: \BreathingPattern.sortOrder) private var patterns: [BreathingPattern]
    @Environment(\.modelContext) private var context

    var body: some View {
        SettingsCard {
            ForEach(patterns) { pattern in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pattern.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.Palette.ink)
                        Text("\(pattern.compactDescription) — \(pattern.purpose)")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Palette.inkMuted)
                    }
                    Spacer()
                    if pattern.isCustom {
                        ChipView(label: "Custom", style: .burgundy)
                    } else {
                        ChipView(label: "Default", style: .neutral)
                    }
                }
                .padding(.vertical, Theme.Space.s2)
                if pattern.id != patterns.last?.id {
                    Divider()
                }
            }
        }
        Text("Custom patterns can be saved from the Breathing tab.")
            .font(Theme.Typography.small)
            .foregroundStyle(Theme.Palette.inkMuted)
    }
}

// MARK: - About

private struct AboutSettingsContent: View {
    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: Theme.Space.s3) {
                Text("XenTimer 0.1.0")
                    .font(Theme.Typography.h2)
                    .foregroundStyle(Theme.Palette.ink)
                Text("Work with rhythm. Rest with breath.")
                    .italic()
                    .foregroundStyle(Theme.Palette.burgundy)
                Text("A macOS productivity timer that combines deep focus sessions with guided breathing breaks.")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkMuted)
            }
        }
    }
}

// MARK: - Shared bits

private struct SettingsCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(.horizontal, Theme.Space.s5)
        .padding(.vertical, Theme.Space.s3)
        .background(Theme.Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .strokeBorder(Theme.Palette.border, lineWidth: 1)
        )
    }
}

private struct SettingRow<Trailing: View>: View {
    let title: String
    let description: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .center, spacing: Theme.Space.s4) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.Palette.ink)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.Palette.inkMuted)
            }
            Spacer()
            trailing
        }
        .padding(.vertical, Theme.Space.s3)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.Palette.border)
                .frame(height: 1)
        }
    }
}
