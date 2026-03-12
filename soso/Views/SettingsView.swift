//
//  SettingsView.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: UserSettingsStore
    @State private var editingNickname = ""
    @State private var showNicknameEditor = false
    @State private var showPermissionAlert = false
    @State private var showTimePicker = false
    
    private let accentGreen = Color(red: 0.2, green: 0.6, blue: 0.35)
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        var components = DateComponents()
        components.hour = settings.notificationHour
        components.minute = settings.notificationMinute
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.98, blue: 0.95),
                        Color(red: 0.92, green: 0.97, blue: 0.93)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                List {
                    // 닉네임 섹션
                    Section {
                        HStack {
                            Text("닉네임")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(settings.nickname.isEmpty ? "설정하기" : settings.nickname)
                                .foregroundStyle(settings.nickname.isEmpty ? .secondary : .primary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingNickname = settings.nickname
                            showNicknameEditor = true
                        }
                    } header: {
                        Text("프로필")
                    }
                    .listRowBackground(Color.white.opacity(0.7))
                    
                    // 알림 섹션
                    Section {
                        Toggle("행복 기록 알림", isOn: Binding(
                            get: { settings.isNotificationEnabled },
                            set: { newValue in
                                if newValue {
                                    NotificationScheduler.requestAuthorization { granted in
                                        if granted {
                                            settings.isNotificationEnabled = true
                                        } else {
                                            showPermissionAlert = true
                                        }
                                    }
                                } else {
                                    settings.isNotificationEnabled = false
                                }
                            }
                        ))
                        .tint(accentGreen)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        
                        if settings.isNotificationEnabled {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text("알림 시간")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            showTimePicker.toggle()
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(formattedTime)
                                                .foregroundStyle(accentGreen)
                                            Image(systemName: "chevron.down")
                                                .font(.caption2)
                                                .foregroundStyle(accentGreen)
                                                .rotationEffect(.degrees(showTimePicker ? 180 : 0))
                                        }
                                        .font(.body)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .frame(height: 44)
                                
                                if showTimePicker {
                                    DatePicker("", selection: notificationTimeBinding, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.wheel)
                                        .labelsHidden()
                                        .frame(height: 120)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    } header: {
                        Text("알림")
                    } footer: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("매일 설정한 시간에 행복 기록을 알려드려요.")
                            Text("소소 작성은 설정한 알림시간으로부터 24시간 동안 한번만 작성이 가능합니다.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.7))
                    
                    // MARK: - 테스트용 (배포 전 삭제)
                    Section {
                        Button("5초 후 알림 테스트") {
                            NotificationScheduler.requestAuthorization { granted in
                                if granted {
                                    NotificationScheduler.scheduleTestNotification()
                                } else {
                                    showPermissionAlert = true
                                }
                            }
                        }
                        .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 0.35))
                    } header: {
                        Text("테스트")
                    } footer: {
                        Text("5초 후 알림이 옵니다. 배포 전 삭제할 섹션입니다.")
                    }
                    .listRowBackground(Color.white.opacity(0.7))
                }
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 44)
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showNicknameEditor) {
                NicknameEditSheet(
                    nickname: $editingNickname,
                    onSave: {
                        settings.updateNickname(editingNickname)
                        showNicknameEditor = false
                    },
                    onCancel: {
                        showNicknameEditor = false
                    }
                )
            }
            .alert("알림 권한", isPresented: $showPermissionAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("알림을 받으려면 설정에서 알림 권한을 허용해주세요.")
            }
        }
    }
    
    private var notificationTimeBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = settings.notificationHour
                components.minute = settings.notificationMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                settings.notificationHour = components.hour ?? 9
                settings.notificationMinute = components.minute ?? 0
            }
        )
    }
}

// MARK: - 닉네임 수정 시트
struct NicknameEditSheet: View {
    @Binding var nickname: String
    let onSave: () -> Void
    let onCancel: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TextField("닉네임을 입력하세요", text: $nickname)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .focused($isFocused)
                    .onAppear { isFocused = true }
                
                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("닉네임 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        onSave()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    SettingsView(settings: UserSettingsStore())
}
