//
//  VideoCallViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 08.10.2025.
//

import UIKit
import RxSwift

final class VideoCallViewController: UIViewController {
    enum CallDirection {
        case incoming, outgoing
    }
    
    deinit {
        RingtonePlayer.shared.stop()
        webSocketService.disconnect()
        streamingAudioPlayer.stop()
        callSTTService.cancel()
    }
    
    private lazy var webSocketService = CallWebSocketService()
    private lazy var streamingAudioPlayer = StreamingAudioPlayer()
    private lazy var callSTTService = CallSTTService()
    
    private let mainView: VideoCallView
    
    private let viewModel: VideoCallViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private init(callDirection: CallDirection) {
        mainView = VideoCallView(callDirection: callDirection)
        viewModel = VideoCallViewModel(callDirection: callDirection)
        
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
        
        let output = viewModel.configure(input: VideoCallViewModel.Input(
            didTapReject: mainView.rejectButton.rx.tap.asSignal(),
            didTapAccept: mainView.acceptButton?.rx.tap.asSignal() ?? .never()
        ))
        
        output.videoViewCallPhase
            .drive(Binder(mainView) { base, callPhase in
                base.setup(callPhase: callPhase)
            })
            .disposed(by: disposeBag)
        
        output.videoViewCallUIState
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
extension VideoCallViewController {
    static func make(callDirection: CallDirection) -> VideoCallViewController {
        let vc = VideoCallViewController(callDirection: callDirection)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension VideoCallViewController {
    func action(_ action: VideoCallViewModel.Action) {
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
        mainView.animationView.setup(animation: .speaking)
        mainView.canSpeakView.isHidden = true
    }

    func handleListeningState() {
        let switchToListening: () -> Void = { [weak self] in
            guard let self else { return }
            
            streamingAudioPlayer.stop()
            try? callSTTService.start { [weak self] text in
                self?.webSocketService.send(message: text)
            }
            mainView.animationView.setup(animation: .listening)
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
