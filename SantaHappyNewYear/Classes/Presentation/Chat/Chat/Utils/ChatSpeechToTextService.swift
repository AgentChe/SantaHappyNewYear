//
//  ChatSpeechToTextService.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

import AVFoundation
import Speech

final class ChatSpeechToTextService {
    enum State { case idle, starting, running }
    private(set) var state: State = .idle
    var isRunning: Bool { state == .running }
    var isBusy: Bool { state == .starting }

    private let queue = DispatchQueue(label: "stt.queue")
    private let audioEngine = AVAudioEngine()
    private var hasTap = false

    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer
    private var cancelPendingStart = false

    init(locale: Locale = Locale(identifier: "ru-RU")) {
        recognizer = SFSpeechRecognizer(locale: locale)!
    }

    func start(
        onPartial: ((String) -> Void)? = nil,
        onFinal: ((String) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        queue.async {
            guard self.state == .idle else { return }
            self.state = .starting
            self.cancelPendingStart = false

            SFSpeechRecognizer.requestAuthorization { status in
                self.queue.async {
                    guard self.state == .starting, !self.cancelPendingStart, status == .authorized else {
                        self.state = .idle
                        return
                    }
                    do {
                        let session = AVAudioSession.sharedInstance()
                        try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
                        try session.setActive(true, options: .notifyOthersOnDeactivation)

                        let req = SFSpeechAudioBufferRecognitionRequest()
                        req.shouldReportPartialResults = true
                        self.request = req

                        self.task = self.recognizer.recognitionTask(with: req) { result, error in
                            if let r = result {
                                onPartial?(r.bestTranscription.formattedString)
                                if r.isFinal {
                                    onFinal?(r.bestTranscription.formattedString)
                                    self.stop()
                                }
                            } else if let e = error {
                                onError?(e); self.stop()
                            }
                        }

                        let input = self.audioEngine.inputNode
                        let format = input.outputFormat(forBus: 0)
                        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                            self?.request?.append(buffer)
                        }
                        self.hasTap = true

                        self.audioEngine.prepare()
                        try self.audioEngine.start()
                        self.state = .running
                    } catch {
                        self.cleanup()
                        self.state = .idle
                        onError?(error)
                    }
                }
            }
        }
    }

    func stop() {
        queue.async {
            switch self.state {
            case .starting:
                self.cancelPendingStart = true
                self.cleanup()
                self.state = .idle
            case .running:
                self.cleanup()
                self.state = .idle
            case .idle:
                break
            }
        }
    }

    private func cleanup() {
        if hasTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasTap = false
        }
        audioEngine.stop()
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
