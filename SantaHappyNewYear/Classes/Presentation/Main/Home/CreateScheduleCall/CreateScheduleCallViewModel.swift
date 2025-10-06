//
//  CreateScheduleCallViewModel.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

import RxSwift
import RxCocoa

final class CreateScheduleCallViewModel {
    enum Action {
        case notifyInvalidDate
        case close
        case checkNotificationsPermissions
    }
    
    private let callMethod: Driver<CreateScheduleCallViewController.CallMethod>
    
    private lazy var callsManager = CallsManager()
    
    init(callMethod: CreateScheduleCallViewController.CallMethod) {
        self.callMethod = BehaviorRelay(value: callMethod).asDriver()
    }
}

// MARK: Public
extension CreateScheduleCallViewModel {
    struct Input {
        let didTapSave: Signal<Void>
        let saveScheduleCall: Signal<(Date, Date)>
    }
    
    struct Output {
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                callMethod: callMethod,
                didTapSave: input.didTapSave,
                saveScheduleCall: input.saveScheduleCall
            )
        )
    }
}

// MARK: Private
private extension CreateScheduleCallViewModel {
    func makeAction(
        callMethod: Driver<CreateScheduleCallViewController.CallMethod>,
        didTapSave: Signal<Void>,
        saveScheduleCall: Signal<(Date, Date)>
    ) -> Driver<Action> {
        let checkNotificationsPermissions = didTapSave
            .map { Action.checkNotificationsPermissions }
            .asDriver(onErrorDriveWith: .never())
        
        let save = saveScheduleCall
            .map { Self.combine(date: $0, time: $1) }
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(callMethod) { ($0, $1) }
            .flatMapLatest { [weak self] dateTime, callMethod -> Driver<Action> in
                guard let self else { return .never() }
                
                if dateTime <= Date() {
                    return .just(.notifyInvalidDate)
                }
                
                let method: ScheduleCall.Method = {
                    switch callMethod {
                    case .audio:
                        return .audio
                    case .video:
                        return .video
                    }
                }()
                
                return callsManager
                    .create(method: method, dateTime: dateTime)
                    .map { _ in Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
        
        return Driver
            .merge(checkNotificationsPermissions, save)
    }
}

// MARK: Additional
private extension CreateScheduleCallViewModel {
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
