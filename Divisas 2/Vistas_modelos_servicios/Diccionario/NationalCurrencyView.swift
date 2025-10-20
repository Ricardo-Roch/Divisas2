//
//  DictionaryView.swift
//  HackDivisas
//
//  Created by Yahir Fuentes on 15/10/25.
//



//Esta pantalla es donde se ven las 3 cards con los 3 paises para elegir



import SwiftUI

struct DictionaryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let headerHeightRatio: CGFloat = 0.33
    private let headerImageName = "DineroCanUsaMex"
    private var titleText: String {"national_currencies".localized()}
    private var subtitleText: String {"choose_currency".localized()}
    struct Currency: Identifiable {
        let id = UUID()
        let flag: String
        let name: String
        let currencyCode: String
        let currencyName: String
        let billsCount: Int
        let coinsCount: Int
        let accentColor: Color
    }
    
    let currencies: [Currency] = [
        Currency(
            flag: "🇲🇽",
            name: "Mexico",
            currencyCode: "MXN",
            currencyName: "mexican_peso".localized(),
            billsCount: 7,
            coinsCount: 5,
            accentColor: Color(hex: "9CA462")
        ),
        Currency(
            flag: "🇺🇸",
            name: "Estados Unidos",
            currencyCode: "USD",
            currencyName: "us_dollar".localized(),
            billsCount: 7,
            coinsCount: 6,
            accentColor: Color(hex: "4275B6")
        ),
        Currency(
            flag: "🇨🇦",
            name: "Canadá",
            currencyCode: "CAD",
            currencyName: "canadian_dollar".localized(),
            billsCount: 7,
            coinsCount: 6,
            accentColor: Color(hex: "FACB49")
        )
    ]
    
    var body: some View {
        GeometryReader { proxy in
            let headerHeight = proxy.size.height * headerHeightRatio
            
            ZStack {
                // Fondo adaptativo
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Section
                    ZStack(alignment: .topLeading) {
                        // Background Image with Overlay
                        Image(headerImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.width, height: headerHeight)
                            .clipped()
                            .overlay(
                                Color.black.opacity(colorScheme == .dark ? 0.50 : 0.35)
                            )
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(colorScheme == .dark ? 0.25 : 0.15),
                                        Color.black.opacity(colorScheme == .dark ? 0.45 : 0.35),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 0) {
                            // Back Button
                            Button(action: {
                                dismiss()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.leading, 4)
                            .padding(.top, 50)  // ⬅️ AGREGA ESTA LÍNEA

                            
                            Spacer()
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 8) {
                                Text(titleText)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                                
                                Text(subtitleText)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.95))
                                    .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 1)
                                    .lineLimit(2)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                    }
                    .frame(height: headerHeight)
                    .ignoresSafeArea(edges: .top)
                    
                    // Cards Section
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(currencies) { currency in
                                if currency.currencyCode == "MXN" {
                                    // Card de México va a MexicanCurrencySearchView
                                    NavigationLink(destination: MexCurrencySearchView()) {
                                        DictionaryCurrencyCard(currency: currency)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else if currency.currencyCode == "USD" {
                                    // Card de Estados Unidos va a USACurrencySearchView
                                    NavigationLink(destination: USACurrencyListView()) {
                                        DictionaryCurrencyCard(currency: currency)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    // Canadá
                                    NavigationLink(destination: CANCurrencyListView()) {
                                        DictionaryCurrencyCard(currency: currency)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Currency Card Component
private struct DictionaryCurrencyCard: View {
    let currency: DictionaryView.Currency
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Flag
            Text(currency.flag)
                .font(.system(size: 48))
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(currency.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                Text("\(currency.currencyName) (\(currency.currencyCode))")
                    .font(.system(size: 14))
                    .foregroundColor(currency.accentColor)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "banknote")
                            .font(.system(size: 14))
                        Text("\(currency.billsCount) billetes")
                            .font(.system(size: 14))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.circle")
                            .font(.system(size: 14))
                        Text("\(currency.coinsCount) monedas")
                            .font(.system(size: 14))
                    }
                }
                .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(currency.accentColor)
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(20)
        .frame(minHeight: 150)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(currency.accentColor.opacity(0.25), lineWidth: 1)
        )
        .shadow(
            color: colorScheme == .dark ?
                Color.black.opacity(0.35) :
                Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

// MARK: - Currency Detail View (Placeholder)
private struct CurrencyDetailView: View {
    let currency: DictionaryView.Currency
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack {
                Text(currency.flag)
                    .font(.system(size: 80))
                
                Text(currency.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)
                
                Text("Vista de Detalle - Próximamente")
                    .foregroundColor(.appTextSecondary)
            }
        }
        .navigationTitle(currency.name)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        DictionaryView()
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        DictionaryView()
            .preferredColorScheme(.dark)
    }
}
