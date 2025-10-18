//
//  DictionaryView.swift
//  Divisas 2
//
//  Fusión: Header visual + Catálogo completo de países del mundo
//

import SwiftUI

struct DictionaryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = CurrencyCatalogViewModel()
    @State private var searchText = ""
    
    private let headerHeightRatio: CGFloat = 0.28
    private let headerImageName = "DineroCanUsaMex"
    
    var filteredCountries: [CountryItem] {
        var items = viewModel.countries
        
        if !searchText.isEmpty {
            items = items.filter { item in
                item.countryName.localizedCaseInsensitiveContains(searchText) ||
                item.currencyCode.localizedCaseInsensitiveContains(searchText) ||
                item.currencyName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return items
    }
    
    var body: some View {
        GeometryReader { proxy in
            let headerHeight = proxy.size.height * headerHeightRatio
            
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header con imagen
                    ZStack(alignment: .topLeading) {
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
                            Button(action: { dismiss() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 17, weight: .semibold))
                                    Text("Home")
                                        .font(.system(size: 17))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }
                            .padding(.top, 50)
                            .padding(.leading, 4)
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Divisas del Mundo")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                                
                                Text("Explora monedas y billetes de \(viewModel.countries.count) países")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.95))
                                    .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 1)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                    .frame(height: headerHeight)
                    .ignoresSafeArea(edges: .top)
                    
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
                    .padding(.vertical, 16)
                    
                    // Contenido
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Cargando países...")
                                .font(.system(size: 16))
                                .foregroundColor(.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredCountries.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: searchText.isEmpty ? "exclamationmark.circle" : "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.appTextSecondary)
                            
                            Text(searchText.isEmpty ? "No se pudieron cargar los países" : "No se encontraron resultados")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            Text(searchText.isEmpty ? "Verifica tu conexión e intenta nuevamente" : "Intenta con otro término de búsqueda")
                                .font(.system(size: 14))
                                .foregroundColor(.appTextSecondary)
                            
                            if searchText.isEmpty {
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
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredCountries) { country in
                                    NavigationLink(destination: CurrencyDetailView(item: country, viewModel: viewModel)) {
                                        CountryCardUnified(item: country)
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
        }
        .navigationBarHidden(true)
        .onAppear {
            if viewModel.countries.isEmpty {
                viewModel.fetchCountries()
            }
        }
    }
}

// MARK: - Country Card Unified
private struct CountryCardUnified: View {
    let item: CountryItem
    @Environment(\.colorScheme) private var colorScheme
    
    var accentColor: Color {
        switch item.currencyCode {
        case "MXN": return Color(hex: "9CA462")
        case "USD": return Color(hex: "4275B6")
        case "CAD": return Color(hex: "FACB49")
        default: return Color(hex: "4275B6")
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Bandera grande
            Text(item.flag)
                .font(.system(size: 40))
                .frame(width: 56)
            
            // Contenido
            VStack(alignment: .leading, spacing: 4) {
                Text(item.countryName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                
                Text("\(item.currencyName)")
                    .font(.system(size: 14))
                    .foregroundColor(accentColor)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                        Text(item.currencyCode)
                            .font(.system(size: 13, weight: .medium))
                    }
                    
                    Text("•")
                        .font(.system(size: 12))
                    
                    Text(item.currencySymbol.isEmpty ? "—" : item.currencySymbol)
                        .font(.system(size: 13))
                }
                .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(accentColor)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor.opacity(0.25), lineWidth: 1)
        )
        .shadow(
            color: colorScheme == .dark ?
                Color.black.opacity(0.3) :
                Color.black.opacity(0.06),
            radius: 6,
            x: 0,
            y: 2
        )
    }
}

// MARK: - Currency Detail View (reutilizando el existente)
private struct CurrencyDetailView: View {
    let item: CountryItem
    let viewModel: CurrencyCatalogViewModel
    @StateObject private var detailViewModel = CurrencyDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var accentColor: Color {
        switch item.currencyCode {
        case "MXN": return Color(hex: "9CA462")
        case "USD": return Color(hex: "4275B6")
        case "CAD": return Color(hex: "FACB49")
        default: return Color(hex: "4275B6")
        }
    }
    
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
                                        .font(.system(size: 72))
                                    Text(item.countryName)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.appTextPrimary)
                                }
                                Spacer()
                            }
                            
                            Divider()
                            
                            // Detalles de la moneda
                            VStack(alignment: .leading, spacing: 16) {
                                CharacteristicRow(icon: "dollarsign.circle", title: "Código", value: item.currencyCode, accentColor: accentColor)
                                CharacteristicRow(icon: "text.bubble", title: "Moneda", value: item.currencyName, accentColor: accentColor)
                                CharacteristicRow(icon: "symbol", title: "Símbolo", value: item.currencySymbol.isEmpty ? "—" : item.currencySymbol, accentColor: accentColor)
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
                                    ForEach(detailViewModel.currencyItems) { currencyItem in
                                        CurrencyItemCard(item: currencyItem, accentColor: accentColor)
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
                                    .foregroundColor(accentColor)
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
                                                .foregroundColor(accentColor)
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12, weight: .semibold))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(RoundedRectangle(cornerRadius: 8).fill(accentColor.opacity(0.15)))
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
    let accentColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var cardAccentColor: Color {
        item.type == "coin" ? Color(hex: "9CA462") : accentColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                                .fill(cardAccentColor.opacity(0.1))
                            Image(systemName: "photo.slash")
                                .foregroundColor(cardAccentColor)
                        }
                        .frame(height: 150)
                    }
                }
            }
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(cardAccentColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.type == "coin" ? "centsign.circle.fill" : "banknote.fill")
                        .font(.system(size: 18))
                        .foregroundColor(cardAccentColor)
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
                        .foregroundColor(cardAccentColor)
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.appCardBackground))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(cardAccentColor.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Characteristic Row
private struct CharacteristicRow: View {
    let icon: String
    let title: String
    let value: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(accentColor)
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
