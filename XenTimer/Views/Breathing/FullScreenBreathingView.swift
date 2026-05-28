import SwiftUI
import SwiftData

struct FullScreenBreathingView: View {

    @Environment(BreathingController.self) private var breathing
    @Environment(AudioService.self) private var audio
    @Environment(TimerService.self) private var timer
    @Environment(FullScreenPresenter.self) private var presenter
    @Environment(\.dismiss) private var dismiss

    @Query private var settingsRows: [AppSettings]

    @State private var animatedScale: CGFloat = 0.55
    @State private var displayPhase: BreathingPhase = .inhale

    private var settings: AppSettings? { settingsRows.first }

    var body: some View {
        ZStack {
            BreathingBackground(phase: displayPhase)

            VStack(spacing: Theme.Space.s7) {
                Text(displayPhase.displayLabel.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .tracking(2.4)
                    .foregroundStyle(.white.opacity(0.5))
                    .transition(.opacity)
                    .id("eyebrow-\(displayPhase.rawValue)")

                BreathingCircle(scale: animatedScale)
                    .frame(width: 320, height: 320)

                Text(displayPhase.displayLabel)
                    .font(.system(size: 36, weight: .ultraLight))
                    .foregroundStyle(.white)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .id("label-\(displayPhase.rawValue)")

                Text(phaseProgressText)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(1)
            }

            // Top strip
            VStack {
                HStack {
                    if !breathing.patternName.isEmpty {
                        Text("\(breathing.patternName) · \(breathing.patternDescription)")
                    }
                    Spacer()
                    if breathing.totalCycles > 0 {
                        Text("Cycle \(breathing.cycleNumber) of \(breathing.totalCycles)")
                    }
                }
                .font(.system(size: 12))
                .tracking(0.5)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, Theme.Space.s7)
                .padding(.top, Theme.Space.s6)
                Spacer()
            }

            // Bottom strip
            VStack {
                Spacer()
                HStack {
                    Text(bottomCaption)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Button { endSession() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10))
                            Text("End session · esc")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.08)))
                        .overlay(Capsule().strokeBorder(.white.opacity(0.14), lineWidth: 1))
                        .foregroundStyle(.white.opacity(0.75))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.escape, modifiers: [])
                }
                .padding(.horizontal, Theme.Space.s7)
                .padding(.bottom, Theme.Space.s6)
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(.black.opacity(0.05))
        .onAppear { syncFromController() }
        .onChange(of: breathing.phaseTick) { _, _ in syncFromController() }
        .onChange(of: breathing.isActive) { _, isActive in
            if !isActive { dismiss() }
        }
        .onChange(of: presenter.closeRequestTick) { _, _ in dismiss() }
    }

    // MARK: - Bits

    private var phaseProgressText: String {
        let remainingSeconds = max(0, breathing.phaseDuration - (breathing.phaseDuration * (1 - (1 - breathing.phaseProgress))))
        if breathing.phaseDuration <= 0 { return "" }
        let value = max(0, breathing.phaseDuration * (1 - breathing.phaseProgress))
        return String(format: "%.1fs", value)
    }

    private var bottomCaption: String {
        var parts: [String] = []
        parts.append("Remaining \(TimeFormatting.clock(breathing.remaining))")
        if let sound = breathing.ambientSound, sound != "Silence" {
            parts.append("Ambient \(sound)")
        }
        return parts.joined(separator: " · ")
    }

    private func syncFromController() {
        let newPhase = breathing.currentPhase
        let duration = breathing.phaseDuration
        let target = breathing.targetScale

        // Play guide
        if let guide = settings?.defaultBreathingGuide {
            audio.playBreathingGuide(newPhase, mode: guide)
        }

        withAnimation(.easeInOut(duration: duration > 0 ? duration : 0.2)) {
            animatedScale = target
        }
        withAnimation(.easeInOut(duration: 0.4)) {
            displayPhase = newPhase
        }
    }

    private func endSession() {
        // Commit session if it was meaningful — though typically breathing is committed
        // by ActiveSessionView when timer finishes. Here we just stop and dismiss.
        breathing.stop()
        audio.fadeOutAmbient()
        timer.stop()
        presenter.requestClose()
        dismiss()
    }
}

// MARK: - Background

private struct BreathingBackground: View {
    let phase: BreathingPhase

    var body: some View {
        let baseColors: [Color] = [
            Color(red: 52/255, green: 73/255, blue: 95/255),
            Color(red: 27/255, green: 41/255, blue: 57/255),
            Color(red: 14/255, green: 23/255, blue: 34/255)
        ]
        let liftedColors: [Color] = [
            Color(red: 60/255, green: 80/255, blue: 100/255),
            Color(red: 30/255, green: 45/255, blue: 62/255),
            Color(red: 16/255, green: 26/255, blue: 36/255)
        ]

        RadialGradient(
            colors: phase.atFullSize ? liftedColors : baseColors,
            center: .center,
            startRadius: 80,
            endRadius: 900
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: phase)
    }
}

// MARK: - Circle

private struct BreathingCircle: View {
    let scale: CGFloat

    var body: some View {
        ZStack {
            // Outer faint ring
            Circle()
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                .scaleEffect(1.18)
            // Mid ring
            Circle()
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                .scaleEffect(1.06)

            // The breathing orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.42),
                            Color(red: 108/255, green: 128/255, blue: 152/255).opacity(0.58),
                            Color(red: 46/255, green: 66/255, blue: 89/255).opacity(0.85)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 6,
                        endRadius: 220
                    )
                )
                .scaleEffect(scale)
                .shadow(color: .white.opacity(0.25), radius: 70)
        }
    }
}
