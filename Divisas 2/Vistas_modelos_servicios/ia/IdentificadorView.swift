//
//  IdentificadorView.swift
//  MXN_AI
//
//  Created by Enrique S. on 15/10/25.
//

import SwiftUI
import AVFoundation

struct IdentificadorView: View {
    @State private var showAlert = false
    @State private var detectedLabel = ""
    @State private var confidence: Float = 0.0
    @State private var isDetecting = false
    @State private var currentBuffer: CVPixelBuffer?
    @State private var selectedModelIndex = 0
    
    // Array de modelos disponibles
    private let modelos = ["Billetes", "Monedas"]
    
    // Diccionario para mapear etiquetas de IA a nombres más amigables
    private let etiquetasPersonalizadas: [String: String] = [
        // Billetes
        "20b": "💵 Billete de $20 pesos",
        "50b": "💵 Billete de $50 pesos",
        "100b": "💵 Billete de $100 pesos",
        "200b": "💵 Billete de $200 pesos",
        "500b": "💵 Billete de $500 pesos",
        "1000b": "💵 Billete de $1,000 pesos",
        
        // Monedas
        "10c": "🪙 Moneda de 10 centavos",
        "50c": "🪙 Moneda de 50 centavos",
        "1m": "🪙 Moneda de $1 peso",
        "2m": "🪙 Moneda de $2 pesos",
        "5m": "🪙 Moneda de $5 pesos",
        "10m": "🪙 Moneda de $10 pesos",
        "20m": "🪙 Moneda de $20 pesos"
    ]
    
    // Función para obtener el modelo activo
    private func activeModel() -> ClassifierProtocol? {
        switch selectedModelIndex {
        case 0:
            return ClasificadorBilletesWrapper()
        case 1:
            return ClasificadorMonedasWrapper()
        default:
            return ClasificadorBilletesWrapper()
        }
    }
    
    // Confianza mínima requerida
    private let confianzaMinima: Float = 0.40

    var body: some View {
        ZStack {
            // Vista de la cámara
            CameraView { pixelBuffer in
                self.currentBuffer = pixelBuffer
            }
            .edgesIgnoringSafeArea(.all)
            
            // Controles y UI
            VStack {
                Spacer()
                
                // Selector de modelos centrado
                HStack {
                    Spacer()
                    
                    // Selector de modelos estilo zoom
                    HStack(spacing: 20) {
                        ForEach(0..<modelos.count, id: \.self) { index in
                            Button(action: {
                                selectedModelIndex = index
                            }) {
                                Text(modelos[index])
                                    .foregroundColor(selectedModelIndex == index ? .yellow : .white)
                                    .fontWeight(selectedModelIndex == index ? .bold : .regular)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .background(
                                        selectedModelIndex == index ?
                                            Capsule().fill(Color.black.opacity(0.7)) :
                                            Capsule().fill(Color.black.opacity(0.5))
                                    )
                            }
                        }
                    }
                    .padding(8)
                    .background(Capsule().fill(Color.black.opacity(0.3)))
                    
                    Spacer()
                }
                
                // Espacio entre selector y botón
                Spacer().frame(height: 20)
                
                // Botón de detección estilo cámara
                Button(action: {
                    detectarObjeto()
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 62, height: 62)
                    }
                }
                .disabled(isDetecting)
                .padding(.bottom, 40)
            }
            
            // Indicador de carga durante la detección
            if isDetecting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 60, height: 60)
                    )
            }
            
            // Etiqueta del modelo activo
            VStack {
                HStack {
                    Text("Modelo: \(modelos[selectedModelIndex])")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule().fill(Color.black.opacity(0.6))
                        )
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.top, 50)
            .padding(.leading, 20)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Resultado"),
                message: Text("Se detectó: \(detectedLabel)\nConfianza: \(String(format: "%.1f", confidence * 100))%"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Función para detectar objetos con el modelo seleccionado
    private func detectarObjeto() {
        guard let pixelBuffer = currentBuffer, !isDetecting else { return }
        
        isDetecting = true
        
        // Obtener el modelo activo y realizar la clasificación
        let model = activeModel()
        model?.classify(pixelBuffer: pixelBuffer) { label, confidenceValue in
            DispatchQueue.main.async {
                if let label = label, let confidenceValue = confidenceValue {
                    if confidenceValue >= confianzaMinima {
                        // Usar etiqueta personalizada si existe, o la etiqueta original si no
                        detectedLabel = etiquetasPersonalizadas[label] ?? label
                        confidence = confidenceValue
                        showAlert = true
                        // Vibración al detectar
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    } else {
                        // Opcional: mostrar mensaje cuando la confianza es baja
                        detectedLabel = "No se pudo identificar con suficiente confianza"
                        confidence = confidenceValue
                        showAlert = true
                    }
                }
                isDetecting = false
            }
        }
    }
}

// Protocolo para unificar los clasificadores
protocol ClassifierProtocol {
    func classify(pixelBuffer: CVPixelBuffer, completion: @escaping (String?, Float?) -> Void)
}

// Extensión para hacer que los wrappers implementen el protocolo
extension ClasificadorBilletesWrapper: ClassifierProtocol {}
extension ClasificadorMonedasWrapper: ClassifierProtocol {}
