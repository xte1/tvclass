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
                    SearchView(apiService: apiService, favorites: $favorites)
                case 4:
                    SettingsView(favoritesCount: favorites.count)
                default:
                    HomeView(apiService: apiService, favorites: $favorites)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // شريط التنقل السفلي الأصلي والمتناسق مع الآيفون 12 Pro Max
            HStack(spacing: 0) {
                TabBarButton(icon: "tv.fill", title: "الرئيسية", isSelected: selectedTab == 0) { selectedTab = 0 }
                TabBarButton(icon: "film.fill", title: "الأفلام", isSelected: selectedTab == 1) { selectedTab = 1 }
                TabBarButton(icon: "popcorn.fill", title: "المسلسلات", isSelected: selectedTab == 2) { selectedTab = 2 }
                TabBarButton(icon: "magnifyingglass", title: "البحث", isSelected: selectedTab == 3) { selectedTab = 3 }
                TabBarButton(icon: "gearshape.fill", title: "الإعدادات", isSelected: selectedTab == 4) { selectedTab = 4 }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
            .shadow(color: .black.opacity(0.5), radius: 15, y: 5)
            .padding(.horizontal, 16)
            .padding(.bottom, 15)
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
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: isSelected ? .bold : .regular))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .regular))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .white : .white.opacity(0.45))
        }
    }
}

// MARK: - الرئيسية
struct HomeView: View {
    @ObservedObject var apiService: APIService
    @Binding var favorites: [MediaItem]
    @State private var selectedMedia: MediaItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        HStack {
                            Text("Tvclass")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)

                            Spacer()

                            Image(systemName: "tv.badge.wifi")
                                .font(.title2)
                                .foregroundColor(.cyan)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                        if let featured = apiService.featuredMovies.first {
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: featured.backdropURL ?? featured.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle().fill(Color.white.opacity(0.05))
                                }
                                .frame(height: 340)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(
                                    LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                                )

                                VStack(alignment: .leading, spacing: 10) {
                                    Text(featured.displayTitle)
                                        .font(.title2).bold()
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    Button(action: { selectedMedia = featured }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "play.fill")
                                            Text("مشاهدة الآن").bold()
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 22)
                                        .padding(.vertical, 10)
                                        .background(Color.white)
                                        .clipShape(Capsule())
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
                                .frame(width: 125, height: 185)
                                .clipShape(RoundedRectangle(cornerRadius: 16))

                                Text(item.displayTitle)
                                    .font(.caption).bold()
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: 125, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - الأفلام
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

// MARK: - المسلسلات
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

// MARK: - شاشة البحث الجديدة
struct SearchView: View {
    @ObservedObject var apiService: APIService
    @Binding var favorites: [MediaItem]
    @State private var searchText = ""
    @State private var selectedMedia: MediaItem?

    var filteredItems: [MediaItem] {
        let all = apiService.trendingMovies + apiService.trendingSeries
        if searchText.isEmpty { return all }
        return all.filter { $0.displayTitle.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("البحث")
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("ابحث عن فيلم، مسلسل...", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)

                AppleTVGrid(title: "", items: filteredItems) { selectedMedia = $0 }
            }
            .padding(.top, 10)
        }
        .fullScreenCover(item: $selectedMedia) { item in
            MovieDetailView(item: item, favorites: $favorites)
        }
    }
}

// MARK: - شاشة الإعدادات الجديدة
struct SettingsView: View {
    let favoritesCount: Int

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("الإعدادات")
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                List {
                    Section {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.cyan)
                            VStack(alignment: .leading) {
                                Text("حساب Tvclass")
                                    .font(.headline)
                                Text("اشتراك موثق 4K")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    Section(header: Text("المكتبة").foregroundColor(.gray)) {
                        HStack {
                            Text("العناصر المفضلة")
                            Spacer()
                            Text("\(favoritesCount)")
                                .foregroundColor(.gray)
                        }
                    }

                    Section(header: Text("التطبيق").foregroundColor(.gray)) {
                        HStack {
                            Text("الإصدار")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .padding(.top, 10)
        }
    }
}

// MARK: - الشبكة الشبكية التكيفية
struct AppleTVGrid: View {
    let title: String
    let items: [MediaItem]
    let onSelect: (MediaItem) -> Void

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading) {
                if !title.isEmpty {
                    Text(title)
                        .font(.title).bold()
                        .foregroundColor(.white)
                        .padding([.top, .horizontal], 20)
                }

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(items) { item in
                            Button(action: { onSelect(item) }) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.white.opacity(0.05)
                                }
                                .frame(height: 165)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
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
