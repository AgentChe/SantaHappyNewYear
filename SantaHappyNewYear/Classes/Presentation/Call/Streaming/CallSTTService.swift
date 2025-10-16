//
//  CallSTTService.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 10.10.2025.
//

import AVFoundation
import Speech

final class CallSTTService {
    struct Endpointing {
        var startDb: Float = -45      // порог начала речи (RMS dBFS)
        var continueDb: Float = -48   // порог продолжения
        var endSilenceMs: Int = 650   // длительность тишины для окончания
        var maxUtteranceMs: Int = 10000
    }

    enum State { case idle, listening }
    enum Err: Error { case notAuthorized, busy }

    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru_RU")) // TODO: en_EN
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    private(set) var state: State = .idle
    private let cfg = Endpointing()

    private var lastText = ""
    private var hasSpeech = false
    private var speechStartAt: TimeInterval = 0
    private var lastVoiceAt: TimeInterval = 0
    private var finishing = false

    func start(onFinal: @escaping (String) -> Void) throws {
        guard state == .idle else { throw Err.busy }

        // Разрешения
        if SFSpeechRecognizer.authorizationStatus() == .notDetermined {
            let sema = DispatchSemaphore(value: 1)
            SFSpeechRecognizer.requestAuthorization { _ in sema.signal() }
            sema.wait()
        }
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else { throw Err.notAuthorized }

        // Сессия
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)

        // Сброс
        finishing = false
        lastText = ""
        hasSpeech = false
        speechStartAt = CACurrentMediaTime()
        lastVoiceAt = speechStartAt

        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let self = self, let req = self.request else { return }
            req.append(buffer)

            // VAD
            let now = CACurrentMediaTime()
            let db = buffer.rmsDbFS()
            if db > (self.hasSpeech ? self.cfg.continueDb : self.cfg.startDb) {
                if !self.hasSpeech {
                    self.hasSpeech = true
                    self.speechStartAt = now
                }
                self.lastVoiceAt = now
            }

            if self.hasSpeech {
                let silenceMs = Int((now - self.lastVoiceAt) * 1000)
                let lenMs = Int((now - self.speechStartAt) * 1000)
                if silenceMs >= self.cfg.endSilenceMs || lenMs >= self.cfg.maxUtteranceMs {
                    self.finishStream()
                }
            }
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer?.recognitionTask(with: request!) { [weak self] result, error in
            guard let self else { return }
            if let r = result {
                self.lastText = r.bestTranscription.formattedString
            }
            if error != nil || result?.isFinal == true || self.finishing {
                let text = self.lastText.trimmingCharacters(in: .whitespacesAndNewlines)
                self.cleanup()
                if !text.isEmpty { onFinal(text) }
            }
        }

        state = .listening
    }

    func cancel() { // прерываем без результата
        cleanup()
    }

    @inline(__always)
    private func finishStream() {
        guard !finishing else { return }
        finishing = true
        request?.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }

    private func cleanup() {
        finishing = true
        request?.endAudio()
        task?.cancel()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request = nil
        task = nil
        state = .idle
    }
}

private extension AVAudioPCMBuffer {
    func rmsDbFS() -> Float {
        guard let ch = floatChannelData else { return -120 }
        let n = Int(frameLength)
        if n == 0 { return -120 }
        var sum: Float = 0
        let ptr = ch[0]
        var i = 0
        while i < n {
            let s = ptr[i]
            sum += s * s
            i += 1
        }
        let rms = sqrtf(sum / Float(n))
        if rms <= 1e-7 { return -120 }
        return 20 * log10f(rms) // 0 dBFS = full scale
    }
}
