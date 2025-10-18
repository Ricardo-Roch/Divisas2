//
//  Color+Extensions.swift
//  HackDivisas
//
//  Created by Yahir Fuentes
//

import SwiftUI

extension Color {
    // MARK: - Colores de fondo adaptativos
    static var appBackground: Color {
        Color(light: Color(hex: "ECE7E4"), dark: Color(hex: "292929"))
    }
    
    // MARK: - Colores de texto adaptativos
    static var appTextPrimary: Color {
        Color(light: .black, dark: .white)
    }
    
    static var appTextSecondary: Color {
        Color(light: Color.black.opacity(0.6), dark: Color.white.opacity(0.6))
    }
    
    // MARK: - Colores de las cards
    static var appCardBackground: Color {
        Color(light: Color.white.opacity(0.7), dark: Color(white: 0.15))
    }
    
    // MARK: - Colores de acento (para las cards de funciones)
    static let converterBlue = Color.blue
    static let historyGreen = Color(red: 0.4, green: 0.6, blue: 0.2)
    static let favoritesYellow = Color(red: 1.0, green: 0.85, blue: 0.2)
    static let dictionaryPurple = Color(red: 0.6, green: 0.4, blue: 0.8)
    static let marketsRed = Color(red: 1.0, green: 0.4, blue: 0.4)
    
    // MARK: - Inicializador para colores adaptativos
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(light: UIColor(light), dark: UIColor(dark)))
    }
    
    // MARK: - Inicializador desde HEX
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - UIColor Extension para soporte adaptativo
extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
}
