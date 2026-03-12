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
    
    private var cloverCount: Int {
        store.records.count
    }
    
    private var canRecordToday: Bool {
        !store.hasRecordedToday(notificationHour: settings.notificationHour, notificationMinute: settings.notificationMinute)
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
                    .padding(.top, 20)
                
                // 유리병
                BottleView(
                    cloverCount: cloverCount,
                    showNewCloverAnimation: showCloverAnimation,
                    onAnimationComplete: {
                        withAnimation {
                            showCloverAnimation = false
                        }
                    }
                )
                .padding(.vertical, 20)
                
                // 클로버 개수
                Text("\(cloverCount)개의 행복")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // 행복 기록 버튼
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
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                } else {
                    Text("오늘의 행복을 이미 기록했어요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 40)
                }
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
