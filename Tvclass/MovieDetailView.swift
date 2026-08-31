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
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()

                AsyncImage(url: item.posterURL ?? item.backdropURL) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.black
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .blur(radius: 40)
                .overlay(Color.black.opacity(0.75))
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        ZStack(alignment: .bottomLeading) {
                            AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Rectangle().fill(Color.white.opacity(0.1))
                            }
                            .frame(height: min(geo.size.height * 0.35, 300))
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                            )
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 16)

                        VStack(spacing: 8) {
                            Text(item.displayTitle)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 8) {
                                Text("Apple Original")
                                    .font(.caption2).bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(6)
                                
                                Text("4K HDR")
                                    .font(.caption2).bold()
                                    .foregroundColor(.white.opacity(0.8))

                                Text(String(format: "★ %.1f", item.voteAverage ?? 0.0))
                                    .font(.caption2).bold()
                                    .foregroundColor(.yellow)
                            }

                            HStack(spacing: 12) {
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
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: 300)
                                    .frame(height: 44)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                }

                                Button(action: {
                                    if isFavorite {
                                        favorites.removeAll(where: { $0.id == item.id })
                                    } else {
                                        favorites.append(item)
                                    }
                                }) {
                                    Image(systemName: isFavorite ? "checkmark" : "plus")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }

                        VStack(alignment: .trailing, spacing: 6) {
                            Text("حول العمل")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(item.overview ?? "شاهد أفضل العروض الحصرية بدقة عالية مع ترجمة عربية كاملة وصوت محيطي.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.trailing)
                                .lineSpacing(3)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)

                        if item.title == nil {
                            VStack(alignment: .trailing, spacing: 12) {
                                HStack {
                                    Menu {
                                        ForEach(1...5, id: \.self) { s in
                                            Button("الموسم \(s)") { selectedSeason = s }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "chevron.down")
                                                .font(.caption2).bold()
                                            Text("الموسم \(selectedSeason)")
                                                .font(.caption).bold()
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                    }

                                    Spacer()

                                    Text("الحلقات")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)

                                VStack(spacing: 8) {
                                    ForEach(1...8, id: \.self) { ep in
                                        Button(action: {
                                            if let url = URL(string: "https://vidsrc.pro/embed/tv/\(item.id)/\(selectedSeason)/\(ep)?sub.ar=true") {
                                                selectedEpisodeURL = url
                                                showPlayer = true
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.title3)
                                                    .foregroundColor(.white)

                                                Spacer()

                                                VStack(alignment: .trailing, spacing: 2) {
                                                    Text("الحلقة \(ep)")
                                                        .font(.subheadline).bold()
                                                        .foregroundColor(.white)
                                                    Text("الموسم \(selectedSeason)")
                                                        .font(.caption2)
                                                        .foregroundColor(.white.opacity(0.6))
                                                }
                                            }
                                            .padding(12)
                                            .background(.ultraThinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.bottom, 60)
                }

                // زر العودة العلوي التكيفي
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                            Text("رجوع")
                                .font(.subheadline).bold()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.4), radius: 5)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 15)
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
