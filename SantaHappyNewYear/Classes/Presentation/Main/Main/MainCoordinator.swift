//
//  MainCoordinator.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import UIKit

final class MainCoordinator {
    weak var parentVC: MainViewController?
    
    lazy var homeVC = HomeViewController.make()
    lazy var messagesVC = ChatsViewController.make()
    lazy var settingsVC = SettingsViewController.make()
    
    private var previousVC: UIViewController?
    
    private let santaCallObserver: SantaCallObserver
    
    init(parentVC: MainViewController, notificationsModel: NotificationsModel?) {
        self.parentVC = parentVC
        self.santaCallObserver = SantaCallObserver(notificationsModel: notificationsModel)
    }
}

// MARK: Public
extension MainCoordinator {
    func startSantaCallObserve() {
        guard santaCallObserver.open == nil else { return }
        
        santaCallObserver.open = { [weak self] method in
            switch method {
            case .audio:
                let vc = AudioCallViewController.make(callDirection: .incoming)
                self?.previousVC?.present(vc, animated: false)
            case .video:
                let vc = VideoCallViewController.make(callDirection: .incoming)
                self?.previousVC?.present(vc, animated: false)
            }
        }
    }
    
    func change(tab: TabView.Tab) {
        parentVC?.mainView.tabView.selectedTab = tab
        
        switch tab {
        case .home:
            changeVC(on: homeVC)
        case .messages:
            changeVC(on: messagesVC)
        case .settings:
            changeVC(on: settingsVC)
        }
    }
}

// MARK: Private
private extension MainCoordinator {
    func changeVC(on vc: UIViewController) {
        if let previousVC = self.previousVC {
            previousVC.willMove(toParent: nil)
            previousVC.view.removeFromSuperview()
            previousVC.removeFromParent()
        }
    
        self.previousVC = vc
        
        guard let parentVC = self.parentVC else {
            return
        }
    
        parentVC.addChild(vc)
        vc.view.frame = parentVC.mainView.container.bounds
        parentVC.mainView.container.addSubview(vc.view)
        vc.willMove(toParent: parentVC)
    }
}
