import Foundation
import AppKit
import SwiftData

enum MarkdownExporter {

    enum ExportError: Error, LocalizedError {
        case noFolderSelected
        case bookmarkStale
        case writeFailed(underlying: Error)

        var errorDescription: String? {
            switch self {
            case .noFolderSelected: "Choose an export folder in Settings first."
            case .bookmarkStale:    "Export folder is no longer accessible — choose it again."
            case .writeFailed(let e): "Failed to write report: \(e.localizedDescription)"
            }
        }
    }

    // MARK: - File naming

    static func filename(for day: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return "XenTimer Daily Report - \(f.string(from: day)).md"
    }

    // MARK: - Markdown rendering

    static func renderMarkdown(
        for stats: DailyAggregator.DailyStats,
        includeReflectionPrompts: Bool
    ) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: stats.date)

        let weekday: String = {
            let f = DateFormatter()
            f.dateFormat = "EEEE, MMM d, yyyy"
            return f.string(from: stats.date)
        }()

        let totalBreathingSessions = stats.breathingSessions.count
        let ratingString = stats.averageRating.map { String(format: "%.1f", $0) } ?? "—"

        var out = ""
        out += "# XenTimer Daily Report — \(dateString)\n\n"
        out += "_\(weekday)_\n\n"
        out += "## Daily Summary\n\n"
        out += "- Completed Focus Sessions: \(stats.focusCompleted)\n"
        out += "- Total Focus Time: \(TimeFormatting.humanDuration(stats.totalFocusTime))\n"
        out += "- Total Break Time: \(TimeFormatting.humanDuration(stats.totalBreakTime))\n"
        out += "- Standalone Breathing Sessions: \(stats.standaloneBreathingCount)\n"
        out += "- Total Breathing Practice Time: \(TimeFormatting.humanDuration(stats.totalBreathingTime))\n"
        out += "- Average Focus Rating: \(ratingString)/10\n"
        out += "- Most Used Breathing Pattern: \(stats.mostUsedBreathingPattern ?? "—")\n"
        out += "- Most Used Focus Tag: \(stats.mostUsedTag ?? "—")\n"
        out += "\n"

        // Session log table — unified across focus + breathing rows.
        out += "## Session Log\n\n"
        if stats.focusSessions.isEmpty && stats.breathingSessions.isEmpty {
            out += "_No sessions recorded._\n\n"
        } else {
            out += "| No. | Time | Type | Duration | Tag | Pattern | Rating | Note |\n"
            out += "|---:|---|---|---:|---|---|---:|---|\n"

            struct Row { let date: Date; let line: String }
            var rows: [Row] = []

            for session in stats.focusSessions {
                let time = TimeFormatting.range(session.startTime, session.endTime)
                let dur  = TimeFormatting.humanDuration(session.actualDuration)
                let rating = session.rating.map { "\($0)" } ?? "—"
                let note = (session.note ?? "").replacingOccurrences(of: "|", with: "\\|")
                let line = "| {N} | \(time) | Focus | \(dur) | \(session.tag ?? "—") | — | \(rating) | \(note) |"
                rows.append(Row(date: session.startTime, line: line))
            }
            for session in stats.breathingSessions {
                let time = TimeFormatting.range(session.startTime, session.endTime)
                let dur  = TimeFormatting.humanDuration(session.actualDuration)
                let pattern = session.patternName.isEmpty ? "—" : session.patternName
                let note = (session.reflectionNote ?? "").replacingOccurrences(of: "|", with: "\\|")
                let typeLabel = session.sessionType == .standalone ? "Breathing" : "Recovery"
                let line = "| {N} | \(time) | \(typeLabel) | \(dur) | — | \(pattern) | — | \(note) |"
                rows.append(Row(date: session.startTime, line: line))
            }

            let ordered = rows.sorted { $0.date < $1.date }
            for (idx, row) in ordered.enumerated() {
                out += row.line.replacingOccurrences(of: "{N}", with: "\(idx + 1)") + "\n"
            }
            out += "\n"
        }

        if includeReflectionPrompts {
            out += "## Reflection\n\n"
            out += "### What went well today?\n\n- \n\n"
            out += "### What interrupted my focus?\n\n- \n\n"
            out += "### What should I improve tomorrow?\n\n- \n\n"
        }

        out += "## Tags\n\n"
        out += "#XenTimer #Pomodoro #Productivity #Recovery #Breathing\n"
        return out
    }

    // MARK: - Folder picker

    /// Shows an open panel for folder selection. Returns a security-scoped bookmark
    /// + the chosen URL on success.
    @MainActor
    static func chooseFolder() -> (bookmark: Data, url: URL)? {
        let panel = NSOpenPanel()
        panel.title = "Choose XenTimer Markdown Export Folder"
        panel.message = "Daily Markdown reports will be written to this folder."
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "Choose"

        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        do {
            let data = try url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            return (data, url)
        } catch {
            return nil
        }
    }

    // MARK: - Write

    /// Writes the daily report for `day` using the configured folder.
    /// Returns the URL of the written file.
    @discardableResult
    static func writeDailyReport(
        for day: Date,
        in context: ModelContext,
        settings: AppSettings
    ) throws -> URL {
        let stats = try DailyAggregator.stats(for: day, context: context)
        let markdown = renderMarkdown(for: stats, includeReflectionPrompts: settings.includeReflectionPrompts)

        guard let bookmark = settings.markdownExportBookmark else {
            throw ExportError.noFolderSelected
        }

        var stale = false
        let folder: URL
        do {
            folder = try URL(
                resolvingBookmarkData: bookmark,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &stale
            )
        } catch {
            throw ExportError.bookmarkStale
        }
        if stale { throw ExportError.bookmarkStale }

        let didStart = folder.startAccessingSecurityScopedResource()
        defer { if didStart { folder.stopAccessingSecurityScopedResource() } }

        let file = folder.appendingPathComponent(filename(for: day))
        do {
            try markdown.data(using: .utf8)?.write(to: file, options: [.atomic])
        } catch {
            throw ExportError.writeFailed(underlying: error)
        }
        return file
    }
}
