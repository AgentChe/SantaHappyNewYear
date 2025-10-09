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
        case playRingtone(RingtonePlayer.CallDirection)
        case stopRingtone
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
        let audioViewCallPhase: Driver<AudioCallView.CallPhase>
        let audioViewCallUIState: Driver<AudioCallView.CallUIState>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let callPhase = makeCallPhase(
            callDirection: callDirection,
            didTapAccept: input.didTapAccept
        )
        
        return Output(
            audioViewCallPhase: makeAudioViewCallPhase(callPhase: callPhase),
            audioViewCallUIState: makeAudioViewCallUIState(
                callDirection: callDirection,
                callPhase: callPhase
            ),
            action: makeAction(
                callDirection: callDirection,
                didTapReject: input.didTapReject,
                callPhase: callPhase
            )
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
    
    func makeAudioViewCallPhase(callPhase: Driver<CallPhase>) -> Driver<AudioCallView.CallPhase> {
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
    
    func makeAudioViewCallUIState(
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
    
    func makeAction(
        callDirection: Driver<AudioCallViewController.CallDirection>,
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
