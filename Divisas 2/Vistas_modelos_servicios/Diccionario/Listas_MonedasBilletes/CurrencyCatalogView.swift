//
//  CurrencyCatalogView.swift
//  Divisas 2
//
//  Created by Ricardo Rocha Moreno
//  Combina REST Countries + Numista API para catálogo con imágenes

import SwiftUI
import Combine

struct CurrencyCatalogView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    @StateObject private var viewModel = CurrencyCatalogViewModel()
    
    var filteredItems: [CountryItem] {
        var items = viewModel.countries
        
        if !searchText.isEmpty {
            items = items.filter { item in
                item.countryName.localizedCaseInsensitiveContains(searchText) ||
                item.currencyCode.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return items
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Home")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.appTextPrimary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Título
                HStack {
                    Text("Monedas del Mundo")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Barra de búsqueda
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.appTextSecondary)
                        .font(.system(size: 16))
                    
                    TextField("Buscar país o moneda", text: $searchText)
                        .foregroundColor(.appTextPrimary)
                        .font(.system(size: 16))
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.appTextSecondary)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.appCardBackground))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appTextSecondary.opacity(0.2), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Subtexto con contador de tokens
                HStack {
                    Text("Selecciona un país para ver sus monedas")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                    Spacer()
                    if viewModel.tokensUsed > 0 {
                        Text("Tokens: \(viewModel.tokensUsed)/2000")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Lista con loading
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Cargando países...")
                            .font(.system(size: 16))
                            .foregroundColor(.appTextSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else if viewModel.countries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.appTextSecondary)
                        Text("No se pudieron cargar los países")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                        Text("Verifica tu conexión e intenta nuevamente")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                        
                        Button(action: { viewModel.fetchCountries() }) {
                            Text("Reintentar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else if filteredItems.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.appTextSecondary)
                        Text("No se encontraron resultados")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                        Text("Intenta con otro término de búsqueda")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredItems) { item in
                                NavigationLink(destination: CurrencyDetailView(item: item, viewModel: viewModel)) {
                                    CountryCard(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchCountries()
        }
    }
}

// MARK: - Country Card
private struct CountryCard: View {
    let item: CountryItem
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Bandera
            Text(item.flag)
                .font(.system(size: 32))
                .frame(width: 50)
            
            // Contenido
            VStack(alignment: .leading, spacing: 4) {
                Text(item.countryName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(item.currencyCode)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "4275B6"))
                    
                    Text(item.currencyName)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.appTextSecondary)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.appCardBackground))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "4275B6").opacity(0.2), lineWidth: 1))
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Currency Detail View
private struct CurrencyDetailView: View {
    let item: CountryItem
    let viewModel: CurrencyCatalogViewModel
    @StateObject private var detailViewModel = CurrencyDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Card de información del país
                        VStack(spacing: 20) {
                            HStack {
                                Spacer()
                                VStack(alignment: .center, spacing: 8) {
                                    Text(item.flag)
                                        .font(.system(size: 60))
                                    Text(item.countryName)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.appTextPrimary)
                                }
                                Spacer()
                            }
                            
                            Divider()
                            
                            // Detalles de la moneda
                            VStack(alignment: .leading, spacing: 16) {
                                CharacteristicRow(icon: "dollarsign.circle", title: "Código", value: item.currencyCode)
                                CharacteristicRow(icon: "text.bubble", title: "Moneda", value: item.currencyName)
                                CharacteristicRow(icon: "symbol", title: "Símbolo", value: item.currencySymbol)
                            }
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.appCardBackground))
                        .padding(.horizontal, 20)
                        
                        // Monedas y Billetes
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Monedas y Billetes")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.appTextPrimary)
                                Spacer()
                            }
                            
                            if detailViewModel.isLoading {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 12) {
                                        ProgressView()
                                            .scaleEffect(1.2)
                                        Text("Cargando monedas...")
                                            .font(.system(size: 14))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    Spacer()
                                }
                                .frame(height: 150)
                            } else if detailViewModel.currencyItems.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.circle")
                                            .font(.system(size: 32))
                                            .foregroundColor(.appTextSecondary)
                                        Text("No hay monedas disponibles")
                                            .font(.system(size: 14))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    Spacer()
                                }
                                .frame(height: 120)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(detailViewModel.currencyItems) { item in
                                        CurrencyItemCard(item: item)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Conversión
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Conversión")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.appTextPrimary)
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "dollarsign.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "4275B6"))
                                    .frame(width: 28)
                                
                                Text("1 \(item.currencyCode)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.appTextPrimary)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    if detailViewModel.isConversionLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Text(detailViewModel.getConvertedValue(mxnValue: 1, currencyCode: item.currencyCode))
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.appTextPrimary)
                                    }
                                    
                                    Button(action: { detailViewModel.showCurrencyPicker = true }) {
                                        HStack(spacing: 4) {
                                            Text(detailViewModel.selectedCurrency.flag)
                                            Text(detailViewModel.selectedCurrency.code)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color(hex: "4275B6"))
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12, weight: .semibold))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: "4275B6").opacity(0.15)))
                                    }
                                }
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.appCardBackground))
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationTitle(item.currencyCode)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $detailViewModel.showCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $detailViewModel.selectedCurrency)
        }
        .onAppear {
            detailViewModel.fetchCurrencies(countryCode: item.countryCode, currencyCode: item.currencyCode)
            detailViewModel.fetchExchangeRates()
            viewModel.incrementTokenCount()
        }
    }
}

