import SwiftUI

struct ContentView: View {
    @StateObject private var apiService = APIService()
    @State private var selectedTab = 0
    @State private var favorites: [MediaItem] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            // الشاشة المعروضة بحسب التبويب المحدد
            Group {
                switch selectedTab {
                case 0:
                    HomeView(apiService: apiService, favorites: $favorites)
                case 1:
                    MoviesView(apiService: apiService, favorites: $favorites)
                case 2:
                    SeriesView(apiService: apiService, favorites: $favorites)
                case 3:
                    LibraryView(favorites: $favorites)
                default:
                    HomeView(apiService: apiService, favorites: $favorites)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // شريط التنقل الزجاجي العائم (Apple TV Liquid Glass TabBar)
            HStack(spacing: 28) {
                TabBarButton(icon: "tv.fill", title: "الرئيسية", isSelected: selectedTab == 0) { selectedTab = 0 }
                TabBarButton(icon: "film.fill", title: "الأفلام", isSelected: selectedTab == 1) { selectedTab = 1 }
                TabBarButton(icon: "popcorn.fill", title: "المسلسلات", isSelected: selectedTab == 2) { selectedTab = 2 }
                TabBarButton(icon: "heart.fill", title: "المكتبة", isSelected: selectedTab == 3) { selectedTab = 3 }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
            .padding(.bottom, 25)
        }
        .preferredColorScheme(.dark)
        .environment(\.layoutDirection, .leftToRight) // منع عكس الكلمات العربية
        .onAppear {
            apiService.fetchAllData()
        }
    }
}

// MARK: - أزرار شريط التنقل الزجاجي
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .bold))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.4))
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

// MARK: - الصفحة الرئيسية بأسلوب Apple TV
struct HomeView: View {
    @ObservedObject var apiService: APIService
    @Binding var favorites: [MediaItem]
    @State private var selectedMedia: MediaItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .trailing, spacing: 24) {
                        
                        // الهيدر العلوي والشعار
                        HStack {
                            Image(systemName: "tv.badge.wifi")
                                .font(.title2)
                                .foregroundColor(.cyan)

                            Spacer()

                            Text("Tvclass")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                        // البوستر الرئيسي (Apple TV Hero Banner)
                        if let featured = apiService.featuredMovies.first {
                            ZStack(alignment: .bottomTrailing) {
                                AsyncImage(url: featured.backdropURL ?? featured.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle().fill(Color.white.opacity(0.05))
                                }
                                .frame(height: 400)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(
                                    LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )

                                VStack(alignment: .trailing, spacing: 10) {
                                    Text(featured.displayTitle)
                                        .font(.title).bold()
                                        .foregroundColor(.white)

                                    HStack(spacing: 15) {
                                        Button(action: { selectedMedia = featured }) {
                                            HStack {
                                                Image(systemName: "play.fill")
                                                Text("مشاهدة").bold()
                                            }
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 25)
                                            .padding(.vertical, 10)
                                            .background(Color.white)
                                            .clipShape(Capsule())
                                        }
                                    }
                                }
                                .padding(20)
                            }
                            .padding(.horizontal, 16)
                        }

                        // الأقسام الأفقية
                        AppleTVRow(title: "الأفلام الأكثر مشاهدة", items: apiService.trendingMovies) { item in
                            selectedMedia = item
                        }

                        AppleTVRow(title: "المسلسلات الحصرية", items: apiService.trendingSeries) { item in
                            selectedMedia = item
                        }

                        Spacer().frame(height: 90)
                    }
                }
            }
            .fullScreenCover(item: $selectedMedia) { item in
                MovieDetailView(item: item, favorites: $favorites)
            }
        }
    }
}

// MARK: - صف أفقـي كروت Apple TV
struct AppleTVRow: View {
    let title: String
    let items: [MediaItem]
    let onSelect: (MediaItem) -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text(title)
                .font(.title3).bold()
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items) { item in
                        Button(action: { onSelect(item) }) {
                            VStack(alignment: .trailing, spacing: 6) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.white.opacity(0.05)
                                }
                                .frame(width: 140, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))

                                Text(item.displayTitle)
                                    .font(.caption).bold()
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: 140, alignment: .trailing)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - باقي التبويبات (أفلام، مسلسلات، مكتبة)
struct MoviesView: View {
    @ObservedObject var apiService: APIService
    @Binding var favorites: [MediaItem]
    @State private var selectedMedia: MediaItem?

    var body: some View {
        AppleTVGrid(title: "الأفلام", items: apiService.trendingMovies) { selectedMedia = $0 }
            .fullScreenCover(item: $selectedMedia) { item in
                MovieDetailView(item: item, favorites: $favorites)
            }
    }
}

struct SeriesView: View {
    @ObservedObject var apiService: APIService
    @Binding var favorites: [MediaItem]
    @State private var selectedMedia: MediaItem?

    var body: some View {
        AppleTVGrid(title: "المسلسلات", items: apiService.trendingSeries) { selectedMedia = $0 }
            .fullScreenCover(item: $selectedMedia) { item in
                MovieDetailView(item: item, favorites: $favorites)
            }
    }
}

struct LibraryView: View {
    @Binding var favorites: [MediaItem]
    @State private var selectedMedia: MediaItem?

    var body: some View {
        AppleTVGrid(title: "المكتبة والمفضلة", items: favorites) { selectedMedia = $0 }
            .fullScreenCover(item: $selectedMedia) { item in
                MovieDetailView(item: item, favorites: $favorites)
            }
    }
}

struct AppleTVGrid: View {
    let title: String
    let items: [MediaItem]
    let onSelect: (MediaItem) -> Void

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .trailing) {
                Text(title)
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .padding([.top, .horizontal], 20)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(items) { item in
                            Button(action: { onSelect(item) }) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.white.opacity(0.05)
                                }
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 1))
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 90)
                }
            }
        }
    }
}
