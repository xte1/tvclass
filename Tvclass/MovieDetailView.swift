import SwiftUI
import WebKit

struct NativeWebPlayerView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = true
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

struct NativeWebPlayer: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            NativeWebPlayerView(url: url)
                .ignoresSafeArea()

            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                    Text("إغلاق")
                        .font(.caption).bold()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.7))
                .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.5), radius: 10)
            }
            .padding(.top, 40)
            .padding(.trailing, 20)
        }
        .statusBarHidden(true)
    }
}

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
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.black
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .blur(radius: 40)
            .overlay(Color.black.opacity(0.82))
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(Color.white.opacity(0.05))
                        }
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)
                        .clipped() // منع تجاوز الحواف وتمدد الصورة
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            LinearGradient(colors: [.clear, .black.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.displayTitle)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            HStack(spacing: 8) {
                                Text("Apple Original")
                                    .font(.caption2).bold()
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(6)

                                Text("4K HDR")
                                    .font(.caption2).bold()
                                    .foregroundColor(.white.opacity(0.8))

                                Text(String(format: "★ %.1f", item.voteAverage ?? 0.0))
                                    .font(.caption2).bold()
                                    .foregroundColor(.yellow)
                            }

                            HStack(spacing: 10) {
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
                                    HStack(spacing: 6) {
                                        Image(systemName: "play.fill")
                                        Text("تشغيل").bold()
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
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
                            .padding(.top, 4)
                        }
                        .padding(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 50)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("عن العمل")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(item.overview ?? "شاهد العرض بدقة عالية مع ترجمة عربية كاملة وصوت محيطي.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.75))
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)

                    if item.title == nil {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("الحلقات")
                                    .font(.subheadline).bold()
                                    .foregroundColor(.white)

                                Spacer()

                                Menu {
                                    ForEach(1...5, id: \.self) { s in
                                        Button("الموسم \(s)") { selectedSeason = s }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("الموسم \(selectedSeason)")
                                            .font(.caption).bold()
                                        Image(systemName: "chevron.down")
                                            .font(.caption2).bold()
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                }
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
                                        HStack(spacing: 10) {
                                            Image(systemName: "play.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.white)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("الحلقة \(ep)")
                                                    .font(.subheadline).bold()
                                                    .foregroundColor(.white)
                                                Text("الموسم \(selectedSeason)")
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.6))
                                            }

                                            Spacer()
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

            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                    Text("رجوع")
                        .font(.subheadline).bold()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.4), radius: 5)
            }
            .padding(.leading, 16)
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showPlayer) {
            if let url = selectedEpisodeURL {
                NativeWebPlayer(url: url)
            }
        }
    }
}
