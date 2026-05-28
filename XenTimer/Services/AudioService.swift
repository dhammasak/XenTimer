import Foundation
import AVFoundation
import AppKit
import Observation

/// Plays ambient backgrounds, voice/bell guidance, and other audio.
/// MVP: speaks via AVSpeechSynthesizer and plays system sounds.
/// Ambient sound playback hooks are present but currently silent until sound files ship.
@Observable
final class AudioService {

    var volume: Float = 0.6 {
        didSet { ambientPlayer?.volume = volume }
    }

    private var ambientPlayer: AVAudioPlayer?
    private let synthesizer = AVSpeechSynthesizer()

    // MARK: - Ambient

    /// Plays a named ambient sound. "Silence" is a no-op.
    /// MVP: this is a no-op for non-silence values too (no shipped sound files yet),
    /// but the API is here so views can wire to it.
    func playAmbient(_ name: String?) {
        stopAmbient()
        guard let name, !name.isEmpty, name.lowercased() != "silence" else { return }
        // Future: resolve a bundled .m4a, create AVAudioPlayer with .loops, fade in.
    }

    func stopAmbient() {
        ambientPlayer?.stop()
        ambientPlayer = nil
    }

    func fadeOutAmbient(duration: TimeInterval = 0.6) {
        guard let player = ambientPlayer else { return }
        let steps = 20
        let initial = player.volume
        let interval = duration / Double(steps)
        for step in 0...steps {
            let when = DispatchTime.now() + interval * Double(step)
            DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
                guard let self else { return }
                self.ambientPlayer?.volume = initial * Float(1.0 - Double(step) / Double(steps))
                if step == steps {
                    self.stopAmbient()
                    self.ambientPlayer?.volume = self.volume
                }
            }
        }
    }

    // MARK: - Voice guide

    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.42
        utterance.pitchMultiplier = 0.95
        utterance.volume = volume
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - Bell / system sounds

    /// Soft chime to mark a phase change.
    func playBell() {
        NSSound(named: NSSound.Name("Tink"))?.play()
    }

    /// Gentle completion chime for end of session.
    func playCompletion() {
        NSSound(named: NSSound.Name("Glass"))?.play()
    }

    // MARK: - Breathing phase guide

    /// Plays the appropriate guide cue at the start of a breathing phase.
    func playBreathingGuide(_ phase: BreathingPhase, mode: BreathingGuideMode) {
        switch mode {
        case .voice:
            speak(phase.displayLabel)
        case .bell:
            playBell()
        case .visualOnly, .silent:
            return
        }
    }
}
