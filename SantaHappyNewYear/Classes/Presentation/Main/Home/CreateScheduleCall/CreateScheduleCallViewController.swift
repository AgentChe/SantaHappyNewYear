//
//  CreateScheduleCallViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateScheduleCallViewController: UIViewController {
    enum CallMethod {
        case audio, video
    }
    
    private lazy var mainView = CreateScheduleCallView()
    
    private let viewModel: CreateScheduleCallViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var saveScheduleCallTrigger = PublishRelay<(Date, Date)>()
    
    private init(callMethod: CallMethod) {
        viewModel = CreateScheduleCallViewModel(callMethod: callMethod)
        
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
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = true
        mainView.dimmedView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind(to: Binder(self) { base, _ in
                base.dismiss()
            })
            .disposed(by: disposeBag)
        
        let output = viewModel.configure(input: CreateScheduleCallViewModel.Input(
            didTapSave: mainView.saveButton.rx.tap.asSignal(),
            saveScheduleCall: saveScheduleCallTrigger.asSignal()
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension CreateScheduleCallViewController {
    static func make(callMethod: CallMethod) -> CreateScheduleCallViewController {
        let vc = CreateScheduleCallViewController(callMethod: callMethod)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension CreateScheduleCallViewController {
    func action(_ action: CreateScheduleCallViewModel.Action) {
        switch action {
        case .notifyInvalidDate:
            let vc = CSCInvalidDateViewController.make()
            present(vc, animated: false)
        case .close:
            dismiss()
        case .checkNotificationsPermissions:
            LocalNotificationsManager.shared.retriveAuthorizationStatus { [weak self] status in
                self?.handle(status: status)
            }
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
    
    func handle(status: NotificationsAuthorizationStatus) {
        switch status {
        case .authorized:
            saveScheduleCallTrigger.accept((mainView.dateView.selectedDate, mainView.timeView.selectedDate))
        case .notDetermined:
            LocalNotificationsManager.shared.requestAuthorization { [weak self] status in
                self?.handle(status: status)
            }
        case .denied:
            let vc = CSCNotNotificationsPermissionsViewController.make()
            present(vc, animated: false)
        }
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}
