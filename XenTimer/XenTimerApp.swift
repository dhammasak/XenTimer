import SwiftUI
import SwiftData

@main
struct XenTimerApp: App {

    // MARK: - Persistent store

    let modelContainer: ModelContainer = {
        let schema = Schema([
            FocusSession.self,
            BreathingSession.self,
            BreathingPattern.self,
            AppSettings.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            SeedData.ensureSeeded(in: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    // MARK: - Services

    @State private var timerService = TimerService()
    @State private var breathingController = BreathingController()
    @State private var audioService = AudioService()
    @State private var notificationService = NotificationService()
    @State private var fullScreenPresenter = FullScreenPresenter()

    // MARK: - Scenes

    var body: some Scene {

        // Main app window
        WindowGroup("XenTimer", id: WindowID.main) {
            MainWindowView()
                .environment(timerService)
                .environment(breathingController)
                .environment(audioService)
                .environment(notificationService)
                .environment(fullScreenPresenter)
                .frame(minWidth: 720, idealWidth: 720, maxWidth: 920, minHeight: 560)
                .background(Theme.Palette.bg)
                .task {
                    await notificationService.requestAuthorizationIfNeeded()
                }
        }
        .modelContainer(modelContainer)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About XenTimer") {}
            }
            CommandMenu("Session") {
                Button("Start Focus") {}
                    .keyboardShortcut("f", modifiers: [.command, .shift])
                Button("Start Breathing") {}
                    .keyboardShortcut("b", modifiers: [.command, .shift])
                Divider()
                Button("Pause / Resume") {
                    timerService.togglePause()
                }
                .keyboardShortcut(.space, modifiers: [.command])
                Button("End Session") {
                    timerService.stop()
                }
                .keyboardShortcut(.escape, modifiers: [.command])
            }
            CommandGroup(after: .windowList) {
                Button("Dashboard") {}
                    .keyboardShortcut("1", modifiers: .command)
                Button("History") {}
                    .keyboardShortcut("2", modifiers: .command)
            }
        }

        // Menu bar item
        MenuBarExtra {
            MenuBarContentView()
                .environment(timerService)
                .environment(breathingController)
                .environment(fullScreenPresenter)
                .modelContainer(modelContainer)
        } label: {
            MenuBarLabelView()
                .environment(timerService)
                .environment(breathingController)
        }
        .menuBarExtraStyle(.window)

        // Full-screen breathing window
        Window("Breathing", id: WindowID.fullScreenBreathing) {
            FullScreenBreathingView()
                .environment(breathingController)
                .environment(audioService)
                .environment(fullScreenPresenter)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        // Preferences window
        Settings {
            SettingsView()
                .environment(audioService)
                .modelContainer(modelContainer)
                .frame(minWidth: 720, minHeight: 520)
        }
    }
}

enum WindowID {
    static let main = "main"
    static let fullScreenBreathing = "breathing-fullscreen"
}
