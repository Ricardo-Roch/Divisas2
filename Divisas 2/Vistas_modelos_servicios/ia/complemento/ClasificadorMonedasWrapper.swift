//
//  ClasificadorMonedasWrapper.swift
//  MXN_AI
//
//  Created by Enrique S. on 15/10/25.
//

import CoreML
import Vision

class ClasificadorMonedasWrapper {
    private let model: VNCoreMLModel
    
    init?() {
        guard let visionModel = try? VNCoreMLModel(for: monedas().model) else {
            return nil
        }
        self.model = visionModel
    }

    func classify(pixelBuffer: CVPixelBuffer, completion: @escaping (String?, Float?) -> Void) {
        let request = VNCoreMLRequest(model: model) { request, _ in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(nil, nil)
                return
            }
            completion(topResult.identifier, topResult.confidence)
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
