import Foundation

enum TimeFormatting {

    /// "18:42" or "1:18:42" if hours present.
    static func clock(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    /// "25 min", "1 hr 15 min", "45 sec".
    static func humanDuration(_ interval: TimeInterval) -> String {
        let total = Int(interval.rounded())
        if total < 60 {
            return "\(total) sec"
        }
        let h = total / 3600
        let m = (total % 3600) / 60
        if h == 0 { return "\(m) min" }
        if m == 0 { return "\(h) hr" }
        return "\(h) hr \(m) min"
    }

    /// "2 hr 30 min", "30 min"  — for daily totals.
    static func dailyDuration(_ interval: TimeInterval) -> String {
        humanDuration(interval)
    }

    /// "09:25" — wall clock time of day.
    static func wallClock(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    /// "09:00–09:25"
    static func range(_ start: Date, _ end: Date) -> String {
        "\(wallClock(start))–\(wallClock(end))"
    }
}
