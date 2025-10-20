//
//  MexicanCoinDetailView.swift
//  HackDivisas
//
//  Created by Yahir Fuentes
//


//Esta pantalla es donde se ven los detalles de la moneda o billete que hayas seleccionado. En este caso nomas hice la moneda de 10 centavos por ahora

import SwiftUI
import Combine

struct MexicanCoinDetailView: View {
    let item: MexCurrencySearchView.CurrencyItem
    @StateObject private var viewModel = CoinDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentImageIndex = 0
    @State private var showInfoPopup = false
    
    // Configuración de imágenes por denominación
    var coinImages: [String] {
        if item.type == .bill {
            switch item.value {
            case "20":
                return ["MX_20B_frente", "MX_20B_reverso", "MX_20BV_reverso", "MX_20BV_reverso"]
            case "50":
                return ["MX_50B_frente", "MX_50B_reverso", "MX_50BV_reverso", "MX_50BV_reverso"]
            case "100":
                return ["MX_100B_frente", "MX_100B_reverso", "MX_100BV_reverso", "MX_100BV_reverso"]
            case "200":
                return ["MX_200B_frente", "MX_200B_reverso", "MX_200BV_reverso", "MX_200BV_reverso"]
            case "500":
                return ["MX_500B_frente", "MX_500B_reverso", "MX_500BV_reverso", "MX_500BV_reverso"]
            case "1000":
                return ["MX_1000B_frente", "MX_1000B_reverso"]
            default:
                return ["placeholder_frente", "placeholder_reverso", "placeholder_lateral1", "placeholder_lateral2"]
            }
        } else {
            switch item.value {
            case "0.10":
                return ["MX_10C_frente", "MX_10C_reverso"]
            case "0.20":
                return ["MX_20C_frente", "MX_20C_reverso"]
            case "0.50":
                return ["MX_50C_frente", "MX_50C_reverso"]
            case "1":
                return ["MX_1P_frente", "MX_1P_reverso"]
            case "2":
                return ["MX_2P_frente", "MX_2P_reverso"]
            case "5":
                return ["MX_5P_frente", "MX_5P_reverso"]
            case "10":
                return ["MX_10P_frente", "MX_10P_reverso"]
            case "20":
                return ["MX_20P_frente", "MX_20P_reverso"]
            default:
                return ["placeholder_frente", "placeholder_reverso", "placeholder_lateral1", "placeholder_lateral2"]
            }
        }
    }
    
    var coinInfo: CoinInfo {
        if item.type == .bill {
            switch item.value {
            case "20": return CoinInfo(years: "2018-presente", description: "Billete de $20 pesos conmemorativo y polímero (serie actual).")
            case "50": return CoinInfo(years: "2021-presente", description: "Billete de $50 pesos de la familia G con motivos axolote y Xochimilco.")
            case "100": return CoinInfo(years: "2020-presente", description: "Billete de $100 pesos de la familia G con Sor Juana Inés de la Cruz.")
            case "200": return CoinInfo(years: "2019-presente", description: "Billete de $200 pesos de la familia G con Hidalgo y Morelos.")
            case "500": return CoinInfo(years: "2018-presente", description: "Billete de $500 pesos de la familia G con Benito Juárez.")
            case "1000": return CoinInfo(years: "2020-presente", description: "Billete de $1000 pesos de la familia G con la Revolución Mexicana.")
            default: return CoinInfo(years: "N/A", description: "Información no disponible.")
            }
        } else {
            switch item.value {
            case "0.10": return CoinInfo(years: "2009-2019", description: "Moneda de 10 centavos fabricada en acero inoxidable. Presenta el Escudo Nacional en el anverso.")
            case "0.20": return CoinInfo(years: "2009-2019", description: "Moneda de 20 centavos con diseño moderno y material resistente.")
            case "0.50": return CoinInfo(years: "1992-presente", description: "Moneda de 50 centavos con centro de bronce-aluminio y anillo de acero inoxidable.")
            case "1": return CoinInfo(years: "1996-presente", description: "Moneda de 1 peso bimetálica, con núcleo de bronce-aluminio y anillo de acero inoxidable.")
            case "2": return CoinInfo(years: "1996-presente", description: "Moneda de 2 pesos bimetálica con diseño distintivo del Escudo Nacional.")
            case "5": return CoinInfo(years: "1997-presente", description: "Moneda de 5 pesos bimetálica, una de las más usadas en circulación.")
            case "10": return CoinInfo(years: "1997-presente", description: "Moneda de 10 pesos bimetálica con centro de bronce-aluminio.")
            case "20": return CoinInfo(years: "1993-presente", description: "Moneda conmemorativa de 20 pesos con diversos diseños según el año de emisión.")
            default: return CoinInfo(years: "N/A", description: "Información no disponible.")
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Carrusel de imágenes
                    TabView(selection: $currentImageIndex) {
                        ForEach(0..<coinImages.count, id: \.self) { index in
                            Image(coinImages[index])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 280)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.appCardBackground)
                                )
                                .tag(index)
                        }
                    }
                    .frame(height: 300)
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    // Sección de Características
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Características")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.appTextPrimary)
                            
