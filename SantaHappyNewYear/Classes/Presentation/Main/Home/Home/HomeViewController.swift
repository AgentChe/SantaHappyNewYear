//
//  HomeViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import UIKit
import RxSwift

final class HomeViewController: UIViewController {
    private lazy var mainView = HomeView()
    
    private lazy var viewModel = HomeViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: HomeViewModel.Input(
            didTapWriteMessage:  mainView.actionsView.writeMessageButton.rx.tap.asSignal(),
            didTapCallSanta: mainView.actionsView.callSantaButton.rx.tap.asSignal(),
            didTapEdit: mainView.tableContainer.tableView.didEdit,
            didTapCall: mainView.tableContainer.tableView.didCall
        ))
        
        output.elements
            .drive(Binder(mainView) { base, elements in
                base.setup(elements: elements)
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
extension HomeViewController {
    static func make() -> HomeViewController {
        let vc = HomeViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension HomeViewController {
    func action(_ action: HomeViewModel.Action) {
        switch action {
        case .openChat:
            let vc = ChatViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        case .chooseCallMethod:
            let vc = ChooseCallMethodViewController.make { [weak self] result in
                guard let self else { return  }
                
                switch result {
                case .nowAudio:
                    if SessionManager().hasActiveSubscriptions() {
                        CallPermissions.requestAll(requireVideo: false) { result in
                            switch result {
                            case .success:
                                let vc = AudioCallViewController.make(callDirection: .outgoing)
                                self.present(vc, animated: false)
                            case .failure(let error):
                                CallPermissions.openErrorAlert(from: self, error: error)
                            }
                        }
                    } else {
                        let vc = PaygateViewController.make()
                        self.present(vc, animated: true)
                    }
                case .nowVideo:
                    if SessionManager().hasActiveSubscriptions() {
                        CallPermissions.requestAll(requireVideo: true) { result in
                            switch result {
                            case .success:
                                let vc = VideoCallViewController.make(callDirection: .outgoing)
                                self.present(vc, animated: false)
                            case .failure(let error):
                                CallPermissions.openErrorAlert(from: self, error: error)
                            }
                        }
                    } else {
                        let vc = PaygateViewController.make()
                        self.present(vc, animated: true)
                    }
                case .scheduleAudio:
                    let vc = CreateScheduleCallViewController.make(callMethod: .audio)
                    self.present(vc, animated: false)
                case .scheduleVideo:
                    let vc = CreateScheduleCallViewController.make(callMethod: .video)
                    self.present(vc, animated: false)
                }
            }
            present(vc, animated: false)
        case .editScheduleCall(let scheduleCall):
            let vc = ScheduleCallViewController.make(scheduleCall: scheduleCall)
            present(vc, animated: false)
        case .audioCall:
            CallPermissions.requestAll(requireVideo: false) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success:
                    let vc = AudioCallViewController.make(callDirection: .outgoing)
                    present(vc, animated: false)
                case .failure(let error):
                    CallPermissions.openErrorAlert(from: self, error: error)
                }
            }
        case .videoCall:
            CallPermissions.requestAll(requireVideo: true) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success:
                    let vc = VideoCallViewController.make(callDirection: .outgoing)
                    present(vc, animated: false)
                case .failure(let error):
                    CallPermissions.openErrorAlert(from: self, error: error)
                }
            }
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
