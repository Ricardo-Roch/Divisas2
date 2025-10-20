//
//  CurrencyConverterViewModel.swift
//  HackDivisas
//

import SwiftUI
import Combine

@MainActor
class CurrencyConverterViewModel: ObservableObject {
    @Published var fromCurrency = Currency.usd
    @Published var toCurrency = Currency.mxn
    @Published var fromAmount = ""
    @Published var toAmount = ""
    @Published var exchangeRates: [String: Double] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var conversionHistory: [ConversionRecord] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadHistory()
        
        // Observar cambios en las monedas o el monto
        Publishers.CombineLatest3($fromCurrency, $toCurrency, $fromAmount)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _ in
                self?.convertCurrency()
            }
            .store(in: &cancellables)
    }
    
    func fetchExchangeRates() {
        guard let url = URL(string: "https://api.frankfurter.app/latest?from=\(fromCurrency.code)") else {
            errorMessage = "URL inválida"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ExchangeRateResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] response in
                self?.exchangeRates = response.rates
                self?.convertCurrency()
            }
            .store(in: &cancellables)
    }
    
    func convertCurrency() {
        guard !fromAmount.isEmpty,
              let amount = Double(fromAmount),
              let rate = getExchangeRate() else {
            toAmount = ""
            return
        }
        
        let converted = amount * rate
        toAmount = String(format: "%.2f", converted)
        
        // Guardar en historial
        saveToHistory(from: amount, to: converted, rate: rate)
    }
    
    func getExchangeRate() -> Double? {
        if fromCurrency.code == toCurrency.code {
            return 1.0
        }
        
        // Si tenemos las tasas desde fromCurrency
        if let rate = exchangeRates[toCurrency.code] {
            return rate
        }
        
        return nil
    }
    
    func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
        
        let tempAmount = fromAmount
        fromAmount = toAmount
        toAmount = tempAmount
        
        fetchExchangeRates()
    }
    
    func handleKeypadInput(_ key: CalculatorKey) {
        switch key {
        case .number(let num):
            if fromAmount.count < 15 {
                fromAmount += "\(num)"
            }
        case .decimal:
            if !fromAmount.contains(".") {
                fromAmount += fromAmount.isEmpty ? "0." : "."
            }
        case .delete:
            if !fromAmount.isEmpty {
                fromAmount.removeLast()
            }
        }
    }
    
    private func saveToHistory(from: Double, to: Double, rate: Double) {
        let record = ConversionRecord(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            fromAmount: from,
            toAmount: to,
            rate: rate,
            date: Date()
        )
        
        conversionHistory.insert(record, at: 0)
        
        // Mantener solo las últimas 20 conversiones
        if conversionHistory.count > 20 {
            conversionHistory = Array(conversionHistory.prefix(20))
        }
        
        saveHistory()
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(conversionHistory) {
            UserDefaults.standard.set(encoded, forKey: "conversionHistory")
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "conversionHistory"),
           let decoded = try? JSONDecoder().decode([ConversionRecord].self, from: data) {
            conversionHistory = decoded
        }
    }
}

// MARK: - Models
struct Currency: Identifiable, Hashable, Codable {
    let id = UUID()
    let code: String
    let name: String
    let flag: String
    
