//
//  ChatsViewController.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatsViewController: UIViewController {
    private lazy var mainView = ChatsView()
    
    private lazy var viewModel = ChatsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didConfirmDeleteTrigger = PublishRelay<Chat>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: ChatsViewModel.Input(
            didSelectChat: mainView.tableView.didSelect,
            didTapDelete: mainView.tableView.didDelete,
            didConfirmDelete: didConfirmDeleteTrigger.asSignal()
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension ChatsViewController {
    static func make() -> ChatsViewController {
        let vc = ChatsViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension ChatsViewController {
    func action(_ action: ChatsViewModel.Action) {
        switch action {
        case .openChat(let chat):
            let vc = ChatViewController.make(chat: chat)
            navigationController?.pushViewController(vc, animated: true)
        case .requestConfirmDelete(let chat):
            let vc = ChatsConfirmDeleteViewController.make { [weak self] in
                self?.didConfirmDeleteTrigger.accept(chat)
            }
            present(vc, animated: false)
        }
    }
}
