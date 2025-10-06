//
//  ScheduleCallViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 05.10.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class ScheduleCallViewController: UIViewController {
    enum CallMethod {
        case audio, video
    }
    
    private lazy var mainView = ScheduleCallView()
    
    private let viewModel: ScheduleCallViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didConfirmDeleteTrigger = PublishRelay<Void>()
    
    private init(scheduleCall: ScheduleCall) {
        viewModel = ScheduleCallViewModel(scheduleCall: scheduleCall)
        
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
        
        let didTapSave: Signal<(Date, Date)> = mainView.saveButton.rx.tap
            .compactMap { [weak self] void -> (Date, Date)? in
                guard let self else { return nil }
                
                return (mainView.dateView.selectedDate, mainView.timeView.selectedDate)
            }
            .asSignal(onErrorSignalWith: .never())
        
        let output = viewModel.configure(input: ScheduleCallViewModel.Input(
            didTapSave: didTapSave,
            didTapDelete: mainView.deleteButton.rx.tap.asSignal(),
            didConfirmDelete: didConfirmDeleteTrigger.asSignal()
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        
        output.initialDateTime
            .drive(Binder(mainView) { base, dateTime in
                base.dateView.setup(dateTime.0)
                base.timeView.setup(dateTime.1)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension ScheduleCallViewController {
    static func make(scheduleCall: ScheduleCall) -> ScheduleCallViewController {
        let vc = ScheduleCallViewController(scheduleCall: scheduleCall)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension ScheduleCallViewController {
    func action(_ action: ScheduleCallViewModel.Action) {
        switch action {
        case .notifyInvalidDate:
            let vc = CSCInvalidDateViewController.make()
            present(vc, animated: false)
        case .close:
            dismiss()
        case .requestConfirmDelete:
            let vc = SCConfirmDeleteViewController.make { [weak self] in
                self?.didConfirmDeleteTrigger.accept(Void())
            }
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
