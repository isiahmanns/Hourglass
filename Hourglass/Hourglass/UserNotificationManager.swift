import UserNotifications

protocol NotificationManager {
    func fireNotification(_ notification: HourglassNotification, soundIsEnabled: Bool)
}
struct UserNotificationManager: NotificationManager {
    static let shared = UserNotificationManager(userNotificationCenter: .current())
    private let userNotificationCenter: UNUserNotificationCenter

    private init(userNotificationCenter: UNUserNotificationCenter) {
        self.userNotificationCenter = userNotificationCenter
        requestAuthorizationIfNeeded()
    }

    private func requestAuthorizationIfNeeded() {
        userNotificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                userNotificationCenter.requestAuthorization(options: [.sound])
                { granted, error in }
            }
        }
    }

    func fireNotification(_ notification: HourglassNotification,
                          soundIsEnabled: Bool) {
        let notificationContent = notification.contentBase
            .sound(soundIsEnabled ? .default : nil)

        let request = UNNotificationRequest(identifier: "",
                                            content: notificationContent,
                                            trigger: nil)

        userNotificationCenter.removeAllDeliveredNotifications()
        userNotificationCenter.add(request)
    }
}

class UserNotificationManagerMock: NotificationManager {
    var didFireNotification: Bool = false
    func fireNotification(_: HourglassNotification, soundIsEnabled: Bool) {
        didFireNotification = true
    }
}

extension UNMutableNotificationContent {
    func sound(_ value: UNNotificationSound?) -> Self {
        self.sound = value
        return self
    }
}
