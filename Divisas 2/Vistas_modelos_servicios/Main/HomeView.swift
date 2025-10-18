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
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.appBackground, Color.appBackground.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack(alignment: .center, spacing: 12) {
                        HStack(spacing: 6) {
                            Image("divcash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 51, height: 51)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            
                            Text("Divcash")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        
                        Spacer()

                        NavigationLink(value: Route.settings) {
                            Image(systemName: "gearshape.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.appTextPrimary)
                                .font(.system(size: 22, weight: .semibold))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    .background(Color.appBackground)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // 1. Escáner - Card grande
                            NavigationLink(value: Route.identifier) {
                                LargeHeaderCard(
                                    title: "Escáner",
                                    subtitle: "Identifica billetes y monedas",
                                    icon: "camera.fill",
                                    accentColor: Color(red: 0.95, green: 0.35, blue: 0.35)
                                )
                                .frame(height: 160)
                            }
                            .buttonStyle(.plain)

                            // 2 y 3. Divisa nacional y Cambia tu dinero - Row
                            HStack(spacing: 16) {
                                NavigationLink(value: Route.nationalCurrency) {
                                    CompactGlassCard(
                                        title: "Divisa\nnacional",
                                        subtitle: "Elige la moneda de tu preferencia",
                                        icon: "banknote.fill",
                                        accentColor: .historyGreen,
                                        height: 200
                                    )
                                }
                                .buttonStyle(.plain)

                                NavigationLink(value: Route.markets) {
                                    CompactGlassCard(
                                        title: "Cambia\ntu dinero",
                                        subtitle: "Encuentra las ubicaciones\nmás cercanas",
                                        icon: "map.fill",
                                        accentColor: .favoritesYellow,
                                        height: 200
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            // 4. Conversor - Card grande con gráfica
                            NavigationLink(value: Route.calculator) {
                                ConverterCardWithChart(
                                    title: "Conversor",
                                    subtitle: "Convierte entre monedas",
                                    icon: "dollarsign.circle.fill",
                                    accentColor: .converterBlue,
                                    data: usdToMxnData
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
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
                    Text("History")
                        .foregroundColor(.appTextPrimary)
                case .markets:
                    MarketsView()
                case .nationalCurrency:
                    DictionaryView()
                case .identifier:
                    IdentificadorView()
                }
            }
            .onAppear {
                loadDollarData()
            }
        }
    }
    
    private func loadDollarData() {
        let baseRate = 17.8
        usdToMxnData = (0..<30).map { day in
            DollarDataPoint(
                day: day,
                rate: baseRate + Double.random(in: -0.3...0.6)
            )
        }
    }
}

// MARK: - Models
struct DollarDataPoint: Identifiable {
    let id = UUID()
    let day: Int
    let rate: Double
}

// MARK: - Large Header Card (Escáner)
struct LargeHeaderCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: accentColor.opacity(0.4), radius: 20, x: 0, y: 10)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("¡Mira lo que vale!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                Spacer(minLength: 0)
            }
            .padding(20)
        }
    }
}

// MARK: - Compact Glass Card
struct CompactGlassCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let height: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: accentColor.opacity(0.4), radius: 15, x: 0, y: 8)
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(20)
        }
        .frame(height: height)
    }
}

// MARK: - Converter Card with Chart
struct ConverterCardWithChart: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let data: [DollarDataPoint]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: accentColor.opacity(0.4), radius: 20, x: 0, y: 10)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                // Gráfica del dólar
                if !data.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("USD/MXN")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                            
                            Spacer()
                            
                            if let lastRate = data.last?.rate {
                                Text(String(format: "$%.2f", lastRate))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        ImprovedLineChart(data: data)
                            .frame(height: 100)
                    }
                    .padding(.top, 4)
                }
                
                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .frame(height: 280)
    }
}

// MARK: - Line Chart
struct ImprovedLineChart: View {
    let data: [DollarDataPoint]
    
    var body: some View {
        GeometryReader { geometry in
            let maxRate = data.map { $0.rate }.max() ?? 1
            let minRate = data.map { $0.rate }.min() ?? 0
            let range = max(maxRate - minRate, 0.1)
            
            ZStack(alignment: .bottom) {
                // Grid de fondo
                VStack(spacing: 0) {
                    ForEach(0..<4) { _ in
                        Divider()
                            .background(Color.white.opacity(0.1))
                        Spacer()
                    }
                }
                
                // Área bajo la curva
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
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Línea del gráfico
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
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
                
                // Punto final
                if let lastPoint = data.last {
                    let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                    let x = CGFloat(data.count - 1) * stepX
                    let normalizedValue = (lastPoint.rate - minRate) / range
                    let y = geometry.size.height - (CGFloat(normalizedValue) * geometry.size.height)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                        .shadow(color: .white.opacity(0.5), radius: 4)
                }
            }
        }
    }
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
