import Foundation
import UserNotifications
import Observation

@Observable
final class NotificationService {

    private(set) var isAuthorized: Bool = false

    enum Kind: String {
        case focusCompleted
        case breakStarted
        case breakCompleted
        case breathingCompleted
        case dailyGoalCompleted
    }

    func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        do {
            let settings = await center.notificationSettings()
            switch settings.authorizationStatus {
            case .notDetermined:
                let granted = try await center.requestAuthorization(options: [.alert, .sound])
                isAuthorized = granted
            case .authorized, .provisional, .ephemeral:
                isAuthorized = true
            default:
                isAuthorized = false
            }
        } catch {
            isAuthorized = false
        }
    }

    func notify(_ kind: Kind, title: String, body: String) {
        guard isAuthorized else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.threadIdentifier = "xentimer.\(kind.rawValue)"

        let request = UNNotificationRequest(
            identifier: "xentimer.\(kind.rawValue).\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Convenience

    func focusCompleted(label: String?) {
        let detail = label.map { "“\($0)” session complete" } ?? "Session complete"
        notify(.focusCompleted, title: "Focus done — take a breath", body: detail)
    }

    func breakStarted(patternName: String) {
        notify(.breakStarted, title: "Recovery break", body: "Following \(patternName)")
    }

    func breakCompleted() {
        notify(.breakCompleted, title: "Break complete", body: "Ready when you are.")
    }

    func breathingCompleted(patternName: String) {
        notify(.breathingCompleted, title: "Breathing session complete", body: "\(patternName) — well done.")
    }

    func dailyGoalCompleted(sessions: Int) {
        notify(.dailyGoalCompleted, title: "Daily goal reached", body: "\(sessions) focus sessions today.")
    }
}
