import SwiftUI
import AVKit

struct SplashView: View {
    @State private var isActive = false
    @State private var player: AVPlayer?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if isActive {
                HomeView()
            } else {
                // Mismo fondo que HomeView
                Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1) : UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1) })
                    .ignoresSafeArea()
                
                // Video en pantalla completa
                if let player = player {
                    FullScreenVideoPlayer(player: player)
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        guard let path = Bundle.main.path(forResource: "IntroFondo", ofType: "mov") else {
            // Si no encuentra el video, pasa directo a HomeView
            print("❌ No se encontró el archivo IntroFondo.mov")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isActive = true
                }
            }
            return
        }
        
        print("✅ Video encontrado en: \(path)")
        
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        
        // Configuración del player
        player?.isMuted = false // Cambia a true si no quieres sonido
        
        // Observer para cuando termine el video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                isActive = true
            }
        }
        
        // Reproducir el video
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            player?.play()
            print("▶️ Reproduciendo video")
        }
    }
}

// MARK: - Full Screen Video Player
struct FullScreenVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerView {
        let playerView = PlayerView()
        playerView.player = player
        return playerView
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        // No es necesario actualizar nada aquí
    }
}

// MARK: - Custom Player View
class PlayerView: UIView {
    var player: AVPlayer? {
        didSet {
            playerLayer.player = player
        }
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = bounds
    }
}
