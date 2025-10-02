//
//  ChatsViewController.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import UIKit
import RxSwift

final class ChatsViewController: UIViewController {
    private lazy var mainView = ChatsView()
    
    private lazy var viewModel = ChatsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: ChatsViewModel.Input(
            didSelectChat: mainView.tableView.didSelect
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
            let vc = ChatsViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