// MARK: - Currency Item Card
private struct CurrencyItemCard: View {
    let item: CurrencyItem
    @Environment(\.colorScheme) private var colorScheme
    
    var accentColor: Color {
        item.type == "coin" ? Color(hex: "9CA462") : Color(hex: "4275B6")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Imagen
            if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                    case .empty:
                        ProgressView()
                            .frame(height: 150)
                    default:
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(accentColor.opacity(0.1))
                            Image(systemName: "photo.slash")
                                .foregroundColor(accentColor)
                        }
                        .frame(height: 150)
                    }
                }
            }
            
            // Info
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.type == "coin" ? "centsign.circle.fill" : "banknote.fill")
                        .font(.system(size: 18))
                        .foregroundColor(accentColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(item.type == "coin" ? "Moneda" : "Billete")
                            .font(.system(size: 12))
                            .foregroundColor(.appTextSecondary)
                        
                        if let year = item.year {
                            Text("•")
                                .foregroundColor(.appTextSecondary)
                            Text(year)
                                .font(.system(size: 12))
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                }
                
                Spacer()
                
                if let value = item.nominalValue {
                    Text(value)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(accentColor)
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.appCardBackground))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(accentColor.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Characteristic Row
private struct CharacteristicRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "4275B6"))
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
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.appCardBackground.opacity(0.5)))
    }
}

// MARK: - Models
struct CountryItem: Identifiable {
    let id = UUID()
    let countryName: String
    let countryCode: String
    let currencyCode: String
    let currencyName: String
    let currencySymbol: String
    let flag: String
}

struct CurrencyItem: Identifiable {
    let id = UUID()
    let title: String
    let type: String // "coin" or "banknote"
    let imageUrl: String?
    let year: String?
    let nominalValue: String?
}

// MARK: - ViewModels
@MainActor
class CurrencyCatalogViewModel: ObservableObject {
    @Published var countries: [CountryItem] = []
    @Published var isLoading = false
    @Published var tokensUsed = 0
    
    func fetchCountries() {
        isLoading = true
        
        let fields = "name,cca2,currencies,flag"
        guard let url = URL(string: "https://restcountries.com/v3.1/all?fields=\(fields)") else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data else { return }
                
                do {
                    let countries = try JSONDecoder().decode([CountryResponse].self, from: data)
                    
                    self?.countries = countries.compactMap { country -> CountryItem? in
                        guard let currencyData = country.currencies?.first else { return nil }
                        
                        return CountryItem(
                            countryName: country.name.common,
                            countryCode: country.cca2,
                            currencyCode: currencyData.key,
                            currencyName: currencyData.value.name,
                            currencySymbol: currencyData.value.symbol ?? "",
                            flag: country.flag
                        )
                    }
                    .sorted { $0.countryName < $1.countryName }
                } catch {
                    print("Error decoding: \(error)")
                }
            }
        }.resume()
    }
    
    func incrementTokenCount() {
        tokensUsed += 1
    }
}

@MainActor
class CurrencyDetailViewModel: ObservableObject {
    @Published var currencyItems: [CurrencyItem] = []
    @Published var isLoading = false
    @Published var isConversionLoading = false
    @Published var selectedCurrency = Currency.usd
    @Published var exchangeRates: [String: Double] = [:]
    @Published var showCurrencyPicker = false
    
    private let numistApiKey = "LvIKqyJFqWBzElbdaxMPQ4KuNk9dkHAdw8JgCQ1j"
    
