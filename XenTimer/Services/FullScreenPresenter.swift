import Foundation
import Observation

/// Coordinates opening/closing of the full-screen breathing window.
/// Views observe this and call SwiftUI's openWindow / dismissWindow in response.
@Observable
final class FullScreenPresenter {
    /// Incremented when a caller requests the full-screen window to open.
    private(set) var openRequestTick: Int = 0
    /// Incremented when a caller requests the full-screen window to close.
    private(set) var closeRequestTick: Int = 0

    func requestOpen() { openRequestTick &+= 1 }
    func requestClose() { closeRequestTick &+= 1 }
}
