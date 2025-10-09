//
//  VideoCallViewModel.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 08.10.2025.
//

import RxSwift
import RxCocoa

final class VideoCallViewModel {
    enum Action {
        case cancelCall
        case playRingtone(RingtonePlayer.CallDirection)
        case stopRingtone
    }
    
    private let callDirection: Driver<VideoCallViewController.CallDirection>
    
    init(callDirection: VideoCallViewController.CallDirection) {
        self.callDirection = BehaviorRelay(value: callDirection).asDriver()
    }
}

// MARK: Public
extension VideoCallViewModel {
    struct Input {
        let didTapReject: Signal<Void>
        let didTapAccept: Signal<Void>
    }
    
    struct Output {
        let callPhase: Driver<VideoCallView.CallPhase>
        let callUIState: Driver<VideoCallView.CallUIState>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let callPhase = makeCallPhase(
            callDirection: callDirection,
            didTapAccept: input.didTapAccept
        )
        
        return Output(
            callPhase: makeViewCallPhase(callPhase: callPhase),
            callUIState: makeCallUIState(callPhase: callPhase),
            action: makeAction(
                callDirection: callDirection,
                didTapReject: input.didTapReject,
                callPhase: callPhase
            )
        )
    }
}

// MARK: Private
private extension VideoCallViewModel {
    enum CallPhase {
        case ringing
        case active
    }
    
    func makeCallPhase(
        callDirection: Driver<VideoCallViewController.CallDirection>,
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
    
    func makeViewCallPhase(callPhase: Driver<CallPhase>) -> Driver<VideoCallView.CallPhase> {
        callPhase
            .flatMapLatest { callPhase -> Driver<VideoCallView.CallPhase> in
                switch callPhase {
                case .ringing:
                    return .just(.ringing)
                case .active:
                    return Observable<Int>
                        .timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.asyncInstance)
                        .map { VideoCallView.CallPhase.active($0) }
                        .asDriver(onErrorDriveWith: .never())
                }
            }
    }
    
    func makeCallUIState(callPhase: Driver<CallPhase>) -> Driver<VideoCallView.CallUIState> {
        callPhase
            .map { callPhase -> VideoCallView.CallUIState in
                switch callPhase {
                case .ringing:
                    return .awaitingPickup
                case .active:
                    return .inConversation
                }
            }
    }
    
    func makeAction(
        callDirection: Driver<VideoCallViewController.CallDirection>,
        didTapReject: Signal<Void>,
        callPhase: Driver<CallPhase>
    ) -> Driver<Action> {
        let cancelCall = didTapReject
            .map { Action.cancelCall }
            .asDriver(onErrorDriveWith: .never())
        
        let ringtone = callPhase
            .withLatestFrom(callDirection) { ($0, $1) }
            .map { callPhase, callDirection -> Action in
                let translateCallDirection: RingtonePlayer.CallDirection = {
                    switch callDirection {
                    case .incoming:
                        return .incoming
                    case .outgoing:
                        return .outgoing
                    }
                }()
                
                switch callPhase {
                case .ringing:
                    return .playRingtone(translateCallDirection)
                case .active:
                    return .stopRingtone
                }
            }
        
        return Driver
            .merge(cancelCall, ringtone)
    }
}
