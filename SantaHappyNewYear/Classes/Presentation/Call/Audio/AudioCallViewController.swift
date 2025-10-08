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
    
    private let mainView: AudioCallView
    
    private let viewModel: AudioCallViewModel
    
    private lazy var disposeBag = DisposeBag()
    
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
        
        let output = viewModel.configure(input: AudioCallViewModel.Input(
            didTapReject: mainView.rejectButton.rx.tap.asSignal(),
            didTapAccept: mainView.acceptButton?.rx.tap.asSignal() ?? .never()
        ))
        
        output.callPhase
            .drive(Binder(mainView) { base, callPhase in
                base.setup(callPhase: callPhase)
            })
            .disposed(by: disposeBag)
        
        output.callUIState
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
            dismiss(animated: false)
        }
    }
}
