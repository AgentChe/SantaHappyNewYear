//
//  SettingsViewModel.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import RxSwift
import RxCocoa

final class SettingsViewModel {
    enum Action {
        case openPaygate
        case openURL(URL)
    }
}

// MARK: Public
extension SettingsViewModel {
    struct Input {
        let didTapUpgrade: Signal<Void>
        let didTapLink: Signal<URL>
    }
    
    struct Output {
        let elements: Driver<[SettingsTableElement]>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(activeSubscription: makeActiveSubscription()),
            action: makeAction(
                didTapUpgrade: input.didTapUpgrade,
                didTapLink: input.didTapLink
            )
        )
    }
}

// MARK: Private
private extension SettingsViewModel {
    func makeElements(activeSubscription: Driver<Bool>) -> Driver<[SettingsTableElement]> {
        activeSubscription
            .map { activeSubscription -> [SettingsTableElement] in
                activeSubscription ? [.links] : [.upgrade, .links]
            }
    }
    
    func makeAction(
        didTapUpgrade: Signal<Void>,
        didTapLink: Signal<URL>
    ) -> Driver<Action> {
        let openPaygate = didTapUpgrade
            .map { Action.openPaygate }
            .asDriver(onErrorDriveWith: .never())
        
        let openURL = didTapLink
            .map { Action.openURL($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openPaygate, openURL)
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .map { SessionManager().hasActiveSubscriptions() }
            .startWith(SessionManager().hasActiveSubscriptions())
            .asDriver(onErrorJustReturn: false)
    }
}
