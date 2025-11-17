//
//  AudioCallViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 06.10.2025.
//

import UIKit
import RxSwift

final class AudioCallViewController: UIViewController {
    enum CallDirection {
        case incoming, outgoing
    }
    
    deinit {
        RingtonePlayer.shared.stop()
        webSocketService.disconnect()
        streamingAudioPlayer.stop()
        callSTTService.cancel()
    }
    
    private let mainView: AudioCallView
    
    private let viewModel: AudioCallViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var webSocketService = CallWebSocketService()
    private lazy var streamingAudioPlayer = StreamingAudioPlayer()
    private lazy var callSTTService = CallSTTService()
    
    private init(callDirection: CallDirection) {
        mainView = AudioCallView(callDirection: callDirection)
        viewModel = AudioCallViewModel(callDirection: callDirection)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webSocketService.agentState
            .emit(to: Binder(self) { base, agentState in
                switch agentState {
                case .listening:
                    base.handleListeningState()
                case .speaking:
                    base.handleSpeakingState()
                }
            })
            .disposed(by: disposeBag)
        
        webSocketService.agentState
            .filter { $0 == .listening }
            .asObservable()
            .take(1)
            .bind(to: Binder(webSocketService) { base, _ in
                base.send(message: "Hello Santa! I'm ready to listen to your greeting message!", status: "start")
            })
            .disposed(by: disposeBag)
        
        webSocketService.audioChunks
            .emit(to: Binder(streamingAudioPlayer) { base, audioChunks in
                base.enqueue(audioChunks)
            })
            .disposed(by: disposeBag)
        
        let output = viewModel.configure(input: AudioCallViewModel.Input(
            didTapReject: mainView.rejectButton.rx.tap.asSignal(),
            didTapAccept: mainView.acceptButton?.rx.tap.asSignal() ?? .never()
        ))
        
        output.audioViewCallPhase
            .drive(Binder(mainView) { base, callPhase in
                base.setup(callPhase: callPhase)
            })
            .disposed(by: disposeBag)
        
        output.audioViewCallUIState
            .drive(Binder(mainView) { base, callUIState in
                base.setup(callUIState: callUIState)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension AudioCallViewController {
    static func make(callDirection: CallDirection) -> AudioCallViewController {
        let vc = AudioCallViewController(callDirection: callDirection)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension AudioCallViewController {
    func action(_ action: AudioCallViewModel.Action) {
        switch action {
        case .cancelCall:
            webSocketService.disconnect()
            streamingAudioPlayer.stop()
            
            dismiss(animated: false)
        case .playRingtone(let callDirection):
            RingtonePlayer.shared.play(callDirection)
        case .stopRingtone:
            RingtonePlayer.shared.stop()
        case .connect:
            webSocketService.connect()
        }
    }
    
    func handleSpeakingState() {
        callSTTService.cancel()
        streamingAudioPlayer.start()
        mainView.canSpeakView.isHidden = true
    }

    func handleListeningState() {
        let switchToListening: () -> Void = { [weak self] in
            guard let self else { return }
            
            streamingAudioPlayer.stop()
            try? callSTTService.start { [weak self] text in
                self?.webSocketService.send(message: text)
            }
            mainView.canSpeakView.isHidden = false
        }

        if streamingAudioPlayer.hasPendingAudio {
            streamingAudioPlayer.waitUntilQueueIsEmpty {
                switchToListening()
            }
        } else {
            switchToListening()
        }
    }
}
