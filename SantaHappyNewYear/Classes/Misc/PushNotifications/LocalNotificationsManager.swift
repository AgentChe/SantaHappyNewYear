//
//  LocalNotificationsManager.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 06.10.2025.
//

import UserNotifications

protocol LocalNotificationsDelegate: AnyObject {
    func localNotificationsDidReceive(authorizationStatus: NotificationsAuthorizationStatus)
    func localNotificationsDidReceive(model: NotificationsModel)
}

final class LocalNotificationsManager: NSObject {
    enum Constants {
        static let categoryId = "santa_call_category"
        static let scheduleCallIdKey = "scheduleCallId"
        static let scheduleCallMethodKey = "scheduleCallMethod"
    }
    
    static let shared = LocalNotificationsManager()
    
    private let notificationsCenter = UNUserNotificationCenter.current()
    
    private var delegates = [Weak<LocalNotificationsDelegate>]()
    
    private override init() {
        super.init()
        
        notificationsCenter.delegate = self
    }
}

// MARK: Public
extension LocalNotificationsManager {
    func schedule(for call: ScheduleCall) {
        guard call.dateTime > Date().addingTimeInterval(1) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "LocalNotifications.Content.Title".localized
        content.body = "LocalNotifications.Content.Body".localized
        content.sound = .defaultRingtone
        content.categoryIdentifier = Constants.categoryId
        content.userInfo = [
            Constants.scheduleCallIdKey: call.id,
            Constants.scheduleCallMethodKey: (call.method == .video ? "video" : "audio")
        ]

        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: call.dateTime)
        comps.timeZone = TimeZone.current

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: call.id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }
    
    func retriveAuthorizationStatus(handler: ((NotificationsAuthorizationStatus) -> Void)?) {
        notificationsCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let result: NotificationsAuthorizationStatus
                
                switch settings.authorizationStatus {
                case .authorized:
                    result = .authorized
                case .notDetermined:
                    result = .notDetermined
                default:
                    result = .denied
                }
                
                handler?(result)
                self?.delegates.forEach { $0.weak?.localNotificationsDidReceive(authorizationStatus: result) }
            }
        }
    }
    
    func requestAuthorization(handler: ((NotificationsAuthorizationStatus) -> Void)?) {
        notificationsCenter.requestAuthorization(options: [.alert, .sound], completionHandler: { [weak self] _, _ in
            self?.notificationsCenter.getNotificationSettings { settings in
                DispatchQueue.main.async {
                    let result: NotificationsAuthorizationStatus
                    
                    switch settings.authorizationStatus {
                    case .authorized:
                        result = .authorized
                    case .notDetermined:
                        result = .notDetermined
                    default:
                        result = .denied
                    }
                    
                    handler?(result)
                    self?.delegates.forEach { $0.weak?.localNotificationsDidReceive(authorizationStatus: result) }
                }
            }
        })
    }
    
    func add(observer: LocalNotificationsDelegate) {
        let weakly = observer as AnyObject
        delegates.append(Weak<LocalNotificationsDelegate>(weakly))
        delegates = delegates.filter { $0.weak != nil }
    }
    
    func remove(observer: LocalNotificationsDelegate) {
        if let index = delegates.firstIndex(where: { $0.weak === observer }) {
            delegates.remove(at: index)
        }
    }
}

// MARK: UNUserNotificationCenterDelegate
extension LocalNotificationsManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        received(userInfo: response.notification.request.content.userInfo)
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        received(userInfo: notification.request.content.userInfo)
        
        completionHandler([])
    }
}

// MARK: Private
private extension LocalNotificationsManager {
    func received(userInfo: [AnyHashable : Any]) {
        let model = NotificationsModel(userInfo: userInfo)
        
        DispatchQueue.main.async { [weak self] in
            self?.delegates.forEach { $0.weak?.localNotificationsDidReceive(model: model) }
        }
    }
}
