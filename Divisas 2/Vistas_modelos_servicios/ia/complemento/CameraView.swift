//
//  CameraView.swift
//  MXN_AI
//
//  Created by Enrique S. on 15/10/25.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    let onFrame: (CVPixelBuffer) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onFrame = onFrame
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
