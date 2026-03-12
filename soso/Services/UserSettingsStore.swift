//
//  UserSettingsStore.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import Foundation
import Combine

@MainActor
final class UserSettingsStore: ObservableObject {
    @Published var nickname: String {
        didSet { UserDefaults.standard.set(nickname, forKey: Keys.nickname) }
    }
    
    @Published var notificationHour: Int {
        didSet {
            UserDefaults.standard.set(notificationHour, forKey: Keys.notificationHour)
            if isNotificationEnabled {
                NotificationScheduler.scheduleNotification(hour: notificationHour, minute: notificationMinute)
            }
        }
    }
    
    @Published var notificationMinute: Int {
        didSet {
            UserDefaults.standard.set(notificationMinute, forKey: Keys.notificationMinute)
            if isNotificationEnabled {
                NotificationScheduler.scheduleNotification(hour: notificationHour, minute: notificationMinute)
            }
        }
    }
    
    @Published var isNotificationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isNotificationEnabled, forKey: Keys.isNotificationEnabled)
            if isNotificationEnabled {
                NotificationScheduler.scheduleNotification(hour: notificationHour, minute: notificationMinute)
            } else {
                NotificationScheduler.cancelAllNotifications()
            }
        }
    }
    
    private enum Keys {
        static let nickname = "user_nickname"
        static let notificationHour = "notification_hour"
        static let notificationMinute = "notification_minute"
        static let isNotificationEnabled = "notification_enabled"
    }
    
    init() {
        self.nickname = UserDefaults.standard.string(forKey: Keys.nickname) ?? ""
        self.notificationHour = UserDefaults.standard.object(forKey: Keys.notificationHour) as? Int ?? 9
        self.notificationMinute = UserDefaults.standard.object(forKey: Keys.notificationMinute) as? Int ?? 0
        self.isNotificationEnabled = UserDefaults.standard.object(forKey: Keys.isNotificationEnabled) as? Bool ?? true
    }
    
    func updateNickname(_ newNickname: String) {
        nickname = newNickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
