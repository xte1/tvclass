import SwiftUI

struct MovieDetailView: View {
    let item: MediaItem
    @State private var selectedSeason = 1
    @State private var selectedEpisode: Episode?
    @Environment(\.dismiss) private var dismiss

    // توليد حلقات تجريبية للمواسم
    var episodes: [Episode] {
        (1...10).compactMap { ep in
            guard let url = URL(string: "https://vidsrc.to/embed/\(item.title == nil ? "tv" : "movie")/\(item.id)/\(selectedSeason)/\(ep)") else { return nil }
            return Episode(
                id: ep,
                title: "الحلقة \(ep)",
                episodeNumber: ep,
                videoURL: url
            )
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .trailing, spacing: 15) {
                    // صورة الغلاف والأزرار
                    ZStack(alignment: .topLeading) {
                        AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(height: 300)
                        .clipped()
                        .overlay(
                            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                        )

                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }

                    VStack(alignment: .trailing, spacing: 10) {
                        Text(item.displayTitle)
                            .font(.title).bold()
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            Text(String(format: "%.1f ★", item.voteAverage ?? 0.0))
                                .foregroundColor(.yellow)
                            Text("2026")
                                .foregroundColor(.gray)
                        }

                        Text(item.overview ?? "لا يوجد وصف متاح حالياً.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                            .padding(.vertical, 5)

                        // زر تشغيل العرض الرئيسي
                        Button(action: {
                            if let firstEp = episodes.first {
                                selectedEpisode = firstEp
                            }
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("مشاهدة الآن").bold()
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }

                        // في حال كان مسلسل: قائمة الأجزاء/المواسم والحلقات
                        if item.title == nil { // المسلسلات تحتوي عادة على name وليس title
                            Divider().background(Color.gray.opacity(0.5)).padding(.vertical)

                            Text("المواسم والحلقات")
                                .font(.headline)
                                .foregroundColor(.white)

                            // اختيار الموسم
                            Picker("الموسم", selection: $selectedSeason) {
                                Text("الموسم 1").tag(1)
                                Text("الموسم 2").tag(2)
                                Text("الموسم 3").tag(3)
                            }
                            .pickerStyle(.segmented)
                            .padding(.vertical, 5)

                            // قائمة الحلقات
                            VStack(spacing: 10) {
                                ForEach(episodes) { ep in
                                    Button(action: { selectedEpisode = ep }) {
                                        HStack {
                                            Image(systemName: "play.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.cyan)

                                            Spacer()

                                            Text(ep.title)
                                                .foregroundColor(.white)
                                                .font(.subheadline)
                                        }
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: $selectedEpisode) { ep in
            PlayerContainerView(mediaItem: item)
        }
    }
}
