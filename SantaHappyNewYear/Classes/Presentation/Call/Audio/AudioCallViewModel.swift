//
//  AudioCallViewModel.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 06.10.2025.
//

import RxSwift
import RxCocoa

final class AudioCallViewModel {
    enum Action {
        case cancelCall
    }
    
    private let callDirection: Driver<AudioCallViewController.CallDirection>
    
    init(callDirection: AudioCallViewController.CallDirection) {
        self.callDirection = BehaviorRelay(value: callDirection).asDriver()
    }
}

// MARK: Public
extension AudioCallViewModel {
    struct Input {
        let didTapReject: Signal<Void>
        let didTapAccept: Signal<Void>
    }
    
    struct Output {
        let callPhase: Driver<AudioCallView.CallPhase>
        let callUIState: Driver<AudioCallView.CallUIState>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let callPhase = makeCallPhase(
            callDirection: callDirection,
            didTapAccept: input.didTapAccept
        )
        
        return Output(
            callPhase: makeViewCallPhase(callPhase: callPhase),
            callUIState: makeCallUIState(
                callDirection: callDirection,
                callPhase: callPhase
            ),
            action: makeAction(didTapReject: input.didTapReject)
        )
    }
}

// MARK: Private
private extension AudioCallViewModel {
    enum CallPhase {
        case ringing
        case active
    }
    
    func makeCallPhase(
        callDirection: Driver<AudioCallViewController.CallDirection>,
        didTapAccept: Signal<Void>
    ) -> Driver<CallPhase> {
        callDirection
            .flatMapLatest { callDirection -> Driver<CallPhase> in
                switch callDirection {
                case .incoming:
                    return didTapAccept
                        .asDriver(onErrorDriveWith: .never())
                        .map { CallPhase.active }
                        .startWith(.ringing)
                case .outgoing:
                    return Observable<CallPhase>.just(.active)
                        .delay(RxTimeInterval.seconds(3), scheduler: MainScheduler.asyncInstance)
                        .asDriver(onErrorDriveWith: .never())
                        .startWith(.ringing)
                }
            }
    }
    
    func makeViewCallPhase(callPhase: Driver<CallPhase>) -> Driver<AudioCallView.CallPhase> {
        callPhase
            .flatMapLatest { callPhase -> Driver<AudioCallView.CallPhase> in
                switch callPhase {
                case .ringing:
                    return .just(.ringing)
                case .active:
                    return Observable<Int>
                        .timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.asyncInstance)
                        .map { AudioCallView.CallPhase.active($0) }
                        .asDriver(onErrorDriveWith: .never())
                }
            }
    }
    
    func makeCallUIState(
        callDirection: Driver<AudioCallViewController.CallDirection>,
        callPhase: Driver<CallPhase>
    ) -> Driver<AudioCallView.CallUIState> {
        callPhase
            .withLatestFrom(callDirection) { ($0, $1) }
            .filter { $1 == .incoming }
            .map { callPhase, _ -> AudioCallView.CallUIState in
                switch callPhase {
                case .ringing:
                    return .awaitingPickup
                case .active:
                    return .inConversation
                }
            }
    }
    
    func makeAction(didTapReject: Signal<Void>) -> Driver<Action> {
        let cancelCall = didTapReject
            .map { Action.cancelCall }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(cancelCall)
    }
}
