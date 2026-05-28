import SwiftUI
import SwiftData

struct HistoryView: View {

    enum TypeFilter: String, CaseIterable, Identifiable {
        case all, focus, breathing
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all:       "All types"
            case .focus:     "Focus only"
            case .breathing: "Breathing only"
            }
        }
    }

    enum DateRangeFilter: String, CaseIterable, Identifiable {
        case last7, last30, thisMonth, allTime
        var id: String { rawValue }
        var label: String {
            switch self {
            case .last7:     "Last 7 days"
            case .last30:    "Last 30 days"
            case .thisMonth: "This month"
            case .allTime:   "All time"
            }
        }
        var startDate: Date? {
            let cal = Calendar.current
            switch self {
            case .last7:     return cal.date(byAdding: .day, value: -7, to: cal.startOfDay(for: .now))
            case .last30:    return cal.date(byAdding: .day, value: -30, to: cal.startOfDay(for: .now))
            case .thisMonth: return cal.dateInterval(of: .month, for: .now)?.start
            case .allTime:   return nil
            }
        }
    }

    enum Selection: Hashable {
        case focus(UUID)
        case breathing(UUID)
    }

    @Query(sort: \FocusSession.startTime, order: .reverse) private var allFocus: [FocusSession]
    @Query(sort: \BreathingSession.startTime, order: .reverse) private var allBreathing: [BreathingSession]
    @Query private var settingsRows: [AppSettings]
    @Environment(\.modelContext) private var context

    @State private var search: String = ""
    @State private var typeFilter: TypeFilter = .all
    @State private var dateFilter: DateRangeFilter = .last7
    @State private var selection: Selection?

    var body: some View {
        HStack(spacing: 0) {
            mainList
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            detailPane
                .frame(width: 320)
                .background(Theme.Palette.surface2)
        }
    }

    // MARK: - List

    private var mainList: some View {
        VStack(spacing: 0) {
            filterBar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    let days = groupedByDay
                    if days.isEmpty {
                        Text("No sessions in this range.")
                            .font(Theme.Typography.small)
                            .foregroundStyle(Theme.Palette.inkMuted)
                            .padding(Theme.Space.s7)
                    } else {
                        ForEach(days, id: \.day) { day in
                            dayHeader(day: day.day, focusCount: day.focusCount, breathingCount: day.breathingCount, totalSeconds: day.totalSeconds, avgRating: day.avgRating)
                                .padding(.top, Theme.Space.s4)

                            ForEach(day.entries) { entry in
                                Button {
                                    selection = entry.selection
                                } label: {
                                    historyRow(entry: entry, isSelected: selection == entry.selection)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.Space.s7)
                .padding(.bottom, Theme.Space.s7)
            }
        }
        .background(Theme.Palette.bg)
    }

    private var filterBar: some View {
        HStack(spacing: Theme.Space.s2) {
            HStack(spacing: Theme.Space.s2) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.Palette.inkMuted)
                TextField("Search sessions, tags, notes…", text: $search)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, Theme.Space.s3)
            .padding(.vertical, 6)
            .background(Theme.Palette.surface2)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .frame(maxWidth: .infinity)

            Picker("", selection: $typeFilter) {
                ForEach(TypeFilter.allCases) { Text($0.label).tag($0) }
            }
            .labelsHidden()
            .frame(width: 140)

            Picker("", selection: $dateFilter) {
                ForEach(DateRangeFilter.allCases) { Text($0.label).tag($0) }
            }
            .labelsHidden()
            .frame(width: 140)
        }
        .padding(.horizontal, Theme.Space.s7)
        .padding(.vertical, Theme.Space.s3)
        .background(Theme.Palette.surface)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.Palette.border).frame(height: 1)
        }
    }

    private func dayHeader(day: Date, focusCount: Int, breathingCount: Int, totalSeconds: TimeInterval, avgRating: Double?) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(dayHeaderText(day))
                    .font(Theme.Typography.h3)
                    .foregroundStyle(Theme.Palette.ink)
                Text(daySubtext(focus: focusCount, breathing: breathingCount, seconds: totalSeconds, avg: avgRating))
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkMuted)
            }
            Spacer()
            Button {
                exportDay(day)
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
                    .font(.system(size: 12))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(settingsRows.first?.markdownExportBookmark == nil)
        }
        .padding(.vertical, Theme.Space.s3)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.Palette.border).frame(height: 1)
        }
    }

    private func historyRow(entry: TimelineEntry, isSelected: Bool) -> some View {
        HStack(spacing: Theme.Space.s4) {
            Text(TimeFormatting.wallClock(entry.start))
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(isSelected ? Theme.Palette.focusDeep : Theme.Palette.inkMuted)
                .frame(width: 56, alignment: .leading)

            switch entry.kind {
            case .focus:
                ChipView(label: entry.tag ?? "Focus", style: .focus)
            case .standaloneBreathing:
                ChipView(label: "Standalone", style: .breath)
            case .breakBreathing:
                ChipView(label: "Recovery", style: .breath)
            }

            Text(TimeFormatting.humanDuration(entry.duration))
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Palette.inkMuted)

            if let sound = entry.sound, sound != "Silence" {
                Text("· \(sound)")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkSoft)
            }

            Spacer()

            if let pattern = entry.pattern {
                Text(pattern)
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkSoft)
            }
            if let rating = entry.rating {
                ChipView(label: "\(rating)", style: .burgundy)
            }
        }
        .padding(.vertical, Theme.Space.s3)
        .padding(.horizontal, Theme.Space.s3)
        .background(isSelected ? Theme.Palette.focusSoft : .clear)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
    }

    // MARK: - Detail pane

    private var detailPane: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Space.s5) {
                if let selection {
                    switch selection {
                    case .focus(let id):
                        if let session = allFocus.first(where: { $0.id == id }) {
                            focusDetail(session: session)
                        }
                    case .breathing(let id):
                        if let session = allBreathing.first(where: { $0.id == id }) {
                            breathingDetail(session: session)
                        }
                    }
                } else {
                    Text("Select a session to see details.")
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Palette.inkMuted)
                        .padding(.top, Theme.Space.s7)
                }
            }
            .padding(Theme.Space.s6)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func focusDetail(session: FocusSession) -> some View {
        VStack(alignment: .leading, spacing: Theme.Space.s5) {
            VStack(alignment: .leading, spacing: 2) {
                Text("SELECTED · \(TimeFormatting.range(session.startTime, session.endTime))")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(Theme.Palette.inkMuted)
                Text(session.tag ?? "Focus session")
                    .font(Theme.Typography.h1)
                    .foregroundStyle(Theme.Palette.ink)
                Text(longDate(session.startTime))
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkSoft)
            }

            if let rating = session.rating {
                HStack(spacing: 8) {
                    Text("\(rating)")
                        .font(.system(size: 24, weight: .light, design: .default))
                        .foregroundStyle(Theme.Palette.burgundy)
                    Text("/ 10 · \(ratingLabel(rating))")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.Palette.burgundy)
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Theme.Palette.burgundySoft)
                .clipShape(Capsule())
            }

            if let note = session.note, !note.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Space.s2) {
                    Text("REFLECTION")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(0.8)
                        .foregroundStyle(Theme.Palette.inkMuted)
                    Text("\u{201C}\(note)\u{201D}")
                        .font(.system(size: 13))
                        .italic()
                        .foregroundStyle(Theme.Palette.ink)
                        .padding(Theme.Space.s3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Palette.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.md)
                                .strokeBorder(Theme.Palette.border, lineWidth: 1)
                        )
                }
            }

            Divider()

            detailSection(label: "FOCUS") {
                detailRow(label: "Duration", value: TimeFormatting.humanDuration(session.actualDuration), trailing: "Planned \(TimeFormatting.humanDuration(session.plannedDuration))")
                if let sound = session.backgroundSound {
                    detailRow(label: "Background sound", value: sound, trailing: nil)
                }
                detailRow(label: "Status", value: session.completed ? "Completed" : "Stopped early", trailing: nil)
            }
        }
    }

    private func breathingDetail(session: BreathingSession) -> some View {
        VStack(alignment: .leading, spacing: Theme.Space.s5) {
            VStack(alignment: .leading, spacing: 2) {
                Text("SELECTED · \(TimeFormatting.range(session.startTime, session.endTime))")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(Theme.Palette.inkMuted)
                Text(session.patternName.isEmpty ? "Breathing session" : session.patternName)
                    .font(Theme.Typography.h1)
                    .foregroundStyle(Theme.Palette.ink)
                Text(longDate(session.startTime))
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkSoft)
            }

            if let note = session.reflectionNote, !note.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Space.s2) {
                    Text("REFLECTION")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(0.8)
                        .foregroundStyle(Theme.Palette.inkMuted)
                    Text("\u{201C}\(note)\u{201D}")
                        .font(.system(size: 13))
                        .italic()
                        .padding(Theme.Space.s3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Palette.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                }
            }

            Divider()

            detailSection(label: "BREATHING") {
                detailRow(label: "Type", value: session.sessionType.displayName, trailing: nil)
                detailRow(label: "Pattern", value: session.patternDescription, trailing: nil)
                detailRow(label: "Duration", value: TimeFormatting.humanDuration(session.actualDuration), trailing: "Planned \(TimeFormatting.humanDuration(session.plannedDuration))")
                if let sound = session.ambientSound {
                    detailRow(label: "Ambient sound", value: sound, trailing: nil)
                }
                detailRow(label: "Status", value: session.completed ? "Completed" : "Stopped early", trailing: nil)
            }
        }
    }

    private func detailSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.Space.s2) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .tracking(0.8)
                .foregroundStyle(Theme.Palette.inkMuted)
            content()
        }
    }

    private func detailRow(label: String, value: String, trailing: String?) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Theme.Palette.inkMuted)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.Palette.ink)
            if let trailing {
                Text(trailing)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.Palette.inkSoft)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func ratingLabel(_ rating: Int) -> String {
        switch rating {
        case 1...3: "Poor focus"
        case 4...6: "Moderate focus"
        case 7...8: "Good focus"
        default:    "Excellent focus"
        }
    }

    private func longDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }

    private func dayHeaderText(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today · \(monthDayString(date))" }
        if cal.isDateInYesterday(date) { return "Yesterday · \(monthDayString(date))" }
        let f = DateFormatter()
        f.dateFormat = "EEEE · MMM d"
        return f.string(from: date)
    }

    private func monthDayString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    private func daySubtext(focus: Int, breathing: Int, seconds: TimeInterval, avg: Double?) -> String {
        var parts: [String] = []
        parts.append("\(focus) focus")
        parts.append("\(breathing) breathing")
        parts.append("\(TimeFormatting.humanDuration(seconds)) total")
        if let avg { parts.append("Avg \(String(format: "%.1f", avg))") }
        return parts.joined(separator: " · ")
    }

    // MARK: - Grouping

    private struct DayGroup {
        let day: Date
        let entries: [TimelineEntry]
        let focusCount: Int
        let breathingCount: Int
        let totalSeconds: TimeInterval
        let avgRating: Double?
    }

    private struct TimelineEntry: Identifiable, Equatable {
        let id: UUID
        let start: Date
        let end: Date
        let kind: Kind
        let tag: String?
        let pattern: String?
        let sound: String?
        let rating: Int?
        let duration: TimeInterval
        let selection: Selection

        enum Kind { case focus, standaloneBreathing, breakBreathing }

        static func == (lhs: TimelineEntry, rhs: TimelineEntry) -> Bool { lhs.id == rhs.id }
    }

    private var groupedByDay: [DayGroup] {
        let cal = Calendar.current
        let cutoff = dateFilter.startDate
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()

        let focusFiltered = allFocus.filter { s in
            if let cutoff, s.startTime < cutoff { return false }
            if typeFilter == .breathing { return false }
            if q.isEmpty { return true }
            return (s.tag ?? "").lowercased().contains(q)
                || (s.note ?? "").lowercased().contains(q)
                || (s.backgroundSound ?? "").lowercased().contains(q)
        }

        let breathingFiltered = allBreathing.filter { s in
            if let cutoff, s.startTime < cutoff { return false }
            if typeFilter == .focus { return false }
            if q.isEmpty { return true }
            return s.patternName.lowercased().contains(q)
                || (s.reflectionNote ?? "").lowercased().contains(q)
                || (s.ambientSound ?? "").lowercased().contains(q)
        }

        var entriesByDay: [Date: [TimelineEntry]] = [:]
        var ratingsByDay: [Date: [Int]] = [:]

        for s in focusFiltered {
            let day = cal.startOfDay(for: s.startTime)
            let entry = TimelineEntry(
                id: s.id, start: s.startTime, end: s.endTime, kind: .focus,
                tag: s.tag, pattern: nil, sound: s.backgroundSound, rating: s.rating,
                duration: s.actualDuration, selection: .focus(s.id)
            )
            entriesByDay[day, default: []].append(entry)
            if let r = s.rating { ratingsByDay[day, default: []].append(r) }
        }
        for s in breathingFiltered {
            let day = cal.startOfDay(for: s.startTime)
            let kind: TimelineEntry.Kind = s.sessionType == .standalone ? .standaloneBreathing : .breakBreathing
            let entry = TimelineEntry(
                id: s.id, start: s.startTime, end: s.endTime, kind: kind,
                tag: nil, pattern: s.patternName, sound: s.ambientSound, rating: nil,
                duration: s.actualDuration, selection: .breathing(s.id)
            )
            entriesByDay[day, default: []].append(entry)
        }

        return entriesByDay.keys.sorted(by: >).map { day in
            let entries = (entriesByDay[day] ?? []).sorted { $0.start > $1.start }
            let focusCount = entries.filter { $0.kind == .focus }.count
            let breathingCount = entries.filter { $0.kind != .focus }.count
            let total = entries.reduce(0) { $0 + $1.duration }
            let ratings = ratingsByDay[day] ?? []
            let avg = ratings.isEmpty ? nil : Double(ratings.reduce(0, +)) / Double(ratings.count)
            return DayGroup(day: day, entries: entries, focusCount: focusCount, breathingCount: breathingCount, totalSeconds: total, avgRating: avg)
        }
    }

    // MARK: - Export

    private func exportDay(_ day: Date) {
        guard let settings = settingsRows.first else { return }
        do {
            _ = try MarkdownExporter.writeDailyReport(for: day, in: context, settings: settings)
        } catch {
            // TODO: surface error inline
            NSLog("Export failed: \(error)")
        }
    }
}
