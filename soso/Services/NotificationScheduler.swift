//
//  NotificationScheduler.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import UserNotifications

enum NotificationScheduler {
    private static let message = "오늘 나의 소소한 행복은 무엇이었나요?"
    private static let identifier = "soso_daily_happiness"
    
    /// 설정한 시·분에 매일 반복 알림 스케줄
    static func scheduleNotification(hour: Int = 9, minute: Int = 0) {
        // 기존 알림 제거 후 새로 등록 (중복 방지)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let content = UNMutableNotificationContent()
        content.title = "소소"
        content.body = message
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            #if DEBUG
            if let error = error {
                print("[소소] 알림 등록 실패: \(error)")
            } else {
                print("[소소] 알림 등록 완료: \(hour)시 \(minute)분")
            }
            #endif
        }
    }
    
    static func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - 테스트용 (배포 전 삭제)
    /// 5초 후 알림 발송. 테스트용이며 배포 전 삭제할 것.
    static func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "소소"
        content.body = message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "soso_test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
