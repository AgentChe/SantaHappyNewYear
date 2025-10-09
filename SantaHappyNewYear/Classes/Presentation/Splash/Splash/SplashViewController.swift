//
//  SplashViewController.swift
//  Soccer
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class SplashViewController: UIViewController {
    private lazy var mainView = SplashView()
    
    private lazy var viewModel = SplashViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var sdkInitialize = SplashReceiptValidationObserver()
    
    private lazy var didSDKConfiguredTrigger = PublishRelay<Void>()
    
    private let notificationsModel: NotificationsModel?
    
    private init(notificationsModel: NotificationsModel?) {
        self.notificationsModel = notificationsModel
        
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
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            self?.open(error: error) ?? .never()
        }
        
        let output = viewModel.configure(input: SplashViewModel.Input(
            didSDKConfigured: didSDKConfiguredTrigger.asSignal()
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        sdkInitialize.observe { [weak self] in
            self?.didSDKConfiguredTrigger.accept(Void())
        }
    }
}

// MARK: Make
extension SplashViewController {
    static func make(notificationsModel: NotificationsModel?) -> SplashViewController {
        SplashViewController(notificationsModel: notificationsModel)
    }
}

// MARK: Private
private extension SplashViewController {
    func route(_ route: SplashViewModel.Route) {
        DispatchQueue.main.async { [weak self] in
            guard let window = UIApplication.shared.window else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                    self?.route(route)
                }
                
                return
            }
            
            switch route {
            case .onboarding:
                window.rootViewController = OnboardingViewController.make()
            case .main:
                window.rootViewController = MainViewController.make(requestReview: false, notificationsModel: self?.notificationsModel)
            case .paygateTransitionMain:
                let vc = PaygateViewController.make { [weak window] in
                    window?.rootViewController = MainViewController.make(requestReview: false, notificationsModel: self?.notificationsModel)
                }
                self?.present(vc, animated: true)
            }
        }
    }
    
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self else { return Disposables.create() }
                
                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
}
