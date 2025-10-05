//
//  CSCInvalidDateViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 05.10.2025.
//

import UIKit
import RxSwift

final class CSCInvalidDateViewController: UIViewController {
    private lazy var mainView = CSCInvalidDateView()
    
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
extension CSCInvalidDateViewController {
    static func make() -> CSCInvalidDateViewController {
        let vc = CSCInvalidDateViewController()
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension CSCInvalidDateViewController {
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}
