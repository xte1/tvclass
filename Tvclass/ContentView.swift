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

            // شريط التنقل السفلي العائم (زجاجي ومستقر)
            HStack(spacing: 0) {
                TabBarButton(icon: "tv.fill", title: "الرئيسية", isSelected: selectedTab == 0) { selectedTab = 0 }
                TabBarButton(icon: "film.fill", title: "الأفلام", isSelected: selectedTab == 1) { selectedTab = 1 }
                TabBarButton(icon: "popcorn.fill", title: "المسلسلات", isSelected: selectedTab == 2) { selectedTab = 2 }
                TabBarButton(icon: "magnifyingglass", title: "البحث", isSelected: selectedTab == 3) { selectedTab = 3 }
                TabBarButton(icon: "gearshape.fill", title: "الإعدادات", isSelected: selectedTab == 4) { selectedTab = 4 }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
            .shadow(color: .black.opacity(0.5), radius: 15, y: 5)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
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
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                Text(title)
                    .font(.system(size: 9, weight: isSelected ? .bold : .regular))
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
                    VStack(alignment: .leading, spacing: 20) {
                        
                        HStack {
                            Text("Tvclass")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Spacer()

                            Image(systemName: "tv.badge.wifi")
                                .font(.title3)
                                .foregroundColor(.cyan)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                        if let featured = apiService.featuredMovies.first {
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: featured.backdropURL ?? featured.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle().fill(Color.white.opacity(0.05))
                                }
                                .frame(height: 280)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                                )

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(featured.displayTitle)
                                        .font(.headline).bold()
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    Button(action: { selectedMedia = featured }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "play.fill")
                                            Text("تشغيل الآن").bold()
                                        }
                                        .font(.caption)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 18)
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
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline).bold()
                .foregroundColor(.white)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        Button(action: { onSelect(item) }) {
                            VStack(alignment: .leading, spacing: 4) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.white.opacity(0.05)
                                }
                                .frame(width: 115, height: 170)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                Text(item.displayTitle)
                                    .font(.caption2).bold()
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: 115, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
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

// MARK: - شاشة البحث (محدثة لتعمل بدقة واستجابة فورية)
struct SearchView: View {
    @ObservedObject var apiService: APIService
    @Binding var favorites: [MediaItem]
    @State private var searchText = ""
    @State private var selectedMedia: MediaItem?

    // دمج الأفلام والمسلسلات معاً ليكون البحث شامل وعملي
    var searchResults: [MediaItem] {
        let combined = apiService.trendingMovies + apiService.trendingSeries
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return combined
        }
        return combined.filter { item in
            item.displayTitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                Text("البحث")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                // حقل كتابة البحث
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("ابحث عن فيلم أو مسلسل...", text: $searchText)
                        .foregroundColor(.white)
                        .autocorrectionDisabled(true)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)

                // نتائج البحث بنظام شبكة متناسق
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(searchResults) { item in
                            Button(action: { selectedMedia = item }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    AsyncImage(url: item.posterURL) { img in
                                        img.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.white.opacity(0.05)
                                    }
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                    Text(item.displayTitle)
                                        .font(.caption2).bold()
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
                }
            }
        }
        .fullScreenCover(item: $selectedMedia) { item in
            MovieDetailView(item: item, favorites: $favorites)
        }
    }
}

// MARK: - الإعدادات
struct SettingsView: View {
    let favoritesCount: Int

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("الإعدادات")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                List {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.cyan)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("حساب Tvclass")
                                    .font(.headline)
                                Text("نشط • جودة 4K HDR")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    Section(header: Text("المفضلة").foregroundColor(.gray)) {
                        HStack {
                            Text("العناصر المحفوظة")
                            Spacer()
                            Text("\(favoritesCount)")
                                .foregroundColor(.gray)
                        }
                    }

                    Section(header: Text("حول التطبيق").foregroundColor(.gray)) {
                        HStack {
                            Text("الإصدار")
                            Spacer()
                            Text("1.1.0")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

// MARK: - شبكة العرض العامة
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
                        .font(.title2).bold()
                        .foregroundColor(.white)
                        .padding([.top, .horizontal], 16)
                }

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(items) { item in
                            Button(action: { onSelect(item) }) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.white.opacity(0.05)
                                }
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
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
