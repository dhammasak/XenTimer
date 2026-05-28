import SwiftUI
import SwiftData

struct DashboardView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \FocusSession.startTime, order: .reverse) private var allFocus: [FocusSession]
    @Query(sort: \BreathingSession.startTime, order: .reverse) private var allBreathing: [BreathingSession]
    @Query private var settingsRows: [AppSettings]

    @State private var stats: DailyAggregator.DailyStats?
    @State private var weekStats: [DailyAggregator.DailyStats] = []
    @State private var streak: Int = 0
    @State private var bestStreak: Int = 0
    @State private var lastExportMessage: String?

    private var settings: AppSettings? { settingsRows.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Space.s5) {

                header

                if let stats {
                    heroRow(stats: stats)
                    secondaryRow(stats: stats)
                    timelineCard(stats: stats)
                } else {
                    Text("Loading today…")
                        .foregroundStyle(Theme.Palette.inkMuted)
                        .padding(.vertical, Theme.Space.s8)
                }
            }
            .padding(Theme.Space.s7)
        }
        .task { recompute() }
        .onChange(of: allFocus.count) { _, _ in recompute() }
        .onChange(of: allBreathing.count) { _, _ in recompute() }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(headerEyebrow)
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(Theme.Palette.inkMuted)
                Text("Today")
                    .font(Theme.Typography.h1)
                    .foregroundStyle(Theme.Palette.ink)
            }
            Spacer()
            Button {
                exportMarkdown()
            } label: {
                Label("Export Markdown", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
            .disabled(settings?.markdownExportBookmark == nil)
            if let message = lastExportMessage {
                Text(message)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.Palette.inkMuted)
            }
        }
    }

    private var headerEyebrow: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE · MMM d, yyyy"
        return f.string(from: .now).uppercased()
    }

    private func heroRow(stats: DailyAggregator.DailyStats) -> some View {
        HStack(spacing: Theme.Space.s4) {
            // Focus completed (with weekly sparkline)
            HeroStatCard {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        StatLabel("Focus completed")
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            StatNumber("\(stats.focusCompleted)")
                            StatSuffix("sessions")
                        }
                        if let delta = yesterdayDelta {
                            ChipView(label: delta, style: .focus)
                                .padding(.top, 4)
                        }
                    }
                    Spacer()
                    StatIcon(systemName: "timer", tone: .focus)
                }
                if !weekStats.isEmpty {
                    sparkline.padding(.top, Theme.Space.s3)
                }
            }
            .frame(maxWidth: .infinity)

            HeroStatCard {
                VStack(alignment: .leading, spacing: 4) {
                    StatLabel("Focus time")
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        StatNumber(timeNumber(stats.totalFocusTime))
                        StatSuffix(timeSuffix(stats.totalFocusTime))
                    }
                    Text("Break time · \(TimeFormatting.humanDuration(stats.totalBreakTime))")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Palette.inkSoft)
                        .padding(.top, Theme.Space.s3)
                }
            }
            .frame(maxWidth: .infinity)

            HeroStatCard {
                VStack(alignment: .leading, spacing: 4) {
                    StatLabel("Average rating")
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        if let avg = stats.averageRating {
                            StatNumber(String(format: "%.1f", avg))
                            StatSuffix("/ 10")
                        } else {
                            StatNumber("—")
                            StatSuffix("no ratings")
                        }
                    }
                    if let avg = stats.averageRating {
                        ratingDots(value: Int(avg.rounded()))
                            .padding(.top, Theme.Space.s3)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func secondaryRow(stats: DailyAggregator.DailyStats) -> some View {
        HStack(spacing: Theme.Space.s4) {
            HeroStatCard {
                VStack(alignment: .leading, spacing: Theme.Space.s2) {
                    StatLabel("Breathing practice")
                    HStack(alignment: .lastTextBaseline, spacing: Theme.Space.s3) {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(stats.breathingSessions.count)")
                                .font(.system(size: 24, weight: .light, design: .default))
                                .foregroundStyle(Theme.Palette.ink)
                                .monospacedDigit()
                            Text("sessions").font(Theme.Typography.small)
                        }
                        Divider().frame(height: 16)
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(Int(stats.totalBreathingTime / 60))")
                                .font(.system(size: 24, weight: .light, design: .default))
                                .foregroundStyle(Theme.Palette.ink)
                                .monospacedDigit()
                            Text("min").font(Theme.Typography.small)
                        }
                    }
                    Text("Includes pomodoro breaks + standalone")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Palette.inkSoft)
                        .padding(.top, Theme.Space.s2)
                }
            }
            .frame(maxWidth: .infinity)

            HeroStatCard {
                VStack(alignment: .leading, spacing: Theme.Space.s2) {
                    StatLabel("Top focus tags")
                    let tagCounts = tagFrequency(in: stats.focusSessions)
                    if tagCounts.isEmpty {
                        Text("No tagged focus sessions today")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Palette.inkMuted)
                            .padding(.top, 6)
                    } else {
                        ForEach(tagCounts.prefix(3), id: \.tag) { item in
                            HStack {
                                ChipView(label: item.tag, style: .focus)
                                Text("\(item.count)× · \(TimeFormatting.humanDuration(item.duration))")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.Palette.inkMuted)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)

            HeroStatCard {
                VStack(alignment: .leading, spacing: Theme.Space.s2) {
                    StatLabel("Streak")
                    HStack(spacing: Theme.Space.s3) {
                        ZStack {
                            Circle()
                                .fill(Theme.Palette.burgundySoft)
                                .frame(width: 36, height: 36)
                            Image(systemName: "flame")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.Palette.burgundy)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(streak) day\(streak == 1 ? "" : "s")")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.Palette.ink)
                            Text("Best \(bestStreak)")
                                .font(Theme.Typography.small)
                                .foregroundStyle(Theme.Palette.inkMuted)
                        }
                    }
                    if let mostUsed = stats.mostUsedBreathingPattern {
                        Divider().padding(.vertical, 2)
                        HStack {
                            ChipView(label: mostUsed, style: .breath)
                            Text("most used pattern")
                                .font(Theme.Typography.small)
                                .foregroundStyle(Theme.Palette.inkMuted)
                            Spacer()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func timelineCard(stats: DailyAggregator.DailyStats) -> some View {
        HeroStatCard {
            VStack(alignment: .leading, spacing: Theme.Space.s3) {
                HStack {
                    Text("Today's sessions")
                        .font(Theme.Typography.h3)
                        .foregroundStyle(Theme.Palette.ink)
                    Spacer()
                    Text("\(stats.focusSessions.count + stats.breathingSessions.count) total")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Palette.inkMuted)
                }
                if stats.focusSessions.isEmpty && stats.breathingSessions.isEmpty {
                    Text("No sessions yet today. Start a focus session from the Timer tab.")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Palette.inkMuted)
                        .padding(.vertical, Theme.Space.s4)
                } else {
                    let merged = mergeTimeline(focus: stats.focusSessions, breathing: stats.breathingSessions)
                    ForEach(Array(merged.enumerated()), id: \.offset) { _, row in
                        TimelineRow(row: row)
                        if row.id != merged.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Bits

    private var sparkline: some View {
        let max = weekStats.map(\.focusCompleted).max() ?? 0
        return HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(weekStats.enumerated()), id: \.offset) { idx, day in
                let h = max > 0 ? CGFloat(day.focusCompleted) / CGFloat(max) : 0
                Rectangle()
                    .fill(idx == weekStats.count - 1 ? Theme.Palette.focus : Theme.Palette.focusSoft)
                    .frame(height: 32 * h)
                    .frame(maxHeight: 32, alignment: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
        .frame(height: 32)
    }

    private func ratingDots(value: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(1...10, id: \.self) { i in
                Circle()
                    .fill(i <= value ? Theme.Palette.burgundy : Theme.Palette.border)
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var yesterdayDelta: String? {
        guard weekStats.count >= 2 else { return nil }
        let today = weekStats[weekStats.count - 1].focusCompleted
        let yesterday = weekStats[weekStats.count - 2].focusCompleted
        let delta = today - yesterday
        if delta == 0 { return nil }
        return delta > 0 ? "+\(delta) vs yesterday" : "\(delta) vs yesterday"
    }

    private func tagFrequency(in sessions: [FocusSession]) -> [(tag: String, count: Int, duration: TimeInterval)] {
        var counts: [String: (Int, TimeInterval)] = [:]
        for s in sessions {
            guard let tag = s.tag, !tag.isEmpty else { continue }
            counts[tag, default: (0, 0)].0 += 1
            counts[tag, default: (0, 0)].1 += s.actualDuration
        }
        return counts
            .map { (tag: $0.key, count: $0.value.0, duration: $0.value.1) }
            .sorted { $0.count > $1.count }
    }

    private func timeNumber(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 { return "\(h)" }
        return "\(m)"
    }

    private func timeSuffix(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 { return "hr \(m) min" }
        return "min"
    }

    // MARK: - Compute

    private func recompute() {
        stats = try? DailyAggregator.stats(for: .now, context: context)
        weekStats = lastSevenDays()
        let (current, best) = computeStreak()
        streak = current
        bestStreak = best
    }

    private func lastSevenDays() -> [DailyAggregator.DailyStats] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        return (0..<7).reversed().compactMap { offset -> DailyAggregator.DailyStats? in
            guard let day = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return try? DailyAggregator.stats(for: day, context: context)
        }
    }

    private func computeStreak() -> (current: Int, best: Int) {
        let cal = Calendar.current
        let completedDays = Set(allFocus.filter(\.completed).map { cal.startOfDay(for: $0.startTime) })
        guard !completedDays.isEmpty else { return (0, 0) }

        // Compute current streak going back from today
        var current = 0
        var cursor = cal.startOfDay(for: .now)
        while completedDays.contains(cursor) {
            current += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }

        // Compute best streak across all days
        let sorted = completedDays.sorted()
        var best = 0
        var run = 0
        var lastDay: Date?
        for day in sorted {
            if let last = lastDay, let next = cal.date(byAdding: .day, value: 1, to: last), next == day {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
            lastDay = day
        }

        return (current, max(current, best))
    }

    // MARK: - Export

    private func exportMarkdown() {
        guard let settings = settingsRows.first else { return }
        do {
            let url = try MarkdownExporter.writeDailyReport(for: .now, in: context, settings: settings)
            lastExportMessage = "Exported to \(url.lastPathComponent)"
        } catch {
            lastExportMessage = error.localizedDescription
        }
    }

    // MARK: - Timeline

    struct TimelineEntry: Identifiable {
        let id: UUID
        let start: Date
        let end: Date
        let kind: Kind
        let tag: String?
        let pattern: String?
        let sound: String?
        let rating: Int?
        let duration: TimeInterval

        enum Kind { case focus, standaloneBreathing, breakBreathing }
    }

    private func mergeTimeline(focus: [FocusSession], breathing: [BreathingSession]) -> [TimelineEntry] {
        var rows: [TimelineEntry] = []
        for s in focus {
            rows.append(TimelineEntry(
                id: s.id, start: s.startTime, end: s.endTime, kind: .focus,
                tag: s.tag, pattern: nil, sound: s.backgroundSound, rating: s.rating,
                duration: s.actualDuration
            ))
        }
        for s in breathing {
            rows.append(TimelineEntry(
                id: s.id, start: s.startTime, end: s.endTime,
                kind: s.sessionType == .standalone ? .standaloneBreathing : .breakBreathing,
                tag: nil, pattern: s.patternName, sound: s.ambientSound, rating: nil,
                duration: s.actualDuration
            ))
        }
        return rows.sorted { $0.start < $1.start }
    }
}

// MARK: - Timeline row

private struct TimelineRow: View {
    let row: DashboardView.TimelineEntry

    var body: some View {
        HStack(spacing: Theme.Space.s3) {
            Text(TimeFormatting.range(row.start, row.end))
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Theme.Palette.inkMuted)
                .frame(width: 100, alignment: .leading)

            switch row.kind {
            case .focus:
                ChipView(label: row.tag ?? "Focus", style: .focus)
            case .standaloneBreathing:
                ChipView(label: "Breathing", style: .breath)
            case .breakBreathing:
                ChipView(label: "Recovery", style: .breath)
            }

            Text(TimeFormatting.humanDuration(row.duration))
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Palette.inkMuted)

            Spacer()

            if let pattern = row.pattern {
                Text(pattern)
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkSoft)
            }
            if let sound = row.sound, sound != "Silence" {
                Text(sound)
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkSoft)
            }
            if let rating = row.rating {
                ChipView(label: "\(rating)/10", style: .burgundy)
            }
        }
        .padding(.vertical, Theme.Space.s2)
    }
}

// MARK: - Card helpers

private struct HeroStatCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(Theme.Space.s5)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Theme.Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .strokeBorder(Theme.Palette.border, lineWidth: 1)
        )
    }
}

private struct StatLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Theme.Palette.inkMuted)
            .tracking(0.2)
    }
}

private struct StatNumber: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 32, weight: .light, design: .default))
            .foregroundStyle(Theme.Palette.ink)
            .monospacedDigit()
    }
}

private struct StatSuffix: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundStyle(Theme.Palette.inkMuted)
    }
}

private struct StatIcon: View {
    enum Tone { case focus, breath, burgundy }
    let systemName: String
    var tone: Tone = .focus

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.Radius.md)
                .fill(background)
                .frame(width: 36, height: 36)
            Image(systemName: systemName)
                .font(.system(size: 16))
                .foregroundStyle(foreground)
        }
    }

    private var background: Color {
        switch tone {
        case .focus:    Theme.Palette.focusSoft
        case .breath:   Theme.Palette.breathBg
        case .burgundy: Theme.Palette.burgundySoft
        }
    }
    private var foreground: Color {
        switch tone {
        case .focus:    Theme.Palette.focusDeep
        case .breath:   Theme.Palette.breath
        case .burgundy: Theme.Palette.burgundy
        }
    }
}
