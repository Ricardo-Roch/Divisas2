//
//  Divisas_2App.swift
//  Divisas 2
//
//  Created by Ricardo Rocha Moreno on 15/10/25.
//

import SwiftUI

@main
struct Divisas_2: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("appColorScheme") private var appColorScheme: AppColorScheme = .system

    var body: some Scene {
        WindowGroup {
            // Mostrar splash siempre que abra la app
            SplashView()
                .preferredColorScheme(appColorScheme.colorScheme)
        }
    }
    
    private func setupNotifications() {
        if notificationsEnabled {
            NotificationManager.shared.scheduleHourlyNotifications()
            
            // Enviar primera notificación inmediatamente
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                NotificationManager.shared.fetchAndNotifyRate()
            }
        }
    }
}
