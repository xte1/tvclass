import SwiftUI

struct ContentView: View {
    @StateObject private var apiService = APIService()
    @State private var selectedTab = 0
    @State private var favorites: [MediaItem] = []

    var body: some View {
        ZStack(alignment: .bottom) {
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

            // شريط تنقل زجاجي عائم يتأقلم بحسب عرض الشاشة
            HStack(spacing: 0) {
                TabBarButton(icon: "tv.fill", title: "الرئيسية", isSelected: selectedTab == 0) { selectedTab = 0 }
                TabBarButton(icon: "film.fill", title: "الأفلام", isSelected: selectedTab == 1) { selectedTab = 1 }
                TabBarButton(icon: "popcorn.fill", title: "المسلسلات", isSelected: selectedTab == 2) { selectedTab = 2 }
                TabBarButton(icon: "heart.fill", title: "المكتبة", isSelected: selectedTab == 3) { selectedTab = 3 }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: 500) // حد أقصى للعرض للشاشات الكبيرة كـ iPad
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
            .shadow(color: .black.opacity(0.4), radius: 15, y: 5)
            .padding(.horizontal, 16)
            .padding(.bottom, 15)
        }
        .preferredColorScheme(.dark)
        .environment(\.layoutDirection, .leftToRight)
        .onAppear {
            apiService.fetchAllData()
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .regular))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .white : .white.opacity(0.4))
        }
    }
}

struct HomeView: View {
    @ObservedObject var apiService: APIService
    @Binding var favorites: [MediaItem]
    @State private var selectedMedia: MediaItem?

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    Color.black.ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .trailing, spacing: 20) {
                            
                            // الهيدر العلوي
                            HStack {
                                Image(systemName: "tv.badge.wifi")
                                    .font(.title3)
                                    .foregroundColor(.cyan)

                                Spacer()

                                Text("Tvclass")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)

                            // البوستر الرئيسي يتكيف طوله مع حجم الشاشة
                            if let featured = apiService.featuredMovies.first {
                                ZStack(alignment: .bottomTrailing) {
                                    AsyncImage(url: featured.backdropURL ?? featured.posterURL) { img in
                                        img.resizable().scaledToFill()
                                    } placeholder: {
                                        Rectangle().fill(Color.white.opacity(0.05))
                                    }
                                    .frame(height: min(geo.size.height * 0.45, 380))
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                                    )

                                    VStack(alignment: .trailing, spacing: 8) {
                                        Text(featured.displayTitle)
                                            .font(.title3).bold()
                                            .foregroundColor(.white)

                                        Button(action: { selectedMedia = featured }) {
                                            HStack {
                                                Image(systemName: "play.fill")
                                                Text("مشاهدة").bold()
                                            }
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 8)
                                            .background(Color.white)
                                            .clipShape(Capsule())
                                        }
                                    }
                                    .padding(16)
                                }
                                .padding(.horizontal, 16)
                            }

                            AppleTVRow(title: "الأفلام الأكثر مشاهدة", items: apiService.trendingMovies) { item in
                                selectedMedia = item
                            }

                            AppleTVRow(title: "المسلسلات الحصرية", items: apiService.trendingSeries) { item in
                                selectedMedia = item
                            }

                            Spacer().frame(height: 80)
                        }
                    }
                }
            }
            .fullScreenCover(item: $selectedMedia) { item in
                MovieDetailView(item: item, favorites: $favorites)
            }
        }
    }
}

struct AppleTVRow: View {
    let title: String
    let items: [MediaItem]
    let onSelect: (MediaItem) -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(items) { item in
                        Button(action: { onSelect(item) }) {
                            VStack(alignment: .trailing, spacing: 4) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.white.opacity(0.05)
                                }
                                .frame(width: 125, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))

                                Text(item.displayTitle)
                                    .font(.caption).bold()
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: 125, alignment: .trailing)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

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

// شبكة متكيفة تلقائياً بحسب عرض الشاشة (تزيد الأعمدة في iPad وتقل في iPhone)
struct AppleTVGrid: View {
    let title: String
    let items: [MediaItem]
    let onSelect: (MediaItem) -> Void

    let columns = [GridItem(.adaptive(minimum: 110, maximum: 160), spacing: 14)]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .trailing) {
                Text(title)
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .padding([.top, .horizontal], 20)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(items) { item in
                            Button(action: { onSelect(item) }) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.white.opacity(0.05)
                                }
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80)
                }
            }
        }
    }
}
