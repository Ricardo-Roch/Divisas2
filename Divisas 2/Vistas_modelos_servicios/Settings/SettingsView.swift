//
//  SettingsView.swift
//  HackDivisas
//
//  Created by Yahir Fuentes on 14/10/25.
//

import SwiftUI

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

struct SettingsView: View {
    @AppStorage("appColorScheme") private var appColorScheme: AppColorScheme = .system
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Fondo adaptativo
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header con botón de regreso
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
                    
                    // Espaciador invisible para centrar el título
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                // Contenido
                Form {
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
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarHidden(true)
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

#Preview {
    SettingsView()
}
