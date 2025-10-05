//
//  CallsMediator.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 05.10.2025.
//

import RxSwift
import RxCocoa

final class CallsMediator {
    static let shared = CallsMediator()
    
    private lazy var didCreatedScheduleCallTrigger = PublishRelay<ScheduleCall>()
    private lazy var didEditedScheduleCallTrigger = PublishRelay<ScheduleCall>()
    private lazy var didDeletedScheduleCallTrigger = PublishRelay<String>()
    
    private init() {}
}

// MARK: Public
extension CallsMediator {
    func created(scheduleCall: ScheduleCall) {
        didCreatedScheduleCallTrigger.accept(scheduleCall)
    }
    
    func edited(scheduleCall: ScheduleCall) {
        didEditedScheduleCallTrigger.accept(scheduleCall)
    }
    
    func deleted(scheduleCallId: String) {
        didDeletedScheduleCallTrigger.accept(scheduleCallId)
    }
    
    var didCreatedScheduleCall: Signal<ScheduleCall> {
        didCreatedScheduleCallTrigger.asSignal()
    }
    
    var didEditedScheduleCall: Signal<ScheduleCall> {
        didEditedScheduleCallTrigger.asSignal()
    }
    
    var didDeletedScheduleCall: Signal<String> {
        didDeletedScheduleCallTrigger.asSignal()
    }
}