    static let popularCurrencies: [Currency] = [
        Currency(code: "USD", name: "Dólar estadounidense", flag: "🇺🇸"),
        Currency(code: "EUR", name: "Euro", flag: "🇪🇺"),
        Currency(code: "GBP", name: "Libra esterlina", flag: "🇬🇧"),
        Currency(code: "JPY", name: "Yen japonés", flag: "🇯🇵"),
        Currency(code: "MXN", name: "Peso mexicano", flag: "🇲🇽"),
        Currency(code: "CAD", name: "Dólar canadiense", flag: "🇨🇦"),
        Currency(code: "AUD", name: "Dólar australiano", flag: "🇦🇺"),
        Currency(code: "CHF", name: "Franco suizo", flag: "🇨🇭"),
        Currency(code: "CNY", name: "Yuan chino", flag: "🇨🇳"),
        Currency(code: "INR", name: "Rupia india", flag: "🇮🇳"),
        Currency(code: "BRL", name: "Real brasileño", flag: "🇧🇷"),
        Currency(code: "KRW", name: "Won surcoreano", flag: "🇰🇷"),
        Currency(code: "RUB", name: "Rublo ruso", flag: "🇷🇺"),
        Currency(code: "SGD", name: "Dólar singapurense", flag: "🇸🇬"),
        Currency(code: "HKD", name: "Dólar hongkonés", flag: "🇭🇰"),
        Currency(code: "NOK", name: "Corona noruega", flag: "🇳🇴"),
        Currency(code: "SEK", name: "Corona sueca", flag: "🇸🇪"),
        Currency(code: "TRY", name: "Lira turca", flag: "🇹🇷"),
        Currency(code: "ZAR", name: "Rand sudafricano", flag: "🇿🇦"),
        Currency(code: "NZD", name: "Dólar neozelandés", flag: "🇳🇿"),
        Currency(code: "DKK", name: "Corona danesa", flag: "🇩🇰"),
        Currency(code: "PLN", name: "Zloty polaco", flag: "🇵🇱"),
        Currency(code: "THB", name: "Baht tailandés", flag: "🇹🇭"),
        Currency(code: "MYR", name: "Ringgit malayo", flag: "🇲🇾"),
        Currency(code: "IDR", name: "Rupia indonesia", flag: "🇮🇩"),
        Currency(code: "CZK", name: "Corona checa", flag: "🇨🇿"),
        Currency(code: "HUF", name: "Florín húngaro", flag: "🇭🇺"),
        Currency(code: "ILS", name: "Nuevo séquel israelí", flag: "🇮🇱"),
        Currency(code: "CLP", name: "Peso chileno", flag: "🇨🇱"),
        Currency(code: "PHP", name: "Peso filipino", flag: "🇵🇭"),
        Currency(code: "AED", name: "Dírham emiratí", flag: "🇦🇪"),
        Currency(code: "COP", name: "Peso colombiano", flag: "🇨🇴"),
        Currency(code: "SAR", name: "Riyal saudí", flag: "🇸🇦"),
        Currency(code: "RON", name: "Leu rumano", flag: "🇷🇴"),
        Currency(code: "ARS", name: "Peso argentino", flag: "🇦🇷"),
        Currency(code: "EGP", name: "Libra egipcia", flag: "🇪🇬"),
        Currency(code: "VND", name: "Dong vietnamita", flag: "🇻🇳"),
        Currency(code: "BGN", name: "Lev búlgaro", flag: "🇧🇬"),
        Currency(code: "UAH", name: "Grivna ucraniana", flag: "🇺🇦"),
        Currency(code: "KES", name: "Chelín keniano", flag: "🇰🇪"),
        Currency(code: "NGN", name: "Naira nigeriana", flag: "🇳🇬"),
        Currency(code: "PEN", name: "Sol peruano", flag: "🇵🇪"),
        Currency(code: "ISK", name: "Corona islandesa", flag: "🇮🇸"),
        Currency(code: "TWD", name: "Nuevo dólar taiwanés", flag: "🇹🇼"),
        Currency(code: "PKR", name: "Rupia pakistaní", flag: "🇵🇰"),
        Currency(code: "QAR", name: "Riyal catarí", flag: "🇶🇦"),
        Currency(code: "KWD", name: "Dinar kuwaití", flag: "🇰🇼"),
        Currency(code: "BHD", name: "Dinar bahreiní", flag: "🇧🇭"),
        Currency(code: "OMR", name: "Rial omaní", flag: "🇴🇲"),
        Currency(code: "JOD", name: "Dinar jordano", flag: "🇯🇴")
    ]
    
    static let usd = popularCurrencies[0]
    static let mxn = popularCurrencies[4]
}

struct ExchangeRateResponse: Codable {
    let amount: Double
    let base: String
    let date: String
    let rates: [String: Double]
}

struct ConversionRecord: Identifiable, Codable {
    let id = UUID()
    let fromCurrency: Currency
    let toCurrency: Currency
    let fromAmount: Double
    let toAmount: Double
    let rate: Double
    let date: Date
}

// MARK: - Currency Picker View
struct CurrencyPickerView: View {
    @Binding var selectedCurrency: Currency
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    
    var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return Currency.popularCurrencies
        }
        return Currency.popularCurrencies.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                List(filteredCurrencies) { currency in
                    Button {
                        selectedCurrency = currency
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Text(currency.flag)
                                .font(.system(size: 32))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(currency.code)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.appTextPrimary)
                                
                                Text(currency.name)
                                    .font(.system(size: 13))
                                    .foregroundColor(.appTextSecondary)
                            }
                            
                            Spacer()
                            
                            if currency.code == selectedCurrency.code {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.appCardBackground)
                }
                .searchable(text: $searchText, prompt: "Buscar moneda")
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Seleccionar moneda")
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

// MARK: - Conversion History View
struct ConversionHistoryView: View {
    let history: [ConversionRecord]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var localizationManager = LocalizationManager3.shared // ← AGREGAR

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                if history.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 60))
                            .foregroundColor(.appTextSecondary)
                        
                        Text("no_history".localized()) // ← CAMBIAR
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                        
                        Text("conversions_appear_here".localized()) // ← CAMBIAR
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                    }
                } else {
                    List(history) { record in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(record.fromCurrency.flag)
                                Text(String(format: "%.2f", record.fromAmount))
                                    .font(.system(size: 16, weight: .semibold))
                                Text(record.fromCurrency.code)
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                                
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                                
                                Text(record.toCurrency.flag)
                                Text(String(format: "%.2f", record.toAmount))
                                    .font(.system(size: 16, weight: .semibold))
                                Text(record.toCurrency.code)
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                            }
                            .foregroundColor(.appTextPrimary)
                            
                            HStack {
                                Text("\("rate".localized()): \(String(format: "%.4f", record.rate))") // ← CAMBIAR
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                                
                                Spacer()
                                
                                Text(record.date, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.appCardBackground)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("history".localized()) // ← CAMBIAR
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("close".localized()) { // ← CAMBIAR
                        dismiss()
                    }
                    .foregroundColor(.appTextPrimary)
                }
            }
        }
    }
}
