//
//  ScheduleCallViewModel.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 05.10.2025.
//

import RxSwift
import RxCocoa

final class ScheduleCallViewModel {
    enum Action {
        case notifyInvalidDate
        case close
        case requestConfirmDelete
    }
    
    private let scheduleCall: Driver<ScheduleCall>
    
    private lazy var callsManager = CallsManager()
    
    init(scheduleCall: ScheduleCall) {
        self.scheduleCall = BehaviorRelay(value: scheduleCall).asDriver()
    }
}

// MARK: Public
extension ScheduleCallViewModel {
    struct Input {
        let didTapSave: Signal<(Date, Date)>
        let didTapDelete: Signal<Void>
        let didConfirmDelete: Signal<Void>
    }
    
    struct Output {
        let action: Driver<Action>
        let initialDateTime: Driver<(Date, Date)>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                scheduleCall: scheduleCall,
                didTapSave: input.didTapSave,
                didTapDelete: input.didTapDelete,
                didConfirmDelete: input.didConfirmDelete
            ),
            initialDateTime: makeInitialDateTime(scheduleCall: scheduleCall)
        )
    }
}

// MARK: Private
private extension ScheduleCallViewModel {
    func makeAction(
        scheduleCall: Driver<ScheduleCall>,
        didTapSave: Signal<(Date, Date)>,
        didTapDelete: Signal<Void>,
        didConfirmDelete: Signal<Void>
    ) -> Driver<Action> {
        let edit = didTapSave
            .map { Self.combine(date: $0, time: $1) }
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(scheduleCall) { ($0, $1) }
            .flatMapLatest { [weak self] dateTime, scheduleCall -> Driver<Action> in
                guard let self else { return .never() }
                
                if dateTime <= Date() {
                    return .just(.notifyInvalidDate)
                }
                
                return callsManager
                    .edit(scheduleCall: scheduleCall, newDateTime: dateTime)
                    .map { _ in Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
        
        let requestConfirmDelete = didTapDelete
            .map { Action.requestConfirmDelete }
            .asDriver(onErrorDriveWith: .never())
        
        let delete = didConfirmDelete
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(scheduleCall)
            .flatMapLatest { [weak self] scheduleCall -> Driver<Action> in
                guard let self else { return .never() }
                
                return callsManager
                    .delete(scheduleCallId: scheduleCall.id)
                    .map { _ in Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
        
        return Driver
            .merge(edit, requestConfirmDelete, delete)
    }
    
    func makeInitialDateTime(scheduleCall: Driver<ScheduleCall>) -> Driver<(Date, Date)> {
        scheduleCall.map { scheduleCall in
            let calendar = Calendar.current
            
            let dateOnly = calendar.startOfDay(for: scheduleCall.dateTime)

            let hms = calendar.dateComponents([.hour, .minute, .second], from: scheduleCall.dateTime)
            let base = Date(timeIntervalSinceReferenceDate: 0)
            let timeOnly = calendar.date(
                bySettingHour: hms.hour ?? 0,
                minute: hms.minute ?? 0,
                second: hms.second ?? 0,
                of: base
            ) ?? base

            return (dateOnly, timeOnly)
        }
    }
}

// MARK: Additional
private extension ScheduleCallViewModel {
    static func combine(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        return calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: timeComponents.second ?? 0,
            of: date
        ) ?? date
    }
}
