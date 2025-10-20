//
//  IdentificadorView.swift
//  MXN_AI
//
//  Created by Enrique S. on 15/10/25.
//

import SwiftUI
import AVFoundation

struct IdentificadorView: View {
    @StateObject private var clasificador = ClasificadorDenominacionesWrapper()!
    @State private var showAlert = false
    @State private var detectedLabel = ""
    @State private var confidence: Float = 0.0
    @State private var isDetecting = false
    @State private var currentBuffer: CVPixelBuffer?
    @State private var selectedModelIndex = 0
    @State private var showCameraPermissionAlert = false
    
    @State private var selectedCurrencyItem: MexCurrencySearchView.CurrencyItem? = nil
    @State private var navigateToDetail = false
    @State private var detectedDenominationCode: String? = nil
    
    private let modelos = ["Billetes", "Monedas"]
    private let confianzaMinima: Float = 0.75
    
    // Diccionario de etiquetas personalizadas
    // Las claves coinciden con las denominaciones de los modelos
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
        "1p": "🪙 Moneda de $1 peso",
        "2p": "🪙 Moneda de $2 pesos",
        "5p": "🪙 Moneda de $5 pesos",
        "10p": "🪙 Moneda de $10 pesos",
        "20p": "🪙 Moneda de $20 pesos"
    ]
    
    var body: some View {
        ZStack {
            // Vista de la cámara
            CameraView { pixelBuffer in
                // no pisar el buffer mientras estás procesando
                if !isDetecting {
                    self.currentBuffer = pixelBuffer
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Overlay oscuro durante la detección
            if isDetecting {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Controles de UI
            VStack(spacing: 0) {
                // Header con indicador del modelo activo
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: selectedModelIndex == 0 ? "banknote" : "dollarsign.circle")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("Detectando: \(modelos[selectedModelIndex])")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.7))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
                    )
                    
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Selector de tipo de detección
                HStack(spacing: 16) {
                    ForEach(0..<modelos.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedModelIndex = index
                            }
                            // Haptic feedback al cambiar
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: index == 0 ? "banknote.fill" : "dollarsign.circle.fill")
                                    .font(.system(size: 28))
                                
                                Text(modelos[index])
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(selectedModelIndex == index ? .yellow : .white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        selectedModelIndex == index ?
                                        Color.black.opacity(0.8) :
                                        Color.black.opacity(0.5)
                                    )
                                    .shadow(
                                        color: selectedModelIndex == index ?
                                            Color.yellow.opacity(0.3) : .clear,
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            )
                        }
                        .disabled(isDetecting)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                // Botón de captura tipo cámara
                Button(action: {
                    detectarObjeto()
                }) {
                    ZStack {
                        // Anillo exterior
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: 80, height: 80)
                        
                        // Botón interior
                        Circle()
                            .fill(isDetecting ? Color.gray : Color.white)
                            .frame(width: 68, height: 68)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        
                        // Indicador de procesamiento
                        if isDetecting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        }
                    }
                }
                .disabled(isDetecting || currentBuffer == nil)
                .opacity(currentBuffer == nil ? 0.5 : 1.0)
                .padding(.bottom, 50)
            }
            
            // Indicador de carga full screen
            if isDetecting {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Analizando \(modelos[selectedModelIndex].lowercased())...")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.8))
                        .shadow(radius: 20)
                )
            }
            
            // === NUEVO: Overlay (toast) no bloqueante con botón OK ===
            if showAlert {
                VStack(spacing: 12) {
                    Text(confidence >= confianzaMinima ? "✅ Identificado" : "⚠️ Confianza baja")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text("\(detectedLabel)\n\nConfianza: \(String(format: "%.1f", confidence * 100))%")
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)
                    Button {
                                            // Cierre inmediato y limpieza mínima (sin tocar cámara ni modelos)
                                            let wasIdentified = confidence >= confianzaMinima
                                            let code = detectedDenominationCode

                                            withAnimation(.easeOut(duration: 0.15)) {
                                                showAlert = false
                                            }
                                            detectedLabel = ""
                                            confidence = 0.0
                                            detectedDenominationCode = nil

                                            guard wasIdentified, let code = code else { return }

                                            // 1) Derivar valueStr y displayName según el código detectado
                                            let valueStr: String
                                            let displayName: String

                                            if code.hasSuffix("b") {
                                                // Billete: valor en pesos
                                                let valorNum = String(code.dropLast())     // "500b" -> "500"
                                                valueStr = valorNum
                                                displayName = "Billete de \(valorNum) pesos mexicanos"
                                            } else if code.hasSuffix("c") {
                                                // Moneda en centavos
                                                let centavosNum = String(code.dropLast())  // "10c" -> "10"
                                                // Si quieres dos dígitos siempre, usa String(format:) en vez de la línea siguiente
                                                valueStr = "0.\(centavosNum)"              // "10" -> "0.10"
                                                displayName = "Moneda de \(centavosNum) centavos mexicanos"
                                            } else {
                                                // Moneda en pesos
                                                let pesosNum = String(code.dropLast())     // "5p" -> "5"
                                                valueStr = pesosNum
                                                displayName = (pesosNum == "1")
                                                    ? "Moneda de 1 peso mexicano"
                                                    : "Moneda de \(pesosNum) pesos mexicanos"
                                            }

                                            // 2) Ícono y tipo (aquí el contexto de 'type:' resuelve .bill/.coin sin ambigüedad)
                                            let iconName = code.hasSuffix("b") ? "banknote.fill" : "bitcoinsign.circle.fill"

                                            selectedCurrencyItem = MexCurrencySearchView.CurrencyItem(
                                                type: code.hasSuffix("b") ? .bill : .coin,
                                                value: valueStr,
                                                displayName: displayName,
                                                icon: iconName
                                            )

                                            // 3) Disparar la navegación a MexicanCoinDetailView
                                            navigateToDetail = true
                                        } label: {
                                            Text("OK")
                                                .font(.system(size: 16, weight: .semibold))
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 24)
                                                .background(
                                                    Capsule().fill(Color.white.opacity(0.15))
                                                )
                                        }
                                        .buttonStyle(.plain)
                                        .foregroundColor(.white)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.85))
                )
                .foregroundColor(.white)
                .shadow(radius: 10)
                .padding(.horizontal, 24)
                .transition(.opacity.combined(with: .scale))
                .animation(.easeInOut(duration: 0.2), value: showAlert)
            }
            NavigationLink(
                destination: Group {
                    if let item = selectedCurrencyItem {
                        MexicanCoinDetailView(item: item)
                    } else {
                        EmptyView()
                    }
                },
                isActive: $navigateToDetail
            ) {
                EmptyView()
            }
            .hidden()
        }
        // Eliminamos la alerta modal de resultados para evitar bloqueo de UI
        // (Se mantiene la alerta de permisos de cámara)
        .alert("Permiso de Cámara Requerido", isPresented: $showCameraPermissionAlert) {
            Button("Ir a Ajustes", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta app necesita acceso a la cámara para identificar billetes y monedas. Por favor, habilita el acceso en Ajustes.")
        }
        .onAppear {
            verificarPermisosCamara()
        }
    }
    
    // MARK: - Funciones privadas
    
    private func copyPixelBuffer(_ src: CVPixelBuffer) -> CVPixelBuffer? {
        let pixelFormat = CVPixelBufferGetPixelFormatType(src)
        let width = CVPixelBufferGetWidth(src)
        let height = CVPixelBufferGetHeight(src)

        var dstOpt: CVPixelBuffer?
        let attrs: CFDictionary = [kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary

        guard CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormat, attrs, &dstOpt) == kCVReturnSuccess,
              let dst = dstOpt else { return nil }

        CVPixelBufferLockBaseAddress(src, .readOnly)
        CVPixelBufferLockBaseAddress(dst, [])

        defer {
            CVPixelBufferUnlockBaseAddress(dst, [])
            CVPixelBufferUnlockBaseAddress(src, .readOnly)
        }

        let planes = max(CVPixelBufferGetPlaneCount(src), 1)
        for plane in 0..<planes {
            let srcBase = CVPixelBufferGetBaseAddressOfPlane(src, plane)!
            let dstBase = CVPixelBufferGetBaseAddressOfPlane(dst, plane)!
            let srcBPR  = CVPixelBufferGetBytesPerRowOfPlane(src, plane)
            let dstBPR  = CVPixelBufferGetBytesPerRowOfPlane(dst, plane)
            let rows    = CVPixelBufferGetHeightOfPlane(src, plane)
            let bytes   = min(srcBPR, dstBPR)

            for r in 0..<rows {
                memcpy(dstBase.advanced(by: r*dstBPR), srcBase.advanced(by: r*srcBPR), bytes)
            }
        }
        return dst
    }
    
    private func verificarPermisosCamara() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    DispatchQueue.main.async {
                        showCameraPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert = true
        default:
            break
        }
    }
    
    private func detectarObjeto() {
        // Si hay un resultado visible, ocultarlo antes de iniciar una nueva detección
        if showAlert {
            withAnimation(.easeOut(duration: 0.15)) {
                showAlert = false
            }
            detectedLabel = ""
            confidence = 0.0
            detectedDenominationCode = nil
        }
        
        guard let pixelBuffer = currentBuffer, !isDetecting else {
            print("⚠️ No hay frame disponible o ya está detectando")
            return
        }

        isDetecting = true

        // 🔒 Copia del frame para Vision (mantengo tu implementación, sin afectar flujo)
        guard let _ = copyPixelBuffer(pixelBuffer) else {
            isDetecting = false
            return
        }
        
        // Haptic feedback inicial
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Determinar tipo según el selector
        let tipo: TipoMoneda = selectedModelIndex == 0 ? .billetes : .monedas
        
        // Ejecutar clasificación (mantengo tu lógica tal cual)
        clasificador.classify(pixelBuffer: pixelBuffer, tipo: tipo) { denominacion, conf in
            DispatchQueue.main.async {
                self.isDetecting = false
                
                guard let denominacion = denominacion, let conf = conf else {
                    // Error en la clasificación
                    self.detectedLabel = "❌ Error al procesar la imagen"
                    self.confidence = 0.0
                    self.detectedDenominationCode = nil
                    
                    let errorGenerator = UINotificationFeedbackGenerator()
                    errorGenerator.notificationOccurred(.error)
                    
                    withAnimation(.easeIn(duration: 0.15)) {
                        self.showAlert = true
                    }
                    return
                }
                
                // Procesar resultado
                if conf >= self.confianzaMinima {
                    // Identificación exitosa
                    self.detectedLabel = self.etiquetasPersonalizadas[denominacion] ?? denominacion.uppercased()
                    self.confidence = conf
                    self.detectedDenominationCode = denominacion   // Guardar código (ej. "500b")
                    
                    // Haptic feedback de éxito
                    let successGenerator = UINotificationFeedbackGenerator()
                    successGenerator.notificationOccurred(.success)
                } else {
                    // Confianza insuficiente
                    self.detectedLabel = "No se pudo identificar con suficiente confianza"
                    self.confidence = conf
                    self.detectedDenominationCode = nil   // No identificado con confianza
                    
                    // Haptic feedback de advertencia
                    let warningGenerator = UINotificationFeedbackGenerator()
                    warningGenerator.notificationOccurred(.warning)
                }
                
                withAnimation(.easeIn(duration: 0.15)) {
                    self.showAlert = true
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    IdentificadorView()
}
