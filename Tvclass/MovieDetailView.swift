import SwiftUI

struct MovieDetailView: View {
    let item: MediaItem
    @State private var selectedEpisode: Episode?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: item.posterURL) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 300)
                .clipped()

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(item.displayTitle)
                            .font(.title).bold()
                        Spacer()
                        HStack {
                            Image(systemName: "star.fill").foregroundColor(.yellow)
                            Text(String(format: "%.1f", item.voteAverage ?? 0.0))
                        }
                        .padding(8)
                        .liquidGlass()
                    }

                    Text(item.overview ?? "لا يوجد وصف متوفر.")
                        .font(.body)
                        .foregroundColor(.gray)

                    Text("الحلقات والأجزاء")
                        .font(.headline)
                        .padding(.top)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(1...8, id: \.self) { ep in
                                Button(action: {
                                    selectedEpisode = Episode(id: ep, title: "الحلقة \(ep)", episodeNumber: ep, videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
                                }) {
                                    VStack {
                                        Image(systemName: "play.circle.fill")
                                            .font(.largeTitle)
                                        Text("الحلقة \(ep)")
                                    }
                                    .frame(width: 100, height: 80)
                                    .liquidGlass()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $selectedEpisode) { ep in
            PlayerView(videoURL: ep.videoURL)
        }
    }
}
