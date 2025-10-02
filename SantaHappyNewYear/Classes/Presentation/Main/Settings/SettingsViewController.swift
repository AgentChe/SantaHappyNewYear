//
//  SettingsViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import UIKit
import RxSwift

final class SettingsViewController: UIViewController {
    private lazy var mainView = SettingsView()
    
    private lazy var viewModel = SettingsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: SettingsViewModel.Input(
            didTapUpgrade: mainView.tableView.didTapUpgrade,
            didTapLink: mainView.tableView.didTapLink
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
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
extension SettingsViewController {
    static func make() -> SettingsViewController {
        let vc = SettingsViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension SettingsViewController {
    func action(_ action: SettingsViewModel.Action) {
        switch action {
        case .openPaygate:
            // TODO
//            let vc = PaygateViewController.make()
//            present(vc, animated: true)
            
            let vc = ChatViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        case .openURL(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
