//
//  SantaCallObserver.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 06.10.2025.
//

import RxSwift

final class SantaCallObserver {
    enum Method {
        case audio, video
    }
    
    var open: ((Method) -> Void)? {
        didSet {
            if let initialNotificationsModel {
                localNotificationsDidReceive(model: initialNotificationsModel)
            }
        }
    }
    
    private lazy var callsManager = CallsManager()
    
    private lazy var disposeBag = DisposeBag()
    
    private let initialNotificationsModel: NotificationsModel?
    
    init(notificationsModel: NotificationsModel?) {
        self.initialNotificationsModel = notificationsModel
        
        LocalNotificationsManager.shared.add(observer: self)
        
        if let notificationsModel {
            localNotificationsDidReceive(model: notificationsModel)
        }
    }
}

// MARK: LocalNotificationsDelegate
extension SantaCallObserver: LocalNotificationsDelegate {
    func localNotificationsDidReceive(authorizationStatus: NotificationsAuthorizationStatus) {}
    
    func localNotificationsDidReceive(model: NotificationsModel) {
        guard
            let scheduleCallId = model.userInfo[LocalNotificationsManager.Constants.scheduleCallIdKey] as? String,
            let scheduleCallMethod = model.userInfo[LocalNotificationsManager.Constants.scheduleCallMethodKey] as? String,
            let method: Method = {
                switch scheduleCallMethod {
                case LocalNotificationsManager.Constants.audioKey:
                    return .audio
                case LocalNotificationsManager.Constants.videoKey:
                    return .video
                default:
                    return nil
                }
            }()
        else { return }
        
        callsManager
            .delete(scheduleCallId: scheduleCallId)
            .asDriver(onErrorDriveWith: .never())
            .drive(Binder(self) { base, _ in
                base.open?(method)
            })
            .disposed(by: disposeBag)
    }
}
