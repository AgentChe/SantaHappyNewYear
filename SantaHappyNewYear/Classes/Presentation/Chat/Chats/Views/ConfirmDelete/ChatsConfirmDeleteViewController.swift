//
//  ChatsConfirmDeleteViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 06.10.2025.
//

import UIKit
import RxSwift

final class ChatsConfirmDeleteViewController: UIViewController {
    private lazy var mainView = ChatsConfirmDeleteView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let didDelete: () -> Void
    
    private init(didDelete: @escaping () -> Void) {
        self.didDelete = didDelete
        
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
        
        mainView.cancelButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss()
            })
            .disposed(by: disposeBag)
        
        mainView.deleteButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss {
                    base.didDelete()
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension ChatsConfirmDeleteViewController {
    static func make(didDelete: @escaping () -> Void) -> ChatsConfirmDeleteViewController {
        let vc = ChatsConfirmDeleteViewController(didDelete: didDelete)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension ChatsConfirmDeleteViewController {
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}
