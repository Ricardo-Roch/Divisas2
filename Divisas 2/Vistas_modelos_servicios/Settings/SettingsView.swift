//
//  SettingsView.swift
//  HackDivisas
//
//  Created by Yahir Fuentes on 14/10/25.
//

import SwiftUI
import UserNotifications

// MARK: - Enum para el esquema de color
enum AppColorScheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var localizedKey: String {
        switch self {
        case .light: return "Claro"
        case .dark: return "Oscuro"
        case .system: return "Sistema"
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("appColorScheme") private var appColorScheme: AppColorScheme = .system
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("lastKnownRate") private var lastKnownRate: Double = 0.0
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var showNotificationAlert = false
    @State private var notificationPermissionDenied = false
    @State private var currentRate: Double = 0.0
    @State private var isLoadingRate = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().strokeBorder(Color.appTextPrimary.opacity(0.1), lineWidth: 1))
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                        }
                        .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("Configuración")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                // Contenido
                Form {
                    // Sección de Apariencia
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Apariencia")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            AppearanceSelector(selection: $appColorScheme)
                            
                            Text("Elige cómo quieres ver la aplicación. El modo Sistema se adapta a la configuración de tu dispositivo.")
                                .font(.footnote)
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                            )
                    )
                    
                    // Sección de Notificaciones
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                
                                Text("Notificaciones de Tipo de Cambio")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.appTextPrimary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                                    .onChange(of: notificationsEnabled) { oldValue, newValue in
                                        handleNotificationToggle(newValue)
                                    }
                            }
                            
                            if notificationsEnabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("Notificación cada hora")
                                            .font(.caption)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        Text("Alerta con cambios mayores al 1%")
                                            .font(.caption)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    
                                    if currentRate > 0 {
                                        HStack {
                                            Image(systemName: "dollarsign.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.caption)
                                            Text("Tipo de cambio actual: $\(String(format: "%.2f", currentRate)) MXN")
                                                .font(.caption.weight(.medium))
                                                .foregroundColor(.appTextPrimary)
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            
                            Text(notificationsEnabled ?
                                "Recibirás notificaciones cada hora con el tipo de cambio USD/MXN actualizado." :
                                "Activa las notificaciones para recibir actualizaciones del tipo de cambio.")
                                .font(.footnote)
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarHidden(true)
        .alert("Permiso de Notificaciones", isPresented: $notificationPermissionDenied) {
            Button("Abrir Ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {
                notificationsEnabled = false
            }
        } message: {
            Text("Para recibir notificaciones del tipo de cambio, necesitas habilitar los permisos en Ajustes.")
        }
        .onAppear {
            if notificationsEnabled {
                fetchCurrentRate()
            }
        }
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            requestNotificationPermission()
        } else {
            cancelAllNotifications()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    fetchCurrentRate()
                    scheduleHourlyNotifications()
                } else {
                    notificationsEnabled = false
                    notificationPermissionDenied = true
                }
            }
        }
    }
    
    private func fetchCurrentRate() {
        isLoadingRate = true
        let urlString = "https://api.frankfurter.app/latest?from=USD&to=MXN"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    isLoadingRate = false
                }
            }
            
            guard let data = data, error == nil else { return }
            
            do {
                let result = try JSONDecoder().decode(FrankfurterLatestResponse.self, from: data)
                DispatchQueue.main.async {
                    if let rate = result.rates["MXN"] {
                        currentRate = rate
                        
                        // Guardar última tasa conocida
                        if lastKnownRate == 0 {
                            lastKnownRate = rate
                        }
                    }
                }
            } catch {
                print("Error decoding rate: \(error)")
            }
        }.resume()
    }
    
    private func scheduleHourlyNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // Notificación cada hora
        let content = UNMutableNotificationContent()
        content.title = "Tipo de Cambio USD/MXN"
        content.sound = .default
        
        // Trigger cada hora
        var dateComponents = DateComponents()
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "hourly-exchange-rate",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
        
        // Programar actualización inmediata
        scheduleImmediateRateCheck()
    }
    
    private func scheduleImmediateRateCheck() {
        // Usar Background Tasks o timer para verificar la tasa
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            checkRateAndNotify()
        }
    }
    
    private func checkRateAndNotify() {
        let urlString = "https://api.frankfurter.app/latest?from=USD&to=MXN"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let result = try JSONDecoder().decode(FrankfurterLatestResponse.self, from: data)
                if let rate = result.rates["MXN"] {
                    DispatchQueue.main.async {
                        sendNotification(for: rate)
                        lastKnownRate = rate
                    }
                }
            } catch {
                print("Error checking rate: \(error)")
            }
        }.resume()
    }
    
    private func sendNotification(for rate: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Tipo de Cambio USD/MXN"
        content.body = "1 USD = $\(String(format: "%.2f", rate)) MXN"
        content.sound = .default
        
        // Calcular cambio porcentual
        if lastKnownRate > 0 {
            let percentChange = ((rate - lastKnownRate) / lastKnownRate) * 100
            
            if abs(percentChange) >= 1.0 {
                let direction = percentChange > 0 ? "📈 Subió" : "📉 Bajó"
                content.subtitle = "\(direction) \(String(format: "%.2f", abs(percentChange)))%"
            }
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

// MARK: - Selector de Apariencia
private struct AppearanceSelector: View {
    @Binding var selection: AppColorScheme
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = scheme
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: scheme.icon)
                            .imageScale(.medium)
                        Text(scheme.localizedKey)
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundColor(foregroundColor(for: scheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(background(for: scheme))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(borderColor(for: scheme), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func isSelected(_ scheme: AppColorScheme) -> Bool {
        selection == scheme
    }
    
    private func background(for scheme: AppColorScheme) -> some ShapeStyle {
        if isSelected(scheme) {
            return AnyShapeStyle(colorScheme == .dark ?
                Color.white.opacity(0.15) :
                Color.white)
        } else {
            return AnyShapeStyle(Color.clear)
        }
    }
    
    private func borderColor(for scheme: AppColorScheme) -> Color {
        if isSelected(scheme) {
            return colorScheme == .dark ?
                Color.white.opacity(0.3) :
                Color.appTextPrimary.opacity(0.2)
        } else {
            return .clear
        }
    }
    
    private func foregroundColor(for scheme: AppColorScheme) -> Color {
        if isSelected(scheme) {
            return colorScheme == .dark ? .white : .black
        } else {
            return .appTextPrimary.opacity(0.6)
        }
    }
}

// MARK: - Frankfurter Latest Response
struct FrankfurterLatestResponse: Codable {
    let amount: Double
    let base: String
    let date: String
    let rates: [String: Double]
}

#Preview {
    SettingsView()
}
