import SwiftUI
import SwiftData

/// Presented when a focus session finishes naturally. Captures rating + reflection note,
/// and optionally chains into a breathing break.
struct FocusCompleteSheet: View {

    @Bindable var session: FocusSession
    var onDismiss: (_ startBreak: Bool) -> Void

    @State private var rating: Int = 7
    @State private var note: String = ""

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query private var settingsRows: [AppSettings]

    private var ratingLabel: String {
        switch rating {
        case 1...3: "Poor focus"
        case 4...6: "Moderate focus"
        case 7...8: "Good focus"
        default:    "Excellent focus"
        }
    }

    private var settings: AppSettings? { settingsRows.first }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Space.s5) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("FOCUS COMPLETE")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Palette.inkMuted)
                Text(session.tag ?? "Focus session")
                    .font(Theme.Typography.h1)
                    .foregroundStyle(Theme.Palette.ink)
                Text("\(TimeFormatting.humanDuration(session.actualDuration)) · \(TimeFormatting.range(session.startTime, session.endTime))")
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Palette.inkMuted)
            }

            // Rating
            VStack(alignment: .leading, spacing: Theme.Space.s3) {
                FieldLabel(text: "How well did you focus?")
                HStack(spacing: 6) {
                    ForEach(1...10, id: \.self) { value in
                        Button { rating = value } label: {
                            ZStack {
                                Circle()
                                    .fill(value <= rating ? Theme.Palette.burgundy : Theme.Palette.surface2)
                                Circle()
                                    .strokeBorder(value <= rating ? Color.clear : Theme.Palette.border, lineWidth: 1)
                                Text("\(value)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(value <= rating ? .white : Theme.Palette.inkMuted)
                            }
                            .frame(width: 30, height: 30)
                        }
                        .buttonStyle(.plain)
                    }
                }
                HStack {
                    Text("\(rating)/10")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.Palette.burgundy)
                    Text("·")
                        .foregroundStyle(Theme.Palette.inkSoft)
                    Text(ratingLabel)
                        .font(Theme.Typography.small)
                        .foregroundStyle(Theme.Palette.inkMuted)
                }
            }

            // Note
            VStack(alignment: .leading, spacing: Theme.Space.s2) {
                FieldLabel(text: "Reflection (optional)")
                TextEditor(text: $note)
                    .font(Theme.Typography.body)
                    .frame(minHeight: 80, maxHeight: 120)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(Theme.Palette.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.md)
                            .strokeBorder(Theme.Palette.border, lineWidth: 1)
                    )
            }

            // Actions
            HStack(spacing: Theme.Space.s3) {
                Button("Skip break") {
                    commit()
                    onDismiss(false)
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Spacer()

                PrimaryActionButton(
                    label: "Save & start break",
                    icon: "wind",
                    tone: .breath
                ) {
                    commit()
                    onDismiss(true)
                    dismiss()
                }
            }
        }
        .padding(Theme.Space.s7)
        .frame(width: 480)
        .background(Theme.Palette.bg)
    }

    private func commit() {
        session.rating = rating
        session.note = note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note
        try? context.save()
    }
}
