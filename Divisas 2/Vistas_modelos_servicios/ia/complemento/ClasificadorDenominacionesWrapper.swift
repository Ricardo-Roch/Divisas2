//
//  ClasificadorDenominacionesWrapper.swift
//  MXN_AI
//
//  Created by Enrique S. on 19/10/25.
//

import CoreML
import Vision
import Combine

enum TipoMoneda {
    case billetes
    case monedas
}

class ClasificadorDenominacionesWrapper: ObservableObject {
    private struct DenomModel {
        let denominacion: String
        let model: VNCoreMLModel
        let tipo: TipoMoneda
    }
    
    private var todosLosModelos: [DenomModel] = []
    
    init?() {
        var modelos: [DenomModel] = []
        
        // MARK: - Cargar modelos de Monedas
        // Cada modelo responde "si"/"no" si es esa denominación
        if let modelo = try? VNCoreMLModel(for: modelo10c().model) {
            modelos.append(DenomModel(denominacion: "10c", model: modelo, tipo: .monedas))
        }
        if let modelo = try? VNCoreMLModel(for: modelo50c().model) {
            modelos.append(DenomModel(denominacion: "50c", model: modelo, tipo: .monedas))
        }
        if let modelo = try? VNCoreMLModel(for: modelo1p().model) {
            modelos.append(DenomModel(denominacion: "1p", model: modelo, tipo: .monedas))
        }
        if let modelo = try? VNCoreMLModel(for: modelo2p().model) {
            modelos.append(DenomModel(denominacion: "2p", model: modelo, tipo: .monedas))
        }
        if let modelo = try? VNCoreMLModel(for: modelo5p().model) {
            modelos.append(DenomModel(denominacion: "5p", model: modelo, tipo: .monedas))
        }
        if let modelo = try? VNCoreMLModel(for: modelo10p().model) {
            modelos.append(DenomModel(denominacion: "10p", model: modelo, tipo: .monedas))
        }
        if let modelo = try? VNCoreMLModel(for: modelo20p().model) {
            modelos.append(DenomModel(denominacion: "20p", model: modelo, tipo: .monedas))
        }
        
        // MARK: - Cargar modelos de Billetes
        if let modelo = try? VNCoreMLModel(for: modelo20b().model) {
            modelos.append(DenomModel(denominacion: "20b", model: modelo, tipo: .billetes))
        }
        if let modelo = try? VNCoreMLModel(for: modelo50b().model) {
            modelos.append(DenomModel(denominacion: "50b", model: modelo, tipo: .billetes))
        }
        if let modelo = try? VNCoreMLModel(for: modelo100b().model) {
            modelos.append(DenomModel(denominacion: "100b", model: modelo, tipo: .billetes))
        }
        if let modelo = try? VNCoreMLModel(for: modelo200b().model) {
            modelos.append(DenomModel(denominacion: "200b", model: modelo, tipo: .billetes))
        }
        if let modelo = try? VNCoreMLModel(for: modelo500b().model) {
            modelos.append(DenomModel(denominacion: "500b", model: modelo, tipo: .billetes))
        }
        if let modelo = try? VNCoreMLModel(for: modelo1000b().model) {
            modelos.append(DenomModel(denominacion: "1000b", model: modelo, tipo: .billetes))
        }
        
        guard !modelos.isEmpty else {
            print("❌ Error: No se pudo cargar ningún modelo")
            return nil
        }
        
        self.todosLosModelos = modelos
        print("✅ Modelos cargados: \(modelos.count) total")
        print("   - Billetes: \(modelos.filter { $0.tipo == .billetes }.count)")
        print("   - Monedas: \(modelos.filter { $0.tipo == .monedas }.count)")
    }
    
    /// Clasifica el pixelBuffer usando todos los modelos del tipo especificado
    /// Cada modelo devuelve "si"/"no", buscamos el que tenga mayor confianza en "si"
    func classify(
        pixelBuffer: CVPixelBuffer,
        tipo: TipoMoneda,
        completion: @escaping (String?, Float?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(nil, nil) }
                return
            }
            
            // Filtrar modelos según el tipo seleccionado
            let modelosAUsar = self.filtrarModelos(porTipo: tipo)
            
            guard !modelosAUsar.isEmpty else {
                print("⚠️ No hay modelos disponibles para el tipo: \(tipo)")
                DispatchQueue.main.async { completion(nil, nil) }
                return
            }
            
            var mejorDenominacion: String? = nil
            var mayorConfianza: Float = 0.0
            
            // Crear grupo de despacho para procesamiento concurrente
            let group = DispatchGroup()
            let lock = NSLock()
            
            print("🔍 Analizando imagen con \(modelosAUsar.count) modelos de \(tipo)...")
            
            // Procesar cada modelo en paralelo
            for denom in modelosAUsar {
                group.enter()
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let request = VNCoreMLRequest(model: denom.model)
                    request.imageCropAndScaleOption = .centerCrop
                    
                    let handler = VNImageRequestHandler(
                        cvPixelBuffer: pixelBuffer,
                        orientation: .up,
                        options: [:]
                    )
                    
                    do {
                        try handler.perform([request])
                        
                        // Cada modelo devuelve "si" o "no"
                        // Buscamos la confianza de la clase "si"
                        if let resultados = request.results as? [VNClassificationObservation],
                           let siResult = resultados.first(where: { $0.identifier.lowercased() == "si" }) {
                            
                            let confianzaSi = siResult.confidence
                            
                            // Actualizar el mejor resultado de forma thread-safe
                            lock.lock()
                            if confianzaSi > mayorConfianza {
                                mayorConfianza = confianzaSi
                                mejorDenominacion = denom.denominacion
                                print("  ✓ \(denom.denominacion): \(String(format: "%.1f%%", confianzaSi * 100))")
                            }
                            lock.unlock()
                        }
                    } catch {
                        print("  ⚠️ Error en modelo \(denom.denominacion): \(error)")
                    }
                    
                    group.leave()
                }
            }
            
            // Esperar a que todos los modelos terminen
            group.wait()
            
            // Retornar resultado en el hilo principal
            DispatchQueue.main.async {
                if let denominacion = mejorDenominacion {
                    print("✅ Mejor detección: \(denominacion) con \(String(format: "%.1f%%", mayorConfianza * 100)) de confianza")
                } else {
                    print("❌ No se detectó ninguna denominación")
                }
                completion(mejorDenominacion, mayorConfianza)
            }
        }
    }
    
    /// Filtra los modelos según el tipo especificado
    private func filtrarModelos(porTipo tipo: TipoMoneda) -> [DenomModel] {
        return todosLosModelos.filter { $0.tipo == tipo }
    }
    
    /// Retorna el número de modelos disponibles por tipo
    func contarModelos(tipo: TipoMoneda) -> Int {
        return filtrarModelos(porTipo: tipo).count
    }
}
