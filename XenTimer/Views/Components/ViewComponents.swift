import SwiftUI

// MARK: - Tag chip

struct ChipView: View {
    enum Style { case neutral, focus, breath, burgundy }
    let label: String
    var style: Style = .neutral

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(Theme.Palette.border, lineWidth: style == .neutral ? 1 : 0))
    }

    private var background: Color {
        switch style {
        case .neutral:  Theme.Palette.surface2
        case .focus:    Theme.Palette.focusSoft
        case .breath:   Theme.Palette.breathBg
        case .burgundy: Theme.Palette.burgundySoft
        }
    }
    private var foreground: Color {
        switch style {
        case .neutral:  Theme.Palette.inkMuted
        case .focus:    Theme.Palette.focusDeep
        case .breath:   Theme.Palette.breath
        case .burgundy: Theme.Palette.burgundy
        }
    }
}

// MARK: - Card

struct CardContainer<Content: View>: View {
    var inset: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(Theme.Space.s6)
            .background(inset ? Theme.Palette.surface2 : Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                    .strokeBorder(inset ? Color.clear : Theme.Palette.border, lineWidth: 1)
            )
    }
}

// MARK: - Tabs

struct ModeTabsView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case focus, breathing
        var id: String { rawValue }
        var label: String { self == .focus ? "Focus" : "Breathing" }
    }

    @Binding var selection: Mode

    var body: some View {
        HStack(spacing: Theme.Space.s1) {
            ForEach(Mode.allCases) { mode in
                Button {
                    withAnimation(Theme.Motion.easeStandard) {
                        selection = mode
                    }
                } label: {
                    Text(mode.label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(selection == mode ? Theme.Palette.ink : Theme.Palette.inkMuted)
                        .padding(.vertical, 7)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(selection == mode ? Theme.Palette.surface : .clear)
                                .shadow(color: selection == mode ? .black.opacity(0.06) : .clear, radius: 1, y: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Theme.Palette.surface2)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
    }
}

// MARK: - Icon button

struct IconButton: View {
    let systemName: String
    var help: String?
    var isActive: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .regular))
                .frame(width: 32, height: 32)
                .foregroundStyle(isActive ? Theme.Palette.ink : Theme.Palette.inkMuted)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .fill(isActive ? Theme.Palette.surface2 : .clear)
                )
        }
        .buttonStyle(.plain)
        .help(help ?? "")
    }
}

// MARK: - Preset segment

struct PresetSegment<Title: View, Meta: View>: View {
    var isActive: Bool
    var tint: Color = Theme.Palette.focus
    var background: Color = Theme.Palette.focusSoft
    var action: () -> Void
    @ViewBuilder var title: Title
    @ViewBuilder var meta: Meta

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                title
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.Palette.ink)
                meta
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.Palette.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Theme.Space.s3)
            .padding(.horizontal, Theme.Space.s4)
            .background(isActive ? background : Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .strokeBorder(isActive ? tint : Theme.Palette.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section label

struct FieldLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Theme.Palette.inkMuted)
    }
}

// MARK: - Big primary button

struct PrimaryActionButton: View {
    enum Tone { case focus, breath }
    let label: String
    var icon: String? = "play.fill"
    var tone: Tone = .focus
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Space.s2) {
                if let icon { Image(systemName: icon).font(.system(size: 13, weight: .semibold)) }
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(Capsule().fill(tone == .focus ? Theme.Palette.focus : Theme.Palette.breath))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mode banner

struct ModeBanner: View {
    enum Tone { case focus, breath }
    let label: String
    var tone: Tone = .focus

    var body: some View {
        HStack(spacing: Theme.Space.s3) {
            Circle()
                .fill(tone == .focus ? Theme.Palette.focus : Theme.Palette.breath)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, Theme.Space.s4)
        .padding(.vertical, Theme.Space.s3)
        .foregroundStyle(tone == .focus ? Theme.Palette.focusDeep : Theme.Palette.breath)
        .background((tone == .focus ? Theme.Palette.focusSoft : Theme.Palette.breathBg))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
    }
}
