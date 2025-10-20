//
//  USACurrencyListView.swift
//  HackDivisas
//
//  Created by Yahir Fuentes
//

//Aquí está la lista de las monedas y billetes de USA

import SwiftUI

struct USACurrencyListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    
    struct CurrencyItem: Identifiable {
        let id = UUID()
        let type: CurrencyType
        let value: String
        let displayName: String
        let icon: String
        
        enum CurrencyType {
            case coin
            case bill
        }
    }
    
    var currencyItems: [CurrencyItem] {
        [
            // Monedas
            CurrencyItem(type: .coin, value: "0.01", displayName: "usa_penny".localized(), icon: "bitcoinsign.circle.fill"),
            CurrencyItem(type: .coin, value: "0.05", displayName: "usa_nickel".localized(), icon: "bitcoinsign.circle.fill"),
            CurrencyItem(type: .coin, value: "0.10", displayName: "usa_dime".localized(), icon: "bitcoinsign.circle.fill"),
            CurrencyItem(type: .coin, value: "0.25", displayName: "usa_quarter".localized(), icon: "bitcoinsign.circle.fill"),
            CurrencyItem(type: .coin, value: "0.50", displayName: "usa_half_dollar".localized(), icon: "bitcoinsign.circle.fill"),
            CurrencyItem(type: .coin, value: "1", displayName: "usa_dollar_coin".localized(), icon: "bitcoinsign.circle.fill"),
            
            // Billetes
            CurrencyItem(type: .bill, value: "1", displayName: "usa_bill_1".localized(), icon: "banknote.fill"),
            CurrencyItem(type: .bill, value: "2", displayName: "usa_bill_2".localized(), icon: "banknote.fill"),
            CurrencyItem(type: .bill, value: "5", displayName: "usa_bill_5".localized(), icon: "banknote.fill"),
            CurrencyItem(type: .bill, value: "10", displayName: "usa_bill_10".localized(), icon: "banknote.fill"),
            CurrencyItem(type: .bill, value: "20", displayName: "usa_bill_20".localized(), icon: "banknote.fill"),
            CurrencyItem(type: .bill, value: "50", displayName: "usa_bill_50".localized(), icon: "banknote.fill"),
            CurrencyItem(type: .bill, value: "100", displayName: "usa_bill_100".localized(), icon: "banknote.fill")
        ]
    }
    
    var filteredItems: [CurrencyItem] {
        if searchText.isEmpty {
            return currencyItems
        } else {
            return currencyItems.filter { item in
                item.displayName.localizedCaseInsensitiveContains(searchText) ||
                item.value.contains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header con botón de regreso
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Título
                HStack {
                    Text("coins_and_bills".localized())
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
                    
                    TextField("search_coin_or_bill".localized(), text: $searchText)
                        .foregroundColor(.appTextPrimary)
                        .font(.system(size: 16))
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.appTextSecondary)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appCardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appTextSecondary.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Subtexto
                HStack {
                    Text("search_any_currency_usa".localized())
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Lista de monedas y billetes
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: CurrencyDetailView(item: item)) {
                                CurrencyItemCard(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if filteredItems.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.appTextSecondary)
                                
                                Text("no_results_found".localized())
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appTextPrimary)
                                
                                Text("try_another_search".localized())
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Currency Item Card
private struct CurrencyItemCard: View {
    let item: USACurrencyListView.CurrencyItem
    @Environment(\.colorScheme) private var colorScheme
    
    var accentColor: Color {
        item.type == .coin ? Color(hex: "C0C0C0") : Color(hex: "4275B6")
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundColor(accentColor)
            }
            
            // Contenido
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                Text(item.type == .coin ? "coin".localized() : "bill".localized())
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Valor
            Text("coming_soon".localized())
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(accentColor)
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.appTextSecondary)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
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

// MARK: - Currency Detail View (Placeholder)
private struct CurrencyDetailView: View {
    let item: USACurrencyListView.CurrencyItem
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: item.icon)
                    .font(.system(size: 80))
                    .foregroundColor(item.type == .coin ? Color(hex: "C0C0C0") : Color(hex: "4275B6"))
                
                Text(item.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Valor: $\(item.value) USD")
                    .font(.title2)
                    .foregroundColor(.appTextSecondary)
                
                Text("Vista de Detalle - Próximamente")
                    .foregroundColor(.appTextSecondary)
                    .padding(.top, 20)
            }
        }
        .navigationTitle(item.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        USACurrencyListView()
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        USACurrencyListView()
            .preferredColorScheme(.dark)
    }
}
