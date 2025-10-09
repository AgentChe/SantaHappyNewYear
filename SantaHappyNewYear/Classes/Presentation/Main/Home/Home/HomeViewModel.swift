//
//  HomeViewModel.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 05.10.2025.
//

import RxSwift
import RxCocoa

final class HomeViewModel {
    enum Action {
        case openChat
        case chooseCallMethod
        case editScheduleCall(ScheduleCall)
        case audioCall
        case videoCall
        case openPaygate
    }
    
    private lazy var callsManager = CallsManager()
}

// MARK: Public
extension HomeViewModel {
    struct Input {
        let didTapWriteMessage: Signal<Void>
        let didTapCallSanta: Signal<Void>
        let didTapEdit: Signal<ScheduleCall>
        let didTapCall: Signal<ScheduleCall>
    }
    
    struct Output {
        let elements: Driver<[ScheduleCall]>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(),
            action: makeAction(
                didTapWriteMessage: input.didTapWriteMessage,
                didTapCallSanta: input.didTapCallSanta,
                didTapEdit: input.didTapEdit,
                didTapCall: input.didTapCall
            )
        )
    }
}

// MARK: Private
private extension HomeViewModel {
    func makeElements() -> Driver<[ScheduleCall]> {
        let initial = callsManager
            .fetchScheduleCalls()
            .asDriver(onErrorJustReturn: [])
        
        return initial
            .flatMapLatest { initialScheduleCalls -> Driver<[ScheduleCall]> in
                enum Action {
                    case create(ScheduleCall)
                    case edit(ScheduleCall)
                    case delete(String)
                }
                
                let action = Driver<Action>
                    .merge(
                        CallsMediator.shared.didCreatedScheduleCall
                            .map { Action.create($0) }
                            .asDriver(onErrorDriveWith: .never()),
                        CallsMediator.shared.didEditedScheduleCall
                            .map { Action.edit($0) }
                            .asDriver(onErrorDriveWith: .never()),
                        CallsMediator.shared.didDeletedScheduleCall
                            .map { Action.delete($0) }
                            .asDriver(onErrorDriveWith: .never()),
                    )
                
                return action
                    .scan(initialScheduleCalls) { scheduleCalls, action -> [ScheduleCall] in
                        switch action {
                        case .create(let scheduleCell):
                            return scheduleCalls + [scheduleCell]
                        case .edit(let scheduleCell):
                            var result = scheduleCalls
                            if let index = result.firstIndex(where: { $0.id == scheduleCell.id }) {
                                result[index] = scheduleCell
                            }
                            return result
                        case .delete(let id):
                            var result = scheduleCalls
                            result.removeAll(where: { $0.id == id })
                            return result
                        }
                    }
                    .startWith(initialScheduleCalls)
                    .map { $0.sorted(by: { $0.dateTime > $1.dateTime }) }
            }
    }
    
    func makeAction(
        didTapWriteMessage: Signal<Void>,
        didTapCallSanta: Signal<Void>,
        didTapEdit: Signal<ScheduleCall>,
        didTapCall: Signal<ScheduleCall>
    ) -> Driver<Action> {
        let openChat = didTapWriteMessage
            .map { Action.openChat }
            .asDriver(onErrorDriveWith: .never())
        
        let chooseCallMethod = didTapCallSanta
            .map { Action.chooseCallMethod }
            .asDriver(onErrorDriveWith: .never())
        
        let editScheduleCall = didTapEdit
            .map { Action.editScheduleCall($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let call = didTapCall
            .flatMapLatest { [weak self] scheduleCall -> Driver<Action> in
                guard let self else { return .never() }
                
                guard SessionManager().hasActiveSubscriptions() else {
                    return .just(.openPaygate)
                }
                
                return callsManager
                    .delete(scheduleCallId: scheduleCall.id)
                    .asDriver(onErrorDriveWith: .never())
                    .map { void -> Action in
                        switch scheduleCall.method {
                        case .audio:
                            return .audioCall
                        case .video:
                            return .videoCall
                        }
                    }
            }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openChat, chooseCallMethod, editScheduleCall, call)
    }
}