                            Spacer()
                            
                            // Botón de información
                            Button(action: {
                                showInfoPopup = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "9CA462").opacity(0.15))
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "questionmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(hex: "9CA462"))
                                }
                            }
                        }
                        
                        // Emisor
                        CharacteristicRow(
                            icon: "mappin.and.ellipse",
                            title: "Emisor",
                            value: "México"
                        )
                        
                        // Años
                        CharacteristicRow(
                            icon: "calendar",
                            title: "Años",
                            value: coinInfo.years
                        )
                        
                        // Valor con conversión
                        HStack(spacing: 12) {
                            Image(systemName: "dollarsign.circle")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "9CA462"))
                                .frame(width: 28)
                            
                            Text("Valor")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.appTextPrimary)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Text(viewModel.getConvertedValue(mxnValue: Double(item.value) ?? 0))
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.appTextPrimary)
                                }
                                
                                // Selector de moneda
                                Button(action: {
                                    viewModel.showCurrencyPicker = true
                                }) {
                                    HStack(spacing: 4) {
                                        Text(viewModel.selectedCurrency.flag)
                                            .font(.system(size: 16))
                                        Text(viewModel.selectedCurrency.code)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "9CA462"))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(hex: "9CA462"))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: "9CA462").opacity(0.15))
                                    )
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appCardBackground)
                        )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appCardBackground)
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(item.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $viewModel.selectedCurrency)
        }
        .sheet(isPresented: $showInfoPopup) {
            CoinInfoPopup(item: item, info: coinInfo)
        }
        .onAppear {
            viewModel.fetchExchangeRates()
        }
    }
}

// MARK: - Characteristic Row Component
private struct CharacteristicRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "9CA462"))
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appTextPrimary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appCardBackground)
        )
    }
}

// MARK: - Coin Info Popup
private struct CoinInfoPopup: View {
    let item: MexCurrencySearchView.CurrencyItem
    let info: CoinInfo
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Icono grande
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "9CA462").opacity(0.15))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(hex: "9CA462"))
                            }
                            Spacer()
                        }
                        .padding(.top, 20)
                        
                        // Título
                        Text(item.displayName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        // Descripción
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Descripción")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            Text(info.description)
                                .font(.system(size: 15))
                                .foregroundColor(.appTextSecondary)
                                .lineSpacing(4)
                        }
                        
                        // Detalles adicionales
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Detalles")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            DetailRow(label: "Valor nominal", value: "$\(item.value) MXN")
                            DetailRow(label: "Período", value: info.years)
                            DetailRow(label: "País emisor", value: "México 🇲🇽")
                            DetailRow(label: "Tipo", value: item.type == .coin ? "Moneda" : "Billete")
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appCardBackground)
                        )
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Información")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.appTextPrimary)
                }
            }
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.appTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.appTextPrimary)
        }
    }
}

// MARK: - Models
struct CoinInfo {
    let years: String
    let description: String
}

// MARK: - ViewModel
@MainActor
class CoinDetailViewModel: ObservableObject {
    @Published var selectedCurrency = Currency.usd
    @Published var exchangeRates: [String: Double] = [:]
    @Published var isLoading = false
    @Published var showCurrencyPicker = false
    
    func fetchExchangeRates() {
        guard let url = URL(string: "https://api.frankfurter.app/latest?from=MXN") else {
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data,
                      let response = try? JSONDecoder().decode(ExchangeRateResponse.self, from: data) else {
                    return
                }
                
                self?.exchangeRates = response.rates
            }
        }.resume()
    }
    
    func getConvertedValue(mxnValue: Double) -> String {
        if selectedCurrency.code == "MXN" {
            return String(format: "%.2f", mxnValue)
        }
        
        guard let rate = exchangeRates[selectedCurrency.code] else {
            return "..."
        }
        
        let converted = mxnValue * rate
        return String(format: "%.2f", converted)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MexicanCoinDetailView(
            item: MexCurrencySearchView.CurrencyItem(
                type: .coin,
                value: "0.10",
                displayName: "Moneda de 10 centavos mexicanos",
                icon: "bitcoinsign.circle.fill"
            )
        )
    }
}
