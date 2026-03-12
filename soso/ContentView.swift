//
//  ContentView.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var happinessStore = HappinessStore()
    @StateObject private var settingsStore = UserSettingsStore()
    
    var body: some View {
        TabView {
            HomeView(store: happinessStore, settings: settingsStore)
                .tabItem {
                    Label("홈", systemImage: "leaf.fill")
                }
            
            SettingsView(settings: settingsStore)
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
        }
        .tint(Color(red: 0.2, green: 0.6, blue: 0.35))
        .onAppear {
            NotificationScheduler.requestAuthorization { granted in
                if granted && settingsStore.isNotificationEnabled {
                    NotificationScheduler.scheduleNotification(
                        hour: settingsStore.notificationHour,
                        minute: settingsStore.notificationMinute
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
