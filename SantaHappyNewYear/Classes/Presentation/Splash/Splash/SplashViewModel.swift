//
//  SplashViewModel.swift
//  CVMaker
//
//  Created by Андрей Чернышев on 27.08.2024.
//

import RxSwift
import RxCocoa

final class SplashViewModel {
    enum Route {
        case onboarding, paygateTransitionMain, main
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension SplashViewModel {
    struct Input {
        let didSDKConfigured: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let login = login(didSDKConfigured: input.didSDKConfigured)
        
        return Output(
            route: makeRoute(login: login)
        )
    }
}

// MARK: Private
private extension SplashViewModel {
    func makeRoute(login: Signal<Void>) -> Driver<Route> {
        login
            .map { void -> Route in
                if !OnboardingViewController.wasViewed() {
                    return .onboarding
                }
                
                return SessionManager().hasActiveSubscriptions() ? Route.main : Route.paygateTransitionMain
            }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func login(didSDKConfigured: Signal<Void>) -> Signal<Void> {
        didSDKConfigured
            .flatMapLatest { [weak self] void -> Signal<Void> in
                guard let self else { return .never() }
                
                func source() -> Single<Void> {
                    let sessionManager = SessionManager()
                    let anonymousId = sessionManager.anonymousId
                    let internalId = sessionManager.internalId
                    
                    let login = (anonymousId == internalId) ? profileManager.create() : profileManager.binding()
                    
                    return login
                        .flatMap { result -> Single<Void> in
                            guard result.success else {
                                return .error(ContentError(.notContent))
                            }
                            
                            return self.profileManager
                                .set(locale: "ru_RU") // TODO: en_EN
                                .map { result -> Void in
                                    guard result.success else {
                                        throw ContentError(.notContent)
                                    }
                                    
                                    return Void()
                                }
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    tryAgain?(error) ?? .empty()
                }
                
                return observableRetrySingle
                    .retry(
                        source: { source() },
                        trigger: { trigger(error: $0) }
                    )
                    .asSignal(onErrorSignalWith: .never())
            }
    }
}
