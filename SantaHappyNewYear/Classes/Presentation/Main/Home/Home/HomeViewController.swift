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
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.writeMessageButton.rx.tap
            .bind(to: Binder(self) { base, void in
                let vc = ChatViewController.make()
                base.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.callSantaButton.rx.tap
            .bind(to: Binder(self) { base, void in
                let vc = ChooseCallMethodViewController.make { result in
                    switch result {
                    case .nowAudio:
                        print("nowAudio") // TODO
                    case .nowVideo:
                        print("nowVideo") // TODO
                    case .scheduleAudio:
                        let vc = ScheduleCallViewController.make(callMethod: .audio)
                        base.present(vc, animated: false)
                    case .scheduleVideo:
                        let vc = ScheduleCallViewController.make(callMethod: .video)
                        base.present(vc, animated: false)
                    }
                }
                base.present(vc, animated: false)
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
