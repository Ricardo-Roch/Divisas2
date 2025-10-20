//
//  HomeView.swift
//  Divisas
//
//  Created by Ricardo Rocha Moreno on 15/10/25.
//

import SwiftUI

struct HomeView: View {
    @State private var usdToMxnData: [DollarDataPoint] = []
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1) : UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1) })
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack(alignment: .center, spacing: 12) {
                        HStack(spacing: 8) {
                            Image("monetas")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            
                            Text("Moneta")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        NavigationLink(value: Route.settings) {
                            Image(systemName: "gearshape.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 20))
                                .frame(width: 40, height: 40)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    // Content
                    ScrollView(.vertical, showsIndicators: false) {
                        if isLandscape {
                            landscapeLayout()
                        } else {
                            portraitLayout()
                        }
                    }
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .settings:
                    SettingsView()
                case .calculator:
                    CurrencyConverterView()
                case .history:
                    Text("History").foregroundColor(.primary)
                case .markets:
                    MarketsView()
                case .nationalCurrency:
                    DictionaryView()
                case .identifier:
                    IdentificadorView()
                }
            }
        }
    }
    
    // Layout vertical (portrait)
    private func portraitLayout() -> some View {
        VStack(spacing: 16) {
            // Escáner
            NavigationLink(value: Route.identifier) {
                ModuleCard(
                    title: "Escáner",
                    subtitle: "Identifica billetes y monedas",
                    icon: "camera.fill",
                    accentColor: Color(red: 0.95, green: 0.35, blue: 0.35),
                    cta: "¡DESCÚBRELO AHORA!",
                    minHeight: 140
                )
            }
            .buttonStyle(.plain)
            
            // Grid 2x2
            HStack(spacing: 16) {
                NavigationLink(value: Route.nationalCurrency) {
                    ModuleCard(
                        title: "Divisa Nacional",
                        subtitle: "Conoce las monedas",
                        icon: "banknote.fill",
                        accentColor: Color(red: 0.65, green: 0.75, blue: 0.35),
                        minHeight: 140
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                
                NavigationLink(value: Route.markets) {
                    ModuleCard(
                        title: "Cambia tu dinero",
                        subtitle: "Todo lo que está cerca de ti",
                        icon: "map.fill",
                        accentColor: Color(red: 1.0, green: 0.85, blue: 0.15),
                        minHeight: 140
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
            
            // Conversor
            NavigationLink(value: Route.calculator) {
                ConverterCard(
                    title: "Convertidor",
                    subtitle: "Entre monedas",
                    icon: "dollarsign.circle.fill",
                    accentColor: Color(red: 0.3, green: 0.55, blue: 0.85),
                    minHeight: 160
                )
            }
            .buttonStyle(.plain)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // Layout horizontal (landscape)
    private func landscapeLayout() -> some View {
        HStack(spacing: 16) {
            // Columna izquierda
            VStack(spacing: 16) {
                NavigationLink(value: Route.identifier) {
                    ModuleCard(
                        title: "Escáner",
                        subtitle: "Identifica billetes",
                        icon: "camera.fill",
                        accentColor: Color(red: 0.95, green: 0.35, blue: 0.35),
                        minHeight: 100
                    )
                }
                .buttonStyle(.plain)
                .frame(maxHeight: .infinity)
                
                HStack(spacing: 16) {
                    NavigationLink(value: Route.nationalCurrency) {
                        ModuleCard(
                            title: "Divisa",
                            subtitle: "Conoce las monedas",
                            icon: "banknote.fill",
                            accentColor: Color(red: 0.65, green: 0.75, blue: 0.35),
                            minHeight: 80
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    
                    NavigationLink(value: Route.markets) {
                        ModuleCard(
                            title: "Cambia",
                            subtitle: "Ubicaciones",
                            icon: "map.fill",
                            accentColor: Color(red: 1.0, green: 0.85, blue: 0.15),
                            minHeight: 80
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Columna derecha - Conversor
            NavigationLink(value: Route.calculator) {
                ConverterCard(
                    title: "Convertidor",
                    subtitle: "Entre monedas",
                    icon: "dollarsign.circle.fill",
                    accentColor: Color(red: 0.3, green: 0.55, blue: 0.85),
                    minHeight: 200
                )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Models
struct DollarDataPoint: Identifiable {
    let id = UUID()
    let day: Int
    let rate: Double
}

// MARK: - Module Card
struct ModuleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    var cta: String?
    var minHeight: CGFloat = 120
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(accentColor)
            
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(accentColor)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white))
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.black.opacity(0.6))
                        .lineLimit(2)
                }
                
                if let cta = cta {
                    Spacer()
                    Text(cta)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(minHeight: minHeight)
        .frame(maxHeight: .infinity)
    }
}


// MARK: - Converter Card
struct ConverterCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    var minHeight: CGFloat = 160
    
    @State private var currentRate: Double = 18.0
    @State private var isLoading: Bool = true
    @State private var historicalData: [HistoricalDataPoint] = []
    @State private var selectedDateIndex: Int = 0
    @State private var showTooltip: Bool = false
    
    var selectedDate: String {
        guard !historicalData.isEmpty && selectedDateIndex < historicalData.count else {
            return "Hoy"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = Locale(identifier: "es_MX")
        return dateFormatter.string(from: historicalData[selectedDateIndex].date)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(accentColor)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(accentColor)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text(subtitle)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.black.opacity(0.6))
                    }
                    
                    Spacer()
                }
                
                if isLoading {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("USD/MXN")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.5))
                            
                            Spacer()
                            
                            ProgressView()
                                .tint(.black)
                        }
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 80)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("USD/MXN")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color.black.opacity(0.5))
                                Text(selectedDate)
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundColor(Color.black.opacity(0.4))
                            }
                            
                            Spacer()
                            
                            if !historicalData.isEmpty {
                                Text(String(format: "$%.2f", historicalData[selectedDateIndex].rate))
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        if !historicalData.isEmpty {
                            ZStack(alignment: .top) {
                                LineChart(
                                    data: historicalData.map { DollarDataPoint(day: 0, rate: $0.rate) },
                                    accentColor: .white,
                                    selectedIndex: $selectedDateIndex,
                                    showTooltip: $showTooltip
                                )
                                .frame(maxWidth: .infinity)
                                .frame(maxHeight: .infinity)
                                
                                // Tooltip
                                if showTooltip {
                                    GeometryReader { geometry in
                                        let stepX = geometry.size.width / CGFloat(max(historicalData.count - 1, 1))
                                        let x = CGFloat(selectedDateIndex) * stepX
                                        
                                        VStack(spacing: 4) {
                                            Text(selectedDate)
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(.black)
                                            Text(String(format: "$%.2f", historicalData[selectedDateIndex].rate))
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.black)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white)
                                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                        )
                                        .offset(x: min(max(x - 40, 0), geometry.size.width - 80), y: -50)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(minHeight: minHeight)
        .frame(maxHeight: .infinity)
        .onAppear {
            loadHistoricalData()
        }
    }
    
    private func loadHistoricalData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let today = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today
        
        let startDate = dateFormatter.string(from: thirtyDaysAgo)
        let endDate = dateFormatter.string(from: today)
        
        let urlString = "https://api.frankfurter.app/\(startDate)..\(endDate)?from=USD&to=MXN"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            generateFallbackHistoricalData()
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    generateFallbackHistoricalData()
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    generateFallbackHistoricalData()
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(FrankfurterResponse.self, from: data)
                
                DispatchQueue.main.async {
                    parseHistoricalData(from: result)
                }
            } catch {
                print("Error decoding: \(error)")
                DispatchQueue.main.async {
                    generateFallbackHistoricalData()
                }
            }
        }.resume()
    }
    
    private func parseHistoricalData(from response: FrankfurterResponse) {
        var data: [HistoricalDataPoint] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for (dateString, rates) in response.rates {
            if let date = dateFormatter.date(from: dateString),
               let mxnRate = rates["MXN"] {
                data.append(HistoricalDataPoint(date: date, rate: mxnRate))
            }
        }
        
        historicalData = data.sorted { $0.date < $1.date }
        
        if !historicalData.isEmpty {
            currentRate = historicalData.last?.rate ?? 18.0
            selectedDateIndex = historicalData.count - 1
        } else {
            generateFallbackHistoricalData()
        }
    }
    
    private func generateFallbackHistoricalData() {
        var data: [HistoricalDataPoint] = []
        let today = Date()
        
        for i in 0..<30 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: today) ?? today
            let rate = 18.0 + Double.random(in: -1.0...1.0)
            data.append(HistoricalDataPoint(date: date, rate: rate))
        }
        
        historicalData = data.reversed()
        selectedDateIndex = historicalData.count - 1
        currentRate = historicalData.last?.rate ?? 18.0
    }
}

// MARK: - Line Chart
struct LineChart: View {
    let data: [DollarDataPoint]
    let accentColor: Color
    @Binding var selectedIndex: Int
    @Binding var showTooltip: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let maxRate = data.map { $0.rate }.max() ?? 1
            let minRate = data.map { $0.rate }.min() ?? 0
            let range = max(maxRate - minRate, 0.1)
            
            ZStack(alignment: .bottom) {
                // Área bajo la línea
                Path { path in
                    guard !data.isEmpty else { return }
                    let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                    
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    
                    for (index, point) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalizedValue = (point.rate - minRate) / range
                        let y = geometry.size.height - (CGFloat(normalizedValue) * geometry.size.height)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [accentColor.opacity(0.3), accentColor.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Línea principal
                Path { path in
                    guard !data.isEmpty else { return }
                    let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                    
                    for (index, point) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalizedValue = (point.rate - minRate) / range
                        let y = geometry.size.height - (CGFloat(normalizedValue) * geometry.size.height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(accentColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                
                // Punto seleccionado
                if selectedIndex < data.count {
                    let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                    let x = CGFloat(selectedIndex) * stepX
                    let normalizedValue = (data[selectedIndex].rate - minRate) / range
                    let y = geometry.size.height - (CGFloat(normalizedValue) * geometry.size.height)
                    
                    ZStack {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 12, height: 12)
                        
                        Circle()
                            .stroke(accentColor.opacity(0.3), lineWidth: 8)
                            .frame(width: 12, height: 12)
                    }
                    .position(x: x, y: y)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                let tappedIndex = Int(round(location.x / stepX))
                selectedIndex = min(max(tappedIndex, 0), data.count - 1)
                
                showTooltip = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showTooltip = false
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                        let dragIndex = Int(round(value.location.x / stepX))
                        selectedIndex = min(max(dragIndex, 0), data.count - 1)
                        showTooltip = true
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showTooltip = false
                        }
                    }
            )
        }
    }
}


// MARK: - Historical Data Point
struct HistoricalDataPoint {
    let date: Date
    let rate: Double
}

// MARK: - Frankfurter Response
struct FrankfurterResponse: Codable {
    let amount: Double
    let base: String
    let startDate: String
    let endDate: String
    let rates: [String: [String: Double]]
    
    enum CodingKeys: String, CodingKey {
        case amount, base
        case startDate = "start_date"
        case endDate = "end_date"
        case rates
    }
}

// MARK: - Card Exchange Rate Data
struct CardExchangeRateData: Codable {
    let rates: [String: Double]
}
// MARK: - Routes
enum Route: Hashable {
    case settings
    case calculator
    case history
    case markets
    case nationalCurrency
    case identifier
}

#Preview {
    HomeView()
}
