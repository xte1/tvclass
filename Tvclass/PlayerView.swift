import SwiftUI
import AVKit

struct PlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    @State private var selectedQuality = "1080p"
    @State private var selectedSubtitle = "العربية"
    
    let qualities = ["1080p", "720p", "480p", "Auto"]
    let subtitles = ["إيقاف", "العربية", "English"]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }

            VStack {
                HStack {
                    Spacer()
                    HStack(spacing: 15) {
                        Picker("الترجمة", selection: $selectedSubtitle) {
                            ForEach(subtitles, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)

                        Picker("الدقة", selection: $selectedQuality) {
                            ForEach(qualities, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(8)
                    .liquidGlass()
                }
                .padding()
                Spacer()
            }
        }
        .onAppear {
            player = AVPlayer(url: videoURL)
            player?.play()
        }
        .onDisappear {
            player?.pause()
        }
    }
}
