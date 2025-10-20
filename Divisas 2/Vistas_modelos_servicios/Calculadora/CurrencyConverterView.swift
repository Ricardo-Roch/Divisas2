//
//  CurrencyConverterView.swift
//  HackDivisas
//

import SwiftUI

struct CurrencyConverterView: View {
    @StateObject private var viewModel = CurrencyConverterViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingFromCurrencyPicker = false
    @State private var showingToCurrencyPicker = false
    @State private var showingHistory = false
    @ObservedObject private var localizationManager = LocalizationManager3.shared // ← AGREGAR

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Desde (From)
                        CurrencyCard(
                            amount: viewModel.fromAmount,
                            currency: viewModel.fromCurrency,
                            isEditing: true
                        ) {
                            showingFromCurrencyPicker = true
                        }
                        
                        // Botón de intercambio
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.swapCurrencies()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.appCardBackground)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                                    )
                                
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.appTextPrimary)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        // Hacia (To)
                        CurrencyCard(
                            amount: viewModel.toAmount,
                            currency: viewModel.toCurrency,
                            isEditing: false
                        ) {
                            showingToCurrencyPicker = true
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
                
                // Calculadora
                CalculatorKeypad { key in
                    viewModel.handleKeypadInput(key)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingFromCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $viewModel.fromCurrency)
        }
        .sheet(isPresented: $showingToCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $viewModel.toCurrency)
        }
        .sheet(isPresented: $showingHistory) {
            ConversionHistoryView(history: viewModel.conversionHistory)
        }
        .onAppear {
            viewModel.fetchExchangeRates()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
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
            
            Text("Conversor")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.appTextPrimary)
            
            Spacer()
            
            Button {
                showingHistory = true
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().strokeBorder(Color.appTextPrimary.opacity(0.1), lineWidth: 1))
                    
                    Image(systemName: "clock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                }
                .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Currency Card
struct CurrencyCard: View {
    let amount: String
    let currency: Currency
    let isEditing: Bool
    let onTapFlag: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onTapFlag) {
                HStack(spacing: 8) {
                    Text(currency.flag)
                        .font(.system(size: 28))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currency.code)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                        
                        Text(currency.name)
                            .font(.system(size: 12))
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }
            .buttonStyle(.plain)
            
            Divider()
                .background(Color.appTextSecondary.opacity(0.3))
            
            HStack {
                Text(amount.isEmpty ? "0" : amount)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Calculator Keypad
struct CalculatorKeypad: View {
    let onKeyPress: (CalculatorKey) -> Void
    
    let keys: [[CalculatorKey]] = [
        [.number(7), .number(8), .number(9)],
        [.number(4), .number(5), .number(6)],
        [.number(1), .number(2), .number(3)],
        [.decimal, .number(0), .delete]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        CalculatorButton(key: key) {
                            onKeyPress(key)
                        }
                    }
                }
            }
        }
    }
}

struct CalculatorButton: View {
    let key: CalculatorKey
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColor, lineWidth: 1)
                    )
                
                if case .number(let num) = key {
                    Text("\(num)")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(textColor)
                } else if case .decimal = key {
                    Text(".")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(textColor)
                } else if case .delete = key {
                    Image(systemName: "delete.left.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        if case .delete = key {
            return .red
        }
        return Color.appCardBackground
    }
    
    private var borderColor: Color {
        if case .delete = key {
            return Color.red.opacity(0.3)
        }
        return Color.appTextPrimary.opacity(0.1)
    }
    
    private var textColor: Color {
        if case .delete = key {
            return .white
        }
        return .appTextPrimary
    }
}

enum CalculatorKey: Hashable {
    case number(Int)
    case decimal
    case delete
}

#Preview {
    NavigationStack {
        CurrencyConverterView()
    }
}