    func fetchCurrencies(countryCode: String, currencyCode: String) {
        isLoading = true
        
        // Primero obtenemos monedas
        let coinsUrlString = "https://api.numista.com/v3/types?category=coin&issuer=\(countryCode)&currency=\(currencyCode)&per_page=30"
        
        guard let coinsUrl = URL(string: coinsUrlString) else {
            isLoading = false
            return
        }
        
        var coinsRequest = URLRequest(url: coinsUrl)
        coinsRequest.setValue("Numista-API-Key \(numistApiKey)", forHTTPHeaderField: "Authorization")
        
        // Luego obtenemos billetes
        let banknotesUrlString = "https://api.numista.com/v3/types?category=banknote&issuer=\(countryCode)&currency=\(currencyCode)&per_page=30"
        
        guard let banknotesUrl = URL(string: banknotesUrlString) else {
            isLoading = false
            return
        }
        
        var banknotesRequest = URLRequest(url: banknotesUrl)
        banknotesRequest.setValue("Numista-API-Key \(numistApiKey)", forHTTPHeaderField: "Authorization")
        
        let group = DispatchGroup()
        var allItems: [CurrencyItem] = []
        
        // Fetch coins
        group.enter()
        URLSession.shared.dataTask(with: coinsRequest) { data, response, error in
            defer { group.leave() }
            
            guard let data = data else {
                print("No data for coins")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(NumistaResponse.self, from: data)
                let coins = response.entries.map { entry in
                    CurrencyItem(
                        title: entry.title,
                        type: "coin",
                        imageUrl: entry.picture_url,
                        year: entry.year != nil ? String(entry.year!) : nil,
                        nominalValue: entry.nominal_value
                    )
                }
                allItems.append(contentsOf: coins)
            } catch {
                print("Error decoding coins: \(error)")
            }
        }.resume()
        
        // Fetch banknotes
        group.enter()
        URLSession.shared.dataTask(with: banknotesRequest) { data, response, error in
            defer { group.leave() }
            
            guard let data = data else {
                print("No data for banknotes")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(NumistaResponse.self, from: data)
                let banknotes = response.entries.map { entry in
                    CurrencyItem(
                        title: entry.title,
                        type: "banknote",
                        imageUrl: entry.picture_url,
                        year: entry.year != nil ? String(entry.year!) : nil,
                        nominalValue: entry.nominal_value
                    )
                }
                allItems.append(contentsOf: banknotes)
            } catch {
                print("Error decoding banknotes: \(error)")
            }
        }.resume()
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.currencyItems = allItems.sorted { item1, item2 in
                // Ordenar por tipo (monedas primero) y luego por valor nominal
                if item1.type != item2.type {
                    return item1.type == "coin"
                }
                return (Double(item1.nominalValue ?? "0") ?? 0) < (Double(item2.nominalValue ?? "0") ?? 0)
            }
        }
    }
    
    func fetchExchangeRates() {
        isConversionLoading = true
        
        guard let url = URL(string: "https://api.frankfurter.app/latest?from=MXN") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isConversionLoading = false
                
                guard let data = data,
                      let response = try? JSONDecoder().decode(ExchangeRateResponse.self, from: data) else {
                    return
                }
                
                self?.exchangeRates = response.rates
            }
        }.resume()
    }
    
    func getConvertedValue(mxnValue: Double, currencyCode: String) -> String {
        if selectedCurrency.code == currencyCode {
            return String(format: "%.2f", mxnValue)
        }
        
        guard let rate = exchangeRates[selectedCurrency.code] else {
            return "..."
        }
        
        let converted = mxnValue * rate
        return String(format: "%.2f", converted)
    }
}

// MARK: - API Response Models
struct CountryResponse: Codable {
    let name: CountryName
    let cca2: String
    let currencies: [String: CurrencyData]?
    let flag: String
}

struct CountryName: Codable {
    let common: String
}

struct CurrencyData: Codable {
    let name: String
    let symbol: String?
}

struct NumistaResponse: Codable {
    let entries: [NumistaEntry]
}

struct NumistaEntry: Codable {
    let title: String
    let year: Int?
    let picture_url: String?
    let nominal_value: String?
}

struct ExchangeRateResponse2: Codable {
    let rates: [String: Double]
}

struct Currency2 {
    let code: String
    let flag: String
    let name: String
    
    static let usd = Currency2(code: "USD", flag: "🇺🇸", name: "Dólar estadounidense")
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CurrencyCatalogView()
    }
}
