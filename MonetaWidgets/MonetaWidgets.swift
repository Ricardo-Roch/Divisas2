import WidgetKit
import SwiftUI

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

// MARK: - Widget Entry
struct ConverterEntry: TimelineEntry {
    let date: Date
    let currentRate: Double
    let historicalData: [HistoricalDataPoint]
    let isPlaceholder: Bool
}

// MARK: - Widget Provider
struct ConverterProvider: TimelineProvider {
    func placeholder(in context: Context) -> ConverterEntry {
        ConverterEntry(
            date: Date(),
            currentRate: 18.41,
            historicalData: generatePlaceholderData(),
            isPlaceholder: true
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ConverterEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            fetchExchangeRate { entry in
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ConverterEntry>) -> Void) {
        fetchExchangeRate { entry in
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    private func fetchExchangeRate(completion: @escaping (ConverterEntry) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let today = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today
        
        let startDate = dateFormatter.string(from: thirtyDaysAgo)
        let endDate = dateFormatter.string(from: today)
        
        let urlString = "https://api.frankfurter.app/\(startDate)..\(endDate)?from=USD&to=MXN"
        
        guard let url = URL(string: urlString) else {
            completion(createFallbackEntry())
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(createFallbackEntry())
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(FrankfurterResponse.self, from: data)
                let entry = parseResponse(result)
                completion(entry)
            } catch {
                completion(createFallbackEntry())
            }
        }.resume()
    }
    
    private func parseResponse(_ response: FrankfurterResponse) -> ConverterEntry {
        var data: [HistoricalDataPoint] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for (dateString, rates) in response.rates {
            if let date = dateFormatter.date(from: dateString),
               let mxnRate = rates["MXN"] {
                data.append(HistoricalDataPoint(date: date, rate: mxnRate))
            }
        }
        
        data.sort { $0.date < $1.date }
        let currentRate = data.last?.rate ?? 18.41
        
        return ConverterEntry(
            date: Date(),
            currentRate: currentRate,
            historicalData: data,
            isPlaceholder: false
        )
    }
    
    private func createFallbackEntry() -> ConverterEntry {
        ConverterEntry(
            date: Date(),
            currentRate: 18.41,
            historicalData: generatePlaceholderData(),
            isPlaceholder: false
        )
    }
    
    private func generatePlaceholderData() -> [HistoricalDataPoint] {
        var data: [HistoricalDataPoint] = []
        let today = Date()
        
        for i in 0..<30 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: today) ?? today
            let rate = 18.41 + Double.random(in: -0.8...0.8)
            data.append(HistoricalDataPoint(date: date, rate: rate))
        }
        
        return data.reversed()
    }
}

// MARK: - Widget View
struct ConverterWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: ConverterEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let entry: ConverterEntry
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header muy compacto - solo ícono
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "dollarsign")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.55, blue: 0.85))
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            Spacer(minLength: 8)
            
            // Info y precio
            VStack(alignment: .leading, spacing: 4) {
                Text("USD/MXN")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(formattedDate)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(String(format: "$%.2f", entry.currentRate))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            
            Spacer(minLength: 8)
            
            // Chart
            if !entry.historicalData.isEmpty {
                MiniLineChart(data: entry.historicalData)
                    .frame(height: 45)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
        }
        .containerBackground(Color(red: 0.3, green: 0.55, blue: 0.85), for: .widget)
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let entry: ConverterEntry
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(red: 0.3, green: 0.55, blue: 0.85))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Convertidor")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Entre monedas")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Spacer()
            
            // Content
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("USD/MXN")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(formattedDate)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Text(String(format: "$%.2f", entry.currentRate))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            
            // Chart
            if !entry.historicalData.isEmpty {
                MiniLineChart(data: entry.historicalData)
                    .frame(height: 50)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .containerBackground(Color(red: 0.3, green: 0.55, blue: 0.85), for: .widget)
    }
}

// MARK: - Large Widget
struct LargeWidgetView: View {
    let entry: ConverterEntry
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(Color(red: 0.3, green: 0.55, blue: 0.85))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Convertidor")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Entre monedas")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("USD/MXN")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(formattedDate)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(String(format: "$%.2f", entry.currentRate))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Chart
            if !entry.historicalData.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    MiniLineChart(data: entry.historicalData)
                        .frame(height: 100)
                    
                    Text("Últimos 30 días")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .containerBackground(Color(red: 0.3, green: 0.55, blue: 0.85), for: .widget)
    }
}

// MARK: - Mini Line Chart
struct MiniLineChart: View {
    let data: [HistoricalDataPoint]
    
    var body: some View {
        GeometryReader { geometry in
            let maxRate = data.map { $0.rate }.max() ?? 1
            let minRate = data.map { $0.rate }.min() ?? 0
            let range = max(maxRate - minRate, 0.1)
            
            ZStack(alignment: .bottom) {
                // Línea con punto al final
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
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                
                // Punto al final
                if !data.isEmpty {
                    let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                    let lastIndex = data.count - 1
                    let x = CGFloat(lastIndex) * stepX
                    let normalizedValue = (data[lastIndex].rate - minRate) / range
                    let y = geometry.size.height - (CGFloat(normalizedValue) * geometry.size.height)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

// MARK: - Widget Configuration
struct ConverterWidget: Widget {
    let kind: String = "ConverterWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ConverterProvider()) { entry in
            ConverterWidgetView(entry: entry)
        }
        .configurationDisplayName("Conversor USD/MXN")
        .description("Muestra el tipo de cambio actual y su historial de 30 días")
        .supportedFamilies([ .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle
@main
struct MonetaWidgets: WidgetBundle {
    var body: some Widget {
        ConverterWidget()
    }
}
