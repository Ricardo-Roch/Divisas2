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
    @StateObject private var localization = LocalizationManager3.shared
    
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
    
    @State private var cameraKey = UUID()
    
    private var modelos: [String] {
        ["bills".localized(), "coins".localized()]
    }
    
    private let confianzaMinima: Float = 0.75
    
    // Diccionario de etiquetas personalizadas usando las traducciones
    private var etiquetasPersonalizadas: [String: String] {
        [
            "20b": "bill_20".localized(),
            "50b": "bill_50".localized(),
            "100b": "bill_100".localized(),
            "200b": "bill_200".localized(),
            "500b": "bill_500".localized(),
            "1000b": "bill_1000".localized(),
            "10c": "coin_10c".localized(),
            "50c": "coin_50c".localized(),
            "1p": "coin_1p".localized(),
            "2p": "coin_2p".localized(),
            "5p": "coin_5p".localized(),
            "10p": "coin_10p".localized(),
            "20p": "coin_20p".localized()
        ]
    }
    
    var body: some View {
        ZStack {
            CameraView { pixelBuffer in
                if !isDetecting {
                    self.currentBuffer = pixelBuffer
                }
            }
            .id(cameraKey)
            .edgesIgnoringSafeArea(.all)
            
            if isDetecting {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 0) {
                // Header con indicador del modelo activo
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: selectedModelIndex == 0 ? "banknote" : "dollarsign.circle")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("detecting_model".localized().replacingOccurrences(of: "{model}", with: modelos[selectedModelIndex]))
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
                
                // Botón de captura
                Button(action: {
                    detectarObjeto()
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(isDetecting ? Color.gray : Color.white)
                            .frame(width: 68, height: 68)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        
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
            
            // Indicador de carga
            if isDetecting {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("analyzing_type".localized().replacingOccurrences(of: "{type}", with: modelos[selectedModelIndex].lowercased()))
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
            
            // Alert overlay
            if showAlert {
                VStack(spacing: 12) {
                    Text(confidence >= confianzaMinima ? "identified".localized() : "low_confidence".localized())
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text("\(detectedLabel)\n\n\("confidence".localized()): \(String(format: "%.1f", confidence * 100))%")
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)
                    Button {
                        let wasIdentified = confidence >= confianzaMinima
                        let code = detectedDenominationCode

                        withAnimation(.easeOut(duration: 0.15)) {
                            showAlert = false
                        }
                        detectedLabel = ""
                        confidence = 0.0
                        detectedDenominationCode = nil

                        guard wasIdentified, let code = code else { return }

                        let valueStr: String
                        let displayName: String

                        if code.hasSuffix("b") {
                            let valorNum = String(code.dropLast())
                            valueStr = valorNum
                            displayName = "mexican_bill".localized().replacingOccurrences(of: "{value}", with: valorNum)
                        } else if code.hasSuffix("c") {
                            let centavosNum = String(code.dropLast())
                            valueStr = "0.\(centavosNum)"
                            displayName = "mexican_coin_cents".localized().replacingOccurrences(of: "{value}", with: centavosNum)
                        } else {
                            let pesosNum = String(code.dropLast())
                            valueStr = pesosNum
                            displayName = (pesosNum == "1")
                                ? "mexican_coin_peso".localized().replacingOccurrences(of: "{value}", with: pesosNum)
                                : "mexican_coin_pesos".localized().replacingOccurrences(of: "{value}", with: pesosNum)
                        }

                        let iconName = code.hasSuffix("b") ? "banknote.fill" : "bitcoinsign.circle.fill"

                        selectedCurrencyItem = MexCurrencySearchView.CurrencyItem(
                            type: code.hasSuffix("b") ? .bill : .coin,
                            value: valueStr,
                            displayName: displayName,
                            icon: iconName
                        )

                        navigateToDetail = true
                    } label: {
                        Text("ok".localized())
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
        .alert("camera_permission_required".localized(), isPresented: $showCameraPermissionAlert) {
            Button("open_settings".localized(), role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("cancel".localized(), role: .cancel) {}
        } message: {
            Text("camera_permission_desc".localized())
        }
        .onAppear {
            verificarPermisosCamara()
            reiniciarCamara()
        }
        .onChange(of: navigateToDetail) { isNavigating in
            if !isNavigating {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    reiniciarCamara()
                    limpiarEstado()
                }
            }
        }
    }
    
    // MARK: - Funciones privadas
    
    private func reiniciarCamara() {
        currentBuffer = nil
        cameraKey = UUID()
        print("🔄 Cámara reiniciada")
    }
    
    private func limpiarEstado() {
        selectedCurrencyItem = nil
        detectedLabel = ""
        confidence = 0.0
        detectedDenominationCode = nil
        showAlert = false
        isDetecting = false
    }
    
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

        guard let _ = copyPixelBuffer(pixelBuffer) else {
            isDetecting = false
            return
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let tipo: TipoMoneda = selectedModelIndex == 0 ? .billetes : .monedas
        
        clasificador.classify(pixelBuffer: pixelBuffer, tipo: tipo) { denominacion, conf in
            DispatchQueue.main.async {
                self.isDetecting = false
                
                guard let denominacion = denominacion, let conf = conf else {
                    self.detectedLabel = "processing_error".localized()
                    self.confidence = 0.0
                    self.detectedDenominationCode = nil
                    
                    let errorGenerator = UINotificationFeedbackGenerator()
                    errorGenerator.notificationOccurred(.error)
                    
                    withAnimation(.easeIn(duration: 0.15)) {
                        self.showAlert = true
                    }
                    return
                }
                
                if conf >= self.confianzaMinima {
                    self.detectedLabel = self.etiquetasPersonalizadas[denominacion] ?? denominacion.uppercased()
                    self.confidence = conf
                    self.detectedDenominationCode = denominacion
                    
                    let successGenerator = UINotificationFeedbackGenerator()
                    successGenerator.notificationOccurred(.success)
                } else {
                    self.detectedLabel = "low_confidence_message".localized()
                    self.confidence = conf
                    self.detectedDenominationCode = nil
                    
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
