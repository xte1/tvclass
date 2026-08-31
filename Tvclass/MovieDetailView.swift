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
            ZStack(alignment: .topLeading) {
                Color.black.ignoresSafeArea()

                // الخلفية الضبابية
                AsyncImage(url: item.posterURL ?? item.backdropURL) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.black
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .blur(radius: 50)
                .overlay(Color.black.opacity(0.8))
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // بوستر العرض
                        ZStack(alignment: .bottomLeading) {
                            AsyncImage(url: item.backdropURL ?? item.posterURL) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Rectangle().fill(Color.white.opacity(0.05))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: min(geo.size.height * 0.4, 320))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                            )
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 16)

                        // تفاصيل العرض والأزرار
                        VStack(alignment: .leading, spacing: 12) {
                            Text(item.displayTitle)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)

                            HStack(spacing: 10) {
                                Text("4K HDR")
                                    .font(.caption2).bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(6)

                                Text(String(format: "★ %.1f", item.voteAverage ?? 0.0))
                                    .font(.caption).bold()
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
                                    .padding(.horizontal, 30)
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
                            .padding(.top, 6)
                        }
                        .padding(.horizontal, 20)

                        // ملخص القصة
                        VStack(alignment: .leading, spacing: 8) {
                            Text("القصة")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(item.overview ?? "شاهد العرض بدقة عالية وترجمة عربية تلقائية.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.75))
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, 16)

                        // قائمة المواسم والحلقات عند اختيار مسلسل
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
                                            HStack {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.white)

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("الحلقة \(ep)")
                                                        .font(.subheadline).bold()
                                                        .foregroundColor(.white)
                                                    Text("اضغط للمشاهدة")
                                                        .font(.caption2)
                                                        .foregroundColor(.white.opacity(0.6))
                                                }

                                                Spacer()
                                            }
                                            .padding(14)
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

                // زر الإغلاق / الرجوع العلوي
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.leading, 20)
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
