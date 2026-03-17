//
//  HomeView.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var store: HappinessStore
    @ObservedObject var settings: UserSettingsStore
    @State private var showWriteScreen = false
    @State private var showCloverAnimation = false
    @State private var randomRecordForToday: HappinessRecord?
    @State private var pendingRandomRecord: HappinessRecord?
    
    // 유리병 흔들림 애니메이션
    @State private var bottleShakeAngle: Double = 0
    
    // 현재 모달이 오늘 첫 열람인지 여부
    @State private var isFirstRandomViewInModal: Bool = false
    
    // 여러 유리병 스와이프를 위한 상태
    @State private var currentBottleIndex: Int = 0
    @State private var didSetInitialBottleIndex: Bool = false
    
    private var cloverCount: Int {
        store.records.count
    }
    
    /// 전체 유리병 개수 (1병당 최대 100개 기록 보관)
    private var bottleCount: Int {
        max(1, Int(ceil(Double(cloverCount) / Double(BottleCloverLayout.maxClovers))))
    }
    
    /// 특정 유리병 인덱스에 해당하는 클로버 개수
    /// 0번 인덱스는 가장 오래된 병, 마지막 인덱스가 현재 진행 중인 병
    private func cloverCount(for bottleIndex: Int) -> Int {
        guard bottleIndex >= 0 else { return 0 }
        let start = bottleIndex * BottleCloverLayout.maxClovers
        guard start < cloverCount else { return 0 }
        let remaining = cloverCount - start
        return min(remaining, BottleCloverLayout.maxClovers)
    }
    
    private var canRecordToday: Bool {
        !store.hasRecordedToday(notificationHour: settings.notificationHour, notificationMinute: settings.notificationMinute)
    }
    
    private var canViewRandomToday: Bool {
        hasEnoughForRandom &&
        !store.hasViewedRandomToday(notificationHour: settings.notificationHour, notificationMinute: settings.notificationMinute)
    }
    
    /// 랜덤 열람이 가능한 최소 행복 개수 충족 여부 (10개 이상)
    /// - 규칙상 "가장 최근 유리병"에 담긴 행복이 10개 이상일 때만 허용
    private var hasEnoughForRandom: Bool {
        let lastBottleIndex = bottleCount - 1
        return cloverCount(for: lastBottleIndex) >= 10
    }
    
    var body: some View {
        ZStack {
            // 배경
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.98, blue: 0.95),
                    Color(red: 0.92, green: 0.97, blue: 0.93)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(settings.nickname.isEmpty ? "나의 행복" : "\(settings.nickname)님의 행복")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 0.2, green: 0.5, blue: 0.3))
                    .padding(.top, 52)
                
                // 병 영역 + 인디케이터 + 설명 + 주요 버튼을 한 블록으로 묶어서
                // 스와이프 시 상대적 위치가 최대한 고정되도록 구성
                VStack(spacing: 8) {
                    // 유리병 영역 + 인디케이터 (세로 위치 고정)
                    VStack(spacing: 2) {
                        // 여러 유리병 스와이프 (병 인덱스 기준)
                        TabView(selection: $currentBottleIndex) {
                            ForEach(0..<bottleCount, id: \.self) { index in
                                BottleView(
                                    cloverCount: cloverCount(for: index),
                                    showNewCloverAnimation: showCloverAnimation && index == bottleCount - 1,
                                    onAnimationComplete: {
                                        withAnimation {
                                            showCloverAnimation = false
                                        }
                                    }
                                )
                                .rotationEffect(.degrees(
                                    index == bottleCount - 1 ? bottleShakeAngle : 0
                                ))
                                .padding(.vertical, 20)
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: BottleCloverLayout.bottleHeight + 40, alignment: .top)
                        
                        // 현재 병 정보 (항상 같은 세로 위치)
                        Text("유리병 \(currentBottleIndex + 1) / \(bottleCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 간격1: 유리병 번호 ↔ 행복 개수 (조금 더 좁게)
                    Text("이 유리병에는 \(cloverCount(for: currentBottleIndex))개의 행복이 담겨 있어요.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // 간격2: 행복 개수 ↔ 버튼/안내 문구 (조금 더 넓게)
                    if currentBottleIndex == bottleCount - 1 {
                        if hasEnoughForRandom {
                            // 현재 진행 중인 병: 과거 행복 랜덤 열람 버튼
                            Button {
                                if canViewRandomToday {
                                    if let record = store.randomPastRecordExcludingToday(
                                        notificationHour: settings.notificationHour,
                                        notificationMinute: settings.notificationMinute
                                    ) {
                                        startShakeAndCloverAnimation(with: record)
                                    }
                                } else {
                                    if let record = store.latestRandomRecordForToday(
                                        notificationHour: settings.notificationHour,
                                        notificationMinute: settings.notificationMinute
                                    ) {
                                        isFirstRandomViewInModal = false
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                            randomRecordForToday = record
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if canViewRandomToday {
                                        Image(systemName: "sparkles")
                                        Text("소소한 행복 열람하기")
                                    } else {
                                        Image(systemName: "checkmark.circle")
                                        Text("오늘 행복 열람 완료")
                                    }
                                }
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.9))
                                .foregroundStyle(
                                    canViewRandomToday
                                    ? Color(red: 0.2, green: 0.6, blue: 0.35)
                                    : Color.secondary
                                )
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                            .padding(.top, 6)
                        } else {
                            // 10개 미만일 때는 버튼 대신 안내 문구
                            Text("행복을 10개 채우면 열람할 수 있어요")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.top, 6)
                        }
                    } else {
                        // 이전 병: 100개 전체 열람 버튼
                        Button {
                            // TODO: 이 병의 100개 전체 열람 화면 (P0-1-3)
                        } label: {
                            Text("전체 열람하기")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.9))
                                .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 0.35))
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .padding(.top, 6)
                    }
                }
                // 병 아래 텍스트/버튼 블록 전체 높이를 고정해서,
                // 병 간 스와이프 시 제목~버튼까지의 세로 위치가 변하지 않도록 함
                .frame(height: 140, alignment: .top)
                
                Spacer()
                
                // 하단 영역도 고정 높이로 맞춰서 스와이프 시 전체 레이아웃이 움직이지 않도록 처리
                VStack {
                    if currentBottleIndex == bottleCount - 1 {
                        if canRecordToday {
                            Button {
                                showWriteScreen = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("오늘의 행복 기록하기")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.2, green: 0.6, blue: 0.35))
                                .foregroundColor(.white)
                                .cornerRadius(14)
                            }
                        } else {
                            Text("오늘 행복 기록 완료")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        // 이전 병에서는 공간만 차지하도록 투명한 뷰 배치
                        Color.clear
                    }
                }
                .padding(.horizontal, 24)
                .frame(height: 72)
                .padding(.bottom, 28)
            }
            
            // 랜덤 행복 모달 오버레이 (시스템 바텀시트 대신 직접 오버레이)
            if let record = randomRecordForToday {
                RandomMemoryModal(
                    record: record,
                    onClose: {
                        if isFirstRandomViewInModal {
                            store.markRandomViewed(record)
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            randomRecordForToday = nil
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        // 앱을 처음 켰을 때는 항상 "가장 최근 유리병"부터 보여주도록 설정
        .onAppear {
            if !didSetInitialBottleIndex && bottleCount > 0 {
                currentBottleIndex = bottleCount - 1
                didSetInitialBottleIndex = true
            }
        }
        .sheet(isPresented: $showWriteScreen) {
            WriteScreen { content in
                store.addRecord(content)
                showWriteScreen = false
                // 첫 번째 유리병(100개)에 추가될 때만 떨어지는 애니메이션
                if store.records.count <= BottleCloverLayout.maxClovers {
                    showCloverAnimation = true
                }
            }
        }
    }
}

// MARK: - 랜덤 행복 쪽지 모달
struct RandomMemoryModal: View {
    let record: HappinessRecord
    let onClose: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: record.createdAt) + "의 행복"
    }
    
    var body: some View {
        ZStack {
            // 중앙 모달 카드
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 15) {
                    Text(formattedDate)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text(record.content.isEmpty ? "(내용 없음)" : record.content)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true) // 줄임표 없이 여러 줄 표시
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Spacer()
                    Button {
                        onClose()
                    } label: {
                        Text("닫기")
                            .font(.subheadline.weight(.semibold)) // 바디보다 살짝 작은 크기
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .foregroundStyle(.primary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 15)
            .frame(maxWidth: 280, minHeight: 180) // 최소 높이만 고정, 내용 길이에 따라 늘어남
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - 애니메이션 헬퍼
private extension HomeView {
    /// 유리병을 좌우로 흔든 뒤, 클로버가 유리병에서 모달 위치로 이동하는 애니메이션
    func startShakeAndCloverAnimation(with record: HappinessRecord) {
        pendingRandomRecord = record
        isFirstRandomViewInModal = true
        
        // 1) 병 흔들기 (섞는 느낌)
        let shakeKeyframes: [Double] = [-8, 8, -6, 6, -3, 3, 0]
        for (index, angle) in shakeKeyframes.enumerated() {
            let delay = 0.22 * Double(index)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.18)) {
                    bottleShakeAngle = angle
                }
            }
        }
        
        // 2) 병 흔들림이 끝난 후, 즉시 모달 등장
        let cloverStartDelay = 0.22 * Double(shakeKeyframes.count)
        DispatchQueue.main.asyncAfter(deadline: .now() + cloverStartDelay) {
            if let pending = pendingRandomRecord {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    randomRecordForToday = pending
                }
            }
            pendingRandomRecord = nil
        }
    }
}
