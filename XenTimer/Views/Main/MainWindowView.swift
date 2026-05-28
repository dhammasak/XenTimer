import SwiftUI
import SwiftData

enum AppPage: String, CaseIterable, Identifiable {
    case timer, dashboard, history
    var id: String { rawValue }
}

struct MainWindowView: View {

    @State private var page: AppPage = .timer
    @State private var mode: ModeTabsView.Mode = .focus

    @Environment(TimerService.self) private var timer
    @Environment(BreathingController.self) private var breathing
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 0) {
            // Custom title bar replacement
            TopToolbar(page: $page, mode: $mode)
                .padding(.horizontal, Theme.Space.s7)
                .padding(.top, Theme.Space.s5)
                .padding(.bottom, Theme.Space.s4)

            Divider().background(Theme.Palette.border)

            Group {
                switch page {
                case .timer:
                    TimerPageContainer(mode: $mode)
                case .dashboard:
                    DashboardView()
                case .history:
                    HistoryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Theme.Palette.bg)
    }
}

private struct TopToolbar: View {
    @Binding var page: AppPage
    @Binding var mode: ModeTabsView.Mode
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        HStack {
            if page == .timer {
                ModeTabsView(selection: $mode)
            } else {
                Text(title(for: page))
                    .font(Theme.Typography.h2)
                    .foregroundStyle(Theme.Palette.ink)
            }
            Spacer()
            HStack(spacing: Theme.Space.s1) {
                IconButton(systemName: "timer", help: "Timer", isActive: page == .timer) {
                    page = .timer
                }
                IconButton(systemName: "square.grid.2x2", help: "Dashboard", isActive: page == .dashboard) {
                    page = .dashboard
                }
                IconButton(systemName: "clock.arrow.circlepath", help: "History", isActive: page == .history) {
                    page = .history
                }
                IconButton(systemName: "gearshape", help: "Settings") {
                    openSettings()
                }
            }
        }
    }

    private func title(for page: AppPage) -> String {
        switch page {
        case .timer:     "Timer"
        case .dashboard: "Dashboard"
        case .history:   "History"
        }
    }
}

private struct TimerPageContainer: View {
    @Binding var mode: ModeTabsView.Mode
    @Environment(TimerService.self) private var timer

    var body: some View {
        Group {
            if timer.isActive {
                ActiveSessionView()
            } else {
                switch mode {
                case .focus:     FocusTabView()
                case .breathing: BreathingTabView()
                }
            }
        }
        .padding(.horizontal, Theme.Space.s7)
        .padding(.vertical, Theme.Space.s6)
    }
}
