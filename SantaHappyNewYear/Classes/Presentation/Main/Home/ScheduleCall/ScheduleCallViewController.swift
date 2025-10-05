//
//  ScheduleCallViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
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
    
    private init(callMethod: CallMethod) {
        viewModel = ScheduleCallViewModel(callMethod: callMethod)
        
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
            didTapSave: didTapSave
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
extension ScheduleCallViewController {
    static func make(callMethod: CallMethod) -> ScheduleCallViewController {
        let vc = ScheduleCallViewController(callMethod: callMethod)
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
