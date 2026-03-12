//
//  HappinessStore.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import Foundation
import Combine

@MainActor
final class HappinessStore: ObservableObject {
    @Published private(set) var records: [HappinessRecord] = []
    
    private let userDefaultsKey = "happiness_records"
    
    init() {
        loadRecords()
    }
    
    func addRecord(_ content: String) {
        let record = HappinessRecord(content: content)
        records.append(record)
        saveRecords()
    }
    
    func hasRecordedToday(notificationHour: Int = 9, notificationMinute: Int = 0) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        // 알림 시간 기준으로 "오늘" 판단 (예: 09:30 설정 시 09:30~다음날 09:29가 한 하루)
        var dayStart = calendar.date(bySettingHour: notificationHour, minute: notificationMinute, second: 0, of: now)!
        if now < dayStart {
            dayStart = calendar.date(byAdding: .day, value: -1, to: dayStart)!
        }
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        
        return records.contains { record in
            record.createdAt >= dayStart && record.createdAt < dayEnd
        }
    }
    
    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([HappinessRecord].self, from: data) else {
            return
        }
        records = decoded
    }
    
    private func saveRecords() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
}
