//
//  ChatSpeechToTextService.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

import AVFoundation
import Speech

public final class ChatSpeechToTextService: NSObject {
    public enum STTError: Error {
        case notAuthorized
        case recognizerUnavailable
        case alreadyRunning
        case notRunning
        case noResult
    }

    private let audioEngine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var onFinal: ((Result<String, Error>) -> Void)?
    private var partialHandler: ((String) -> Void)?
    private var bestFinal: String = ""
    private var isRunning = false
    private let requiresOnDevice: Bool

    override init() {
        self.recognizer = SFSpeechRecognizer(locale: Locale.current)!
        self.requiresOnDevice = false
        
        super.init()
    }

    // Разрешения один раз перед стартом
    public func preparePermissions(completion: @escaping (Result<Void, Error>) -> Void) {
        AVAudioApplication.requestRecordPermission { micOK in
            guard micOK else { completion(.failure(STTError.notAuthorized)); return }
            SFSpeechRecognizer.requestAuthorization { auth in
                switch auth {
                case .authorized: completion(.success(()))
                default: completion(.failure(STTError.notAuthorized))
                }
            }
        }
    }

    // Начать запись по touchDown
    public func begin(onPartial: ((String) -> Void)? = nil) throws {
        guard !isRunning else { throw STTError.alreadyRunning }
        guard recognizer.isAvailable else { throw STTError.recognizerUnavailable }
        isRunning = true
        partialHandler = onPartial
        bestFinal = ""

        try configureAudioSession()
        try startEngineAndTask()
    }

    // Завершить по touchUp и вернуть финальный текст
    public func end(completion: @escaping (Result<String, Error>) -> Void) throws {
        guard isRunning else { throw STTError.notRunning }
        onFinal = completion

        request?.endAudio()
        stopEngineInputTap()

        // Если Apple уже прислал финал — вернем сразу при завершении task handler’ом.
        // На всякий случай даем короткий таймаут и возвращаем лучшее из имеющегося.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            if self.isRunning == false { return } // уже завершили в handler’е
            self.finish(returning: self.bestFinal.isEmpty ? .failure(STTError.noResult)
                                                          : .success(self.bestFinal))
        }
    }

    // Прервать без результата
    public func cancel() {
        cleanup()
        onFinal?(.failure(NSError(domain: "stt.cancelled", code: -1)))
        onFinal = nil
    }

    // MARK: - Internals

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.duckOthers, .allowBluetooth, .allowBluetoothA2DP])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startEngineAndTask() throws {
        let input = audioEngine.inputNode
        let format = input.inputFormat(forBus: 0)

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        if #available(iOS 13, *) { req.requiresOnDeviceRecognition = requiresOnDevice }
        request = req

        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] (buffer, _) in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            guard let self else { return }

            if let result = result {
                let text = result.bestTranscription.formattedString
                if result.isFinal {
                    self.bestFinal = text
                } else {
                    self.partialHandler?(text)
                }
            }

            if let error = error {
                self.finish(returning: .failure(error))
                return
            }

            if let result = result, result.isFinal {
                self.finish(returning: .success(self.bestFinal))
            }
        }
    }

    private func stopEngineInputTap() {
        if audioEngine.isRunning { audioEngine.stop() }
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
    }

    private func finish(returning result: Result<String, Error>) {
        cleanup()
        onFinal?(result)
        onFinal = nil
    }

    private func cleanup() {
        isRunning = false
        stopEngineInputTap()
        task?.cancel()
        task = nil
        request = nil
        partialHandler = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch { /* ignore */ }
    }

    deinit { cleanup() }
}
