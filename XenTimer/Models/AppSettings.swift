import Foundation
import SwiftData

enum MenuBarDisplayStyle: String, Codable, CaseIterable, Identifiable {
    case labelAndTime
    case timeOnly
    case iconOnly

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .labelAndTime: "Label + Time"
        case .timeOnly:     "Time only"
        case .iconOnly:     "Icon only"
        }
    }
}

enum BreathingGuideMode: String, Codable, CaseIterable, Identifiable {
    case voice
    case bell
    case visualOnly
    case silent

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .voice:      "Voice"
        case .bell:       "Soft bell"
        case .visualOnly: "Visual only"
        case .silent:     "Silent"
        }
    }
}

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID

    var defaultFocusDuration: TimeInterval
    var defaultBreakDuration: TimeInterval
    var defaultStandaloneBreathingDuration: TimeInterval
    var defaultBreathingPatternID: UUID?

    var defaultFocusSound: String
    var defaultBreakSound: String
    var defaultBreathingGuideRaw: String

    var notificationsEnabled: Bool
    var menuBarDisplayStyleRaw: String

    var markdownExportBookmark: Data?
    var markdownExportPath: String?
    var autoExportDaily: Bool
    var includeReflectionPrompts: Bool

    var autoStartBreakAfterFocus: Bool
    var promptForRating: Bool
    var launchAtLogin: Bool

    var volume: Double  // 0…1

    init(
        id: UUID = UUID(),
        defaultFocusDuration: TimeInterval = 25 * 60,
        defaultBreakDuration: TimeInterval = 5 * 60,
        defaultStandaloneBreathingDuration: TimeInterval = 10 * 60,
        defaultBreathingPatternID: UUID? = nil,
        defaultFocusSound: String = "Silence",
        defaultBreakSound: String = "Silence",
        defaultBreathingGuide: BreathingGuideMode = .bell,
        notificationsEnabled: Bool = true,
        menuBarDisplayStyle: MenuBarDisplayStyle = .labelAndTime,
        markdownExportBookmark: Data? = nil,
        markdownExportPath: String? = nil,
        autoExportDaily: Bool = true,
        includeReflectionPrompts: Bool = true,
        autoStartBreakAfterFocus: Bool = true,
        promptForRating: Bool = true,
        launchAtLogin: Bool = false,
        volume: Double = 0.6
    ) {
        self.id = id
        self.defaultFocusDuration = defaultFocusDuration
        self.defaultBreakDuration = defaultBreakDuration
        self.defaultStandaloneBreathingDuration = defaultStandaloneBreathingDuration
        self.defaultBreathingPatternID = defaultBreathingPatternID
        self.defaultFocusSound = defaultFocusSound
        self.defaultBreakSound = defaultBreakSound
        self.defaultBreathingGuideRaw = defaultBreathingGuide.rawValue
        self.notificationsEnabled = notificationsEnabled
        self.menuBarDisplayStyleRaw = menuBarDisplayStyle.rawValue
        self.markdownExportBookmark = markdownExportBookmark
        self.markdownExportPath = markdownExportPath
        self.autoExportDaily = autoExportDaily
        self.includeReflectionPrompts = includeReflectionPrompts
        self.autoStartBreakAfterFocus = autoStartBreakAfterFocus
        self.promptForRating = promptForRating
        self.launchAtLogin = launchAtLogin
        self.volume = volume
    }

    var menuBarDisplayStyle: MenuBarDisplayStyle {
        get { MenuBarDisplayStyle(rawValue: menuBarDisplayStyleRaw) ?? .labelAndTime }
        set { menuBarDisplayStyleRaw = newValue.rawValue }
    }

    var defaultBreathingGuide: BreathingGuideMode {
        get { BreathingGuideMode(rawValue: defaultBreathingGuideRaw) ?? .bell }
        set { defaultBreathingGuideRaw = newValue.rawValue }
    }
}
