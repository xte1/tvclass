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

            // شريط تنقل زجاجي عائم ومتناسق
            HStack(spacing: 0) {
                TabBarButton(icon: "tv.fill", title: "الرئيسية", isSelected: selectedTab == 0) { selectedTab = 0 }
                TabBarButton(icon: "film.fill", title: "الأفلام", isSelected: selectedTab == 1) { selectedTab = 1 }
                TabBarButton(icon: "popcorn.fill", title: "المسلسلات", isSelected: selectedTab == 2) { selectedTab = 2 }
                TabBarButton(icon: "heart.fill", title: "المكتبة", isSelected: selectedTab == 3) { selectedTab = 3 }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .frame(maxWidth: 450)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
            .shadow(color: .black.opacity(0.4), radius: 15, y: 5)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .preferredColorScheme(.dark)
        .environment(\.layoutDirection, .rightToLeft)
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
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .white : .white.opacity(0.45))
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
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // الهيدر العلوي
                            HStack {
                                Text("Tvclass")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Spacer()

                                Image(systemName: "tv.badge.wifi")
                                    .font(.title2)
                                    .foregroundColor(.cyan)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)

                            // البوستر الرئيسي متناسق الحجم
                            if let featured = apiService.featuredMovies.first {
                                ZStack(alignment: .bottomLeading) {
                                    AsyncImage(url: featured.backdropURL ?? featured.posterURL) { img in
                                        img.resizable().scaledToFill()
                                    } placeholder: {
                                        Rectangle().fill(Color.white.opacity(0.05))
                                    }
                                    .frame(width: geo.size.width - 32, height: min(geo.size.height * 0.45, 380))
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .overlay(
                                        LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                                    )

                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(featured.displayTitle)
                                            .font(.title2).bold()
                                            .foregroundColor(.white)
                                            .lineLimit(1)

                                        HStack(spacing: 12) {
                                            Button(action: { selectedMedia = featured }) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "play.fill")
                                                    Text("تشغيل").bold()
                                                }
                                                .font(.subheadline)
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 22)
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

                            AppleTVRow(title: "الأفلام الأكثر مشاهدة", items: apiService.trendingMovies) { item in
                                selectedMedia = item
                            }

                            AppleTVRow(title: "المسلسلات الحصرية", items: apiService.trendingSeries) { item in
                                selectedMedia = item
                            }

                            Spacer().frame(height: 100)
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
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3).bold()
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(items) { item in
                        Button(action: { onSelect(item) }) {
                            VStack(alignment: .leading, spacing: 6) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.white.opacity(0.05)
                                }
                                .frame(width: 130, height: 190)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))

                                Text(item.displayTitle)
                                    .font(.caption).bold()
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: 130, alignment: .leading)
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

struct AppleTVGrid: View {
    let title: String
    let items: [MediaItem]
    let onSelect: (MediaItem) -> Void

    let columns = [GridItem(.adaptive(minimum: 120, maximum: 170), spacing: 16)]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading) {
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
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
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
