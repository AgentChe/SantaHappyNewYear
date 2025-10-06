//
//  CallsManager.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 05.10.2025.
//

import RxSwift

protocol CallsManagerProtocol {
    func fetchScheduleCalls() -> Single<[ScheduleCall]>
    func create(method: ScheduleCall.Method, dateTime: Date) -> Single<ScheduleCall>
    func edit(scheduleCall: ScheduleCall, newDateTime: Date) -> Single<ScheduleCall>
    func delete(scheduleCallId: String) -> Single<Void>
}

final class CallsManager {}

// MARK: CallsManagerProtocol
extension CallsManager: CallsManagerProtocol {
    func fetchScheduleCalls() -> Single<[ScheduleCall]> {
        Single<[ScheduleCall]>.create { single in
            let scheduleCalls: [ScheduleCall] = {
                guard let data = UserDefaults.standard.data(forKey: Constants.scheduleCallKey) else { return [] }
                let scheduleCalls = try? JSONDecoder().decode([ScheduleCall].self, from: data)
                return scheduleCalls ?? []
            }()
            
            single(.success(scheduleCalls))
            
            return Disposables.create()
        }
    }
    
    func create(method: ScheduleCall.Method, dateTime: Date) -> Single<ScheduleCall> {
        fetchScheduleCalls()
            .flatMap { scheduleCalls -> Single<ScheduleCall> in
                Single<ScheduleCall>.create { single in
                    let new = ScheduleCall(id: UUID().uuidString, method: method, dateTime: dateTime)
                    let all = scheduleCalls + [new]
                    
                    if let data = try? JSONEncoder().encode(all) {
                        UserDefaults.standard.set(data, forKey: Constants.scheduleCallKey)
                    }
                    
                    single(.success(new))
                    
                    CallsMediator.shared.created(scheduleCall: new)
                    LocalNotificationsManager.shared.schedule(for: new)
                    
                    return Disposables.create()
                }
            }
    }
    
    func edit(scheduleCall: ScheduleCall, newDateTime: Date) -> Single<ScheduleCall> {
        fetchScheduleCalls()
            .flatMap { scheduleCalls -> Single<ScheduleCall> in
                Single<ScheduleCall>.create { single in
                    if let oldIndex = scheduleCalls.firstIndex(where: { $0.id == scheduleCall.id }) {
                        let old = scheduleCalls[oldIndex]
                        let edited = ScheduleCall(id: old.id, method: old.method, dateTime: newDateTime)
                        
                        var all = scheduleCalls
                        all[oldIndex] = edited
                        
                        if let data = try? JSONEncoder().encode(all) {
                            UserDefaults.standard.set(data, forKey: Constants.scheduleCallKey)
                        }
                        
                        single(.success(edited))
                        
                        CallsMediator.shared.edited(scheduleCall: edited)
                        LocalNotificationsManager.shared.cancel(id: edited.id)
                        LocalNotificationsManager.shared.schedule(for: edited)
                    } else {
                        single(.success(scheduleCall))
                    }
                    
                    return Disposables.create()
                }
            }
    }
    
    func delete(scheduleCallId: String) -> Single<Void> {
        fetchScheduleCalls()
            .flatMap { scheduleCalls -> Single<Void> in
                Single<Void>.create { single in
                    var all = scheduleCalls
                    all.removeAll(where: { $0.id == scheduleCallId })
                    
                    if let data = try? JSONEncoder().encode(all) {
                        UserDefaults.standard.set(data, forKey: Constants.scheduleCallKey)
                    }
                    
                    single(.success(Void()))
                    
                    CallsMediator.shared.deleted(scheduleCallId: scheduleCallId)
                    LocalNotificationsManager.shared.cancel(id: scheduleCallId)
                    
                    return Disposables.create()
                }
            }
    }
}

// MARK: Private
private extension CallsManager {
    enum Constants {
        static let scheduleCallKey = "calls_manager_schedule_calls"
    }
}
