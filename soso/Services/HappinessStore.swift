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
    private let lastRandomViewKey = "last_random_view_date"
    private let lastRandomRecordIdKey = "last_random_record_id"
    
    @Published private(set) var lastRandomViewDate: Date?
    private var lastRandomRecordId: UUID?
    
    init() {
        #if DEBUG
        // 테스트용: 기존 데이터 리셋 후 더미 데이터 주입
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: lastRandomViewKey)
        UserDefaults.standard.removeObject(forKey: lastRandomRecordIdKey)
        records = []
        #else
        loadRecords()
        #endif
        loadLastRandomViewDate()
        loadLastRandomRecordId()
        
        #if DEBUG
        // 초기 테스트용 더미 데이터 (실제 배포 전 제거)
        if records.isEmpty {
            let calendar = Calendar.current
            let now = Date()
            // 200개의 더미 기록 생성 (모두 과거 날짜로 분산)
            for i in 1...200 {
                guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
                let dummyContent = "오늘도 작은 행복을 발견하며 마음을 천천히 들여다본 하루였다. 커피 한 잔, 햇살, 스쳐 간 미소까지 모두 소중하게 느껴졌다. 버스는 한번에 탈 수 있었고 수업이 휴강이라 좋았다."
                let record = HappinessRecord(content: dummyContent, createdAt: date)
                records.append(record)
            }
            saveRecords()
        }
        #endif
    }
    
    func addRecord(_ content: String) {
        let record = HappinessRecord(content: content)
        records.append(record)
        saveRecords()
    }
    
    /// 알림 시간 기준으로 \"오늘\" 이미 기록했는지 여부
    func hasRecordedToday(notificationHour: Int = 9, notificationMinute: Int = 0) -> Bool {
        let window = dayWindow(for: Date(), notificationHour: notificationHour, notificationMinute: notificationMinute)
        return records.contains { record in
            record.createdAt >= window.start && record.createdAt < window.end
        }
    }
    
    /// 오늘 랜덤 열람을 이미 했는지 여부
    func hasViewedRandomToday(notificationHour: Int = 9, notificationMinute: Int = 0) -> Bool {
        guard let lastRandomViewDate else { return false }
        let window = dayWindow(for: Date(), notificationHour: notificationHour, notificationMinute: notificationMinute)
        return lastRandomViewDate >= window.start && lastRandomViewDate < window.end
    }
    
    /// 오늘 기록을 제외한 과거 행복 중 하나를 랜덤으로 반환 (없으면 nil)
    func randomPastRecordExcludingToday(notificationHour: Int = 9, notificationMinute: Int = 0) -> HappinessRecord? {
        let window = dayWindow(for: Date(), notificationHour: notificationHour, notificationMinute: notificationMinute)
        
        let pastRecords = records.filter { record in
            !(record.createdAt >= window.start && record.createdAt < window.end)
        }
        
        guard !pastRecords.isEmpty else { return nil }
        let index = Int.random(in: 0..<pastRecords.count)
        return pastRecords[index]
    }
    
    /// 오늘 마지막으로 랜덤 열람한 행복이 있다면 반환 (오늘 하루 범위 안에서만)
    func latestRandomRecordForToday(notificationHour: Int = 9, notificationMinute: Int = 0) -> HappinessRecord? {
        guard let lastRandomViewDate,
              let lastRandomRecordId else { return nil }
        
        let window = dayWindow(for: Date(), notificationHour: notificationHour, notificationMinute: notificationMinute)
        guard lastRandomViewDate >= window.start && lastRandomViewDate < window.end else {
            return nil
        }
        
        return records.first(where: { $0.id == lastRandomRecordId })
    }
    
    /// 랜덤 열람을 완료했을 때 호출하여 \"오늘 열람 완료\" 상태로 표시
    func markRandomViewed(_ record: HappinessRecord) {
        lastRandomViewDate = Date()
        lastRandomRecordId = record.id
        saveLastRandomViewDate()
        saveLastRandomRecordId()
    }
    
    // MARK: - Persistence
    
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
    
    private func loadLastRandomViewDate() {
        lastRandomViewDate = UserDefaults.standard.object(forKey: lastRandomViewKey) as? Date
    }
    
    private func saveLastRandomViewDate() {
        UserDefaults.standard.set(lastRandomViewDate, forKey: lastRandomViewKey)
    }
    
    private func loadLastRandomRecordId() {
        if let idString = UserDefaults.standard.string(forKey: lastRandomRecordIdKey),
           let uuid = UUID(uuidString: idString) {
            lastRandomRecordId = uuid
        }
    }
    
    private func saveLastRandomRecordId() {
        if let id = lastRandomRecordId {
            UserDefaults.standard.set(id.uuidString, forKey: lastRandomRecordIdKey)
        } else {
            UserDefaults.standard.removeObject(forKey: lastRandomRecordIdKey)
        }
    }
    
    // MARK: - Day window helper
    
    /// 알림 시간을 기준으로 하루 구간(start~end)을 반환
    private func dayWindow(for date: Date, notificationHour: Int, notificationMinute: Int) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        var dayStart = calendar.date(bySettingHour: notificationHour, minute: notificationMinute, second: 0, of: date)!
        if date < dayStart {
            dayStart = calendar.date(byAdding: .day, value: -1, to: dayStart)!
        }
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        return (start: dayStart, end: dayEnd)
    }
}
