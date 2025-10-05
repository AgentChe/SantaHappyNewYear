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
        case cancelled
    }
    
    deinit {
        cleanup()
    }

    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    
    private var onFinal: ((Result<String, Error>) -> Void)?
    private var partialHandler: ((String) -> Void)?
    private var bestFinal: String = ""
    private var isRunning = false
}

// MARK: Public
extension ChatSpeechToTextService {
    func preparePermissions(completion: @escaping (Result<Void, Error>) -> Void) {
        AVAudioApplication.requestRecordPermission { micOK in
            if micOK {
                SFSpeechRecognizer.requestAuthorization { auth in
                    switch auth {
                    case .authorized:
                        completion(.success(()))
                    default:
                        completion(.failure(STTError.notAuthorized))
                    }
                }
            } else {
                completion(.failure(STTError.notAuthorized))
            }
        }
    }

    func begin(onPartial: ((String) -> Void)? = nil) throws {
        guard !isRunning else { throw STTError.alreadyRunning }
        
        guard recognizer.isAvailable else { throw STTError.recognizerUnavailable }
        
        isRunning = true
        partialHandler = onPartial
        bestFinal = ""

        try configureAudioSession()
        try startEngineAndTask()
    }

    func end(completion: @escaping (Result<String, Error>) -> Void) throws {
        guard isRunning else { throw STTError.notRunning }
        
        onFinal = completion

        request?.endAudio()
        stopEngineInputTap()

        // Если Apple уже прислал финал — вернем сразу при завершении task handler’ом.
        // На всякий случай даем короткий таймаут и возвращаем лучшее из имеющегося.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            
            if self.isRunning == false { return }
            
            self.finish(returning: self.bestFinal.isEmpty ? .failure(STTError.noResult) : .success(self.bestFinal))
        }
    }

    func cancel() {
        cleanup()
        
        onFinal?(.failure(STTError.cancelled))
        onFinal = nil
    }
}

// MARK: Private
private extension ChatSpeechToTextService {
    func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    func startEngineAndTask() throws {
        let input = audioEngine.inputNode
        let format = input.inputFormat(forBus: 0)

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        req.requiresOnDeviceRecognition = false
        request = req

        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 2048, format: format) { [weak self] (buffer, _) in
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

    func stopEngineInputTap() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
    }

    func finish(returning result: Result<String, Error>) {
        cleanup()
        onFinal?(result)
        onFinal = nil
    }

    func cleanup() {
        isRunning = false
        stopEngineInputTap()
        task?.cancel()
        task = nil
        request = nil
        partialHandler = nil
        
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
