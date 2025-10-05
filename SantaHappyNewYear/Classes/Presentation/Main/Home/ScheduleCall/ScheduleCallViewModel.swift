//
//  ScheduleCallViewModel.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

import RxSwift
import RxCocoa

final class ScheduleCallViewModel {
    enum Action {
        case notifyInvalidDate
        case close
    }
    
    private let callMethod: Driver<ScheduleCallViewController.CallMethod>
    
    private lazy var callsManager = CallsManager()
    
    init(callMethod: ScheduleCallViewController.CallMethod) {
        self.callMethod = BehaviorRelay(value: callMethod).asDriver()
    }
}

// MARK: Public
extension ScheduleCallViewModel {
    struct Input {
        let didTapSave: Signal<(Date, Date)>
    }
    
    struct Output {
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                callMethod: callMethod,
                didTapSave: input.didTapSave
            )
        )
    }
}

// MARK: Private
private extension ScheduleCallViewModel {
    func makeAction(
        callMethod: Driver<ScheduleCallViewController.CallMethod>,
        didTapSave: Signal<(Date, Date)>
    ) -> Driver<Action> {
        didTapSave
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
