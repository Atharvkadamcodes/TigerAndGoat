import SwiftUI
import AVKit

struct DetailImage: View {
    var imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

struct DetailText: View {
    var title: String
    var text: String
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: horizontalSizeClass == .compact ? 12 : 24) {
            Text(title)
                .font(horizontalSizeClass == .compact ? .title : .system(size: 44, weight: .bold))
                .foregroundColor(.primary)
            
            Text(text)
                .font(horizontalSizeClass == .compact ? .body : .system(size: 24, weight: .regular))
                .foregroundColor(.secondary)
                .lineSpacing(horizontalSizeClass == .compact ? 4 : 12)
        }
    }
}


struct VideoPlayerView: UIViewRepresentable {
    let videoName: String
    let videoExtension: String

    func makeUIView(context: Context) -> UIView {
        let view = LoopingPlayerUIView(frame: .zero)
        view.loadVideo(name: videoName, extension: videoExtension)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class LoopingPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(playerLayer)

        playerLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    func loadVideo(name: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("🚨 Could not find video: \(name).\(ext) inside the Resources folder!")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = true // Prevents random audio glitches
        
        playerLayer.player = queuePlayer
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        queuePlayer.play()
    }
}
