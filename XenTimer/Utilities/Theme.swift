import SwiftUI

enum Theme {

    enum Palette {
        static let ink           = Color("Ink")
        static let inkMuted      = Color("InkMuted")
        static let inkSoft       = Color("InkSoft")
        static let bg            = Color("Bg")
        static let surface       = Color("Surface")
        static let surface2      = Color("Surface2")
        static let border        = Color("Border")
        static let borderStrong  = Color("BorderStrong")

        static let focus         = Color("Focus")
        static let focusDeep     = Color("FocusDeep")
        static let focusSoft     = Color("FocusSoft")

        static let breath        = Color("Breath")
        static let breathSoft    = Color("BreathSoft")
        static let breathBg      = Color("BreathBg")

        static let burgundy      = Color("Burgundy")
        static let burgundySoft  = Color("BurgundySoft")
        static let warn          = Color("Warn")
    }

    enum Typography {
        static func display(size: CGFloat, weight: Font.Weight = .light) -> Font {
            .system(size: size, weight: weight, design: .default)
        }
        static let displayXL   = Font.system(size: 64, weight: .ultraLight, design: .default)
        static let displayL    = Font.system(size: 44, weight: .light,      design: .default)
        static let display     = Font.system(size: 32, weight: .light,      design: .default)
        static let h1          = Font.system(size: 24, weight: .medium,     design: .default)
        static let h2          = Font.system(size: 18, weight: .medium,     design: .default)
        static let h3          = Font.system(size: 15, weight: .semibold,   design: .default)
        static let body        = Font.system(size: 14, weight: .regular,    design: .default)
        static let small       = Font.system(size: 13, weight: .regular,    design: .default)
        static let meta        = Font.system(size: 11, weight: .medium,     design: .default)
        static let mono        = Font.system(size: 14, weight: .medium,     design: .monospaced)
        static let monoLarge   = Font.system(size: 28, weight: .light,      design: .monospaced)
    }

    enum Space {
        static let s1: CGFloat = 4
        static let s2: CGFloat = 8
        static let s3: CGFloat = 12
        static let s4: CGFloat = 16
        static let s5: CGFloat = 20
        static let s6: CGFloat = 24
        static let s7: CGFloat = 32
        static let s8: CGFloat = 40
        static let s9: CGFloat = 48
        static let s10: CGFloat = 64
    }

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let pill: CGFloat = 999
    }

    enum Motion {
        static let fast: Double = 0.16
        static let base: Double = 0.24
        static let slow: Double = 0.40

        static var easeStandard: Animation { .timingCurve(0.4, 0, 0.2, 1, duration: base) }
        static var easeSlow: Animation     { .timingCurve(0.4, 0, 0.2, 1, duration: slow) }
        static var breathing: Animation    { .easeInOut(duration: base) }
    }
}
