//
//  CSCNotNotificationsPermissionsViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 06.10.2025.
//

import UIKit
import RxSwift

final class CSCNotNotificationsPermissionsViewController: UIViewController {
    private lazy var mainView = CSCNotNotificationsPermissionsView()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.okButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension CSCNotNotificationsPermissionsViewController {
    static func make() -> CSCNotNotificationsPermissionsViewController {
        let vc = CSCNotNotificationsPermissionsViewController()
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension CSCNotNotificationsPermissionsViewController {
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}
