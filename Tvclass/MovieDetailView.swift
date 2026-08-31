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
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            // الخلفية الضبابية المحيطة
            AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.black
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: 50)
            .overlay(Color.black.opacity(0.78))
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // البوستر الرئيسي العلوي بالكامل
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(Color.white.opacity(0.05))
                        }
                        .frame(height: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            LinearGradient(colors: [.clear, .black.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                        )

                        VStack(alignment: .leading, spacing: 10) {
                            Text(item.displayTitle)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            HStack(spacing: 10) {
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

                            // أزرار المشاهدة والإضافة للمفضلة
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
                                    HStack(spacing: 8) {
                                        Image(systemName: "play.fill")
                                        Text("مشاهدة").bold()
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
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
                                        .frame(width: 48, height: 48)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 50)

                    // قصة الفلم/المسلسل
                    VStack(alignment: .leading, spacing: 8) {
                        Text("عن العمل")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(item.overview ?? "شاهد أفضل العروض الحصرية بدقة 4K مع ترجمة عربية كاملة وصوت محيطي.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal, 16)

                    // الحلقات والمواسم للمسلسلات
                    if item.title == nil {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("الحلقات")
                                    .font(.title3).bold()
                                    .foregroundColor(.white)

                                Spacer()

                                Menu {
                                    ForEach(1...5, id: \.self) { s in
                                        Button("الموسم \(s)") { selectedSeason = s }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Text("الموسم \(selectedSeason)")
                                            .font(.subheadline).bold()
                                        Image(systemName: "chevron.down")
                                            .font(.caption).bold()
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 20)

                            VStack(spacing: 10) {
                                ForEach(1...8, id: \.self) { ep in
                                    Button(action: {
                                        if let url = URL(string: "https://vidsrc.pro/embed/tv/\(item.id)/\(selectedSeason)/\(ep)?sub.ar=true") {
                                            selectedEpisodeURL = url
                                            showPlayer = true
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                                                    img.resizable().scaledToFill()
                                                } placeholder: {
                                                    Color.white.opacity(0.05)
                                                }
                                                .frame(width: 100, height: 62)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                                Image(systemName: "play.circle.fill")
                                                    .font(.title3)
                                                    .foregroundColor(.white)
                                            }

                                            VStack(alignment: .leading, spacing: 3) {
                                                Text("الحلقة \(ep)")
                                                    .font(.subheadline).bold()
                                                    .foregroundColor(.white)
                                                Text("الموسم \(selectedSeason)")
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.6))
                                            }

                                            Spacer()
                                        }
                                        .padding(10)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.bottom, 60)
            }

            // زر عودة علوي بارز ومباشر
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
