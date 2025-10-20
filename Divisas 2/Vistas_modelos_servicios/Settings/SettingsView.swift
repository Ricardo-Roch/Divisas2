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
        case .light: return "light"
        case .dark: return "dark"
        case .system: return "system"
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
    
    @ObservedObject private var localizationManager = LocalizationManager3.shared
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var showNotificationAlert = false
    @State private var notificationPermissionDenied = false
    @State private var currentRate: Double = 0.0
    @State private var isLoadingRate = false
    @State private var showLanguagePicker = false
    
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
                    
                    Text("settings".localized())
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
                    // SECCIÓN: Idioma
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                
                                Text("language".localized())
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.appTextPrimary)
                                
                                Spacer()
                                
                                Button {
                                    showLanguagePicker = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Text(localizationManager.currentLanguage.flag)
                                            .font(.title3)
                                        Text(localizationManager.currentLanguage.displayName)
                                            .font(.subheadline)
                                            .foregroundColor(.appTextSecondary)
                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            
                            Text("language_desc".localized())
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
                    
                    // Sección de Apariencia
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("appearance".localized())
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            AppearanceSelector(selection: $appColorScheme)
                            
                            Text("appearance_desc".localized())
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
                                
                                Text("notifications".localized())
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
                                        Text("hourly_notification".localized())
                                            .font(.caption)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        Text("change_alert".localized())
                                            .font(.caption)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    
                                    if currentRate > 0 {
                                        HStack {
                                            Image(systemName: "dollarsign.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.caption)
                                            Text("\("current_rate".localized()): $\(String(format: "%.2f", currentRate)) MXN")
                                                .font(.caption.weight(.medium))
                                                .foregroundColor(.appTextPrimary)
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            
                            Text(notificationsEnabled ?
                                "notification_enabled_desc".localized() :
                                "notification_disabled_desc".localized())
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
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerView(selectedLanguage: $localizationManager.currentLanguage)
        }
        .alert("notification_permission".localized(), isPresented: $notificationPermissionDenied) {
            Button("open_settings".localized()) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("cancel".localized(), role: .cancel) {
                notificationsEnabled = false
            }
        } message: {
            Text("notification_permission_desc".localized())
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
            NotificationManager.shared.cancelAllNotifications()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    fetchCurrentRate()
                    NotificationManager.shared.scheduleHourlyNotifications()
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
}

// MARK: - Language Picker View
struct LanguagePickerView: View {
    @Binding var selectedLanguage: AppLanguage
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                List(AppLanguage.allCases, id: \.self) { language in
                    Button {
                        withAnimation {
                            selectedLanguage = language
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(language.flag)
                                .font(.system(size: 32))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(language.displayName)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.appTextPrimary)
                            }
                            
                            Spacer()
                            
                            if language == selectedLanguage {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20, weight: .semibold))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.appCardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("language".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("close".localized()) {
                        dismiss()
                    }
                    .foregroundColor(.appTextPrimary)
                }
            }
        }
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
                        Text(scheme.localizedKey.localized())
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
