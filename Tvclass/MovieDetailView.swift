import SwiftUI

struct MovieDetailView: View {
    let item: MediaItem
    @Binding var favorites: [MediaItem]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedSeason = 1
    @State private var selectedEpisodeURL: URL? = nil
    @State private var showPlayer = false

    var isFavorite: Bool {
        favorites.contains(where: { $0.id == item.id })
    }

    var body: some View {
        ZStack {
            AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.black
            }
            .ignoresSafeArea()
            .blur(radius: 50)
            .overlay(Color.black.opacity(0.65))

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(Color.white.opacity(0.05))
                        }
                        .frame(height: 420)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 12) {
                            Text(item.displayTitle)
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 8)

                            HStack(spacing: 10) {
                                Text("Apple Original")
                                    .font(.caption2).bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(6)
                                
                                Text("4K HDR • 5.1")
                                    .font(.caption).bold()
                                    .foregroundColor(.white.opacity(0.8))

                                Text(String(format: "★ %.1f", item.voteAverage ?? 0.0))
                                    .font(.caption).bold()
                                    .foregroundColor(.yellow)
                            }

                            HStack(spacing: 14) {
                                Button(action: {
                                    let isMovie = item.title != nil
                                    let urlStr = isMovie ?
                                        "https://vidsrc.pro/embed/movie/\(item.id)?sub.ar=true" :
                                        "https://vidsrc.pro/embed/tv/\(item.id)/\(selectedSeason)/1?sub.ar=true"
                                    if let url = URL(string: urlStr) {
                                        selectedEpisodeURL = url
                                        showPlayer = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("تشغيل").bold()
                                    }
                                    .foregroundColor(.black)
                                    .frame(width: 140, height: 48)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .shadow(color: .white.opacity(0.25), radius: 12)
                                }

                                Button(action: {
                                    if isFavorite {
                                        favorites.removeAll(where: { $0.id == item.id })
                                    } else {
                                        favorites.append(item)
                                    }
                                }) {
                                    Image(systemName: isFavorite ? "checkmark" : "plus")
                                        .font(.title3).bold()
                                        .foregroundColor(.white)
                                        .frame(width: 48, height: 48)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                }
                            }
                            .padding(.top, 6)
                        }
                        .padding(24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 60)

                    VStack(alignment: .trailing, spacing: 8) {
                        Text("حول العمل")
                            .font(.title3).bold()
                            .foregroundColor(.white)

                        Text(item.overview ?? "شاهد أفضل العروض الحصرية بدقة 4K مع ترجمة عربية كاملة وصوت محيطي.")
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .padding(.horizontal, 16)

                    if item.title == nil {
                        VStack(alignment: .trailing, spacing: 16) {
                            HStack {
                                Menu {
                                    ForEach(1...5, id: \.self) { s in
                                        Button("الموسم \(s)") { selectedSeason = s }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.down")
                                            .font(.caption).bold()
                                        Text("الموسم \(selectedSeason)")
                                            .font(.subheadline).bold()
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                }

                                Spacer()

                                Text("الحلقات")
                                    .font(.title2).bold()
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(1...10, id: \.self) { ep in
                                        AppleTVEpisodeCard(epNumber: ep, item: item, season: selectedSeason) {
                                            if let url = URL(string: "https://vidsrc.pro/embed/tv/\(item.id)/\(selectedSeason)/\(ep)?sub.ar=true") {
                                                selectedEpisodeURL = url
                                                showPlayer = true
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 50)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showPlayer) {
            if let url = selectedEpisodeURL {
                NativeWebPlayer(url: url)
            }
        }
    }
}

struct AppleTVEpisodeCard: View {
    let epNumber: Int
    let item: MediaItem
    let season: Int
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .center) {
                    AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Color.white.opacity(0.05)
                    }
                    .frame(width: 220, height: 125)
                    .clipped()

                    Color.black.opacity(0.3)

                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 6)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(epNumber). الحلقة \(epNumber)")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("الموسم \(season)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 4)
            }
            .frame(width: 220)
        }
    }
}
