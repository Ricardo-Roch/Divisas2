//
//  MexCurrencySearchView.swift
//  HackDivisas
//
//  Created by Yahir Fuentes
//

//Esta pantalla es donde se ve la lista de monedas y billetes de Mexico solamente

import SwiftUI

struct MexCurrencySearchView: View {
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
    
    let currencyItems: [CurrencyItem] = [
        // Monedas
        CurrencyItem(type: .coin, value: "0.10", displayName: "Moneda de 10 centavos mexicanos", icon: "bitcoinsign.circle.fill"),
        CurrencyItem(type: .coin, value: "0.20", displayName: "Moneda de 20 centavos mexicanos", icon: "bitcoinsign.circle.fill"),
        CurrencyItem(type: .coin, value: "0.50", displayName: "Moneda de 50 centavos mexicanos", icon: "bitcoinsign.circle.fill"),
        CurrencyItem(type: .coin, value: "1", displayName: "Moneda de 1 peso mexicano", icon: "bitcoinsign.circle.fill"),
        CurrencyItem(type: .coin, value: "2", displayName: "Moneda de 2 pesos mexicanos", icon: "bitcoinsign.circle.fill"),
        CurrencyItem(type: .coin, value: "5", displayName: "Moneda de 5 pesos mexicanos", icon: "bitcoinsign.circle.fill"),
        CurrencyItem(type: .coin, value: "10", displayName: "Moneda de 10 pesos mexicanos", icon: "bitcoinsign.circle.fill"),
        CurrencyItem(type: .coin, value: "20", displayName: "Moneda de 20 pesos mexicanos", icon: "bitcoinsign.circle.fill"),
        
        // Billetes
        CurrencyItem(type: .bill, value: "20", displayName: "Billete de 20 pesos mexicanos", icon: "banknote.fill"),
        CurrencyItem(type: .bill, value: "50", displayName: "Billete de 50 pesos mexicanos", icon: "banknote.fill"),
        CurrencyItem(type: .bill, value: "100", displayName: "Billete de 100 pesos mexicanos", icon: "banknote.fill"),
        CurrencyItem(type: .bill, value: "200", displayName: "Billete de 200 pesos mexicanos", icon: "banknote.fill"),
        CurrencyItem(type: .bill, value: "500", displayName: "Billete de 500 pesos mexicanos", icon: "banknote.fill"),
        CurrencyItem(type: .bill, value: "1000", displayName: "Billete de 1000 pesos mexicanos", icon: "banknote.fill")
    ]
    
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
                    Text("Monedas y Billetes")
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
                    
                    TextField("Buscar moneda o billete", text: $searchText)
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
                    Text("Busca cualquier moneda de México en circulación actualmente")
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
                            NavigationLink(destination: MexicanCoinDetailView(item: item)) {
                                CurrencyItemCard(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if filteredItems.isEmpty {
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
    let item: MexCurrencySearchView.CurrencyItem
    @Environment(\.colorScheme) private var colorScheme
    
    var accentColor: Color {
        item.type == .coin ? Color(hex: "9CA462") : Color(hex: "4275B6")
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
                
                Text(item.type == .coin ? "Moneda" : "Billete")
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Valor
            Text("$\(item.value)")
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

// MARK: - Preview
#Preview {
    NavigationStack {
        MexCurrencySearchView()
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        MexCurrencySearchView()
            .preferredColorScheme(.dark)
    }
}
