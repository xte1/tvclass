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
                    MoviesView(apiService: apiService)
                case 2:
                    SeriesView(apiService: apiService)
                case 3:
                    LibraryView(favorites: $favorites)
                case 4:
                    SearchView(apiService: apiService)
                default:
                    HomeView(apiService: apiService, favorites: $favorites)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // شريط التنقل الزجاجي العائم (Glass Floating TabBar)
            CustomGlassTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
        }
        .preferredColorScheme(.dark)
        .environment(\.layoutDirection, .leftToRight) // إصلاح عكس الحروف والكلمات العربية
        .onAppear {
            apiService.fetchAllData()
        }
    }
}

// MARK: - شريط التنقل الزجاجي العائم
struct CustomGlassTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "magnifyingglass", title: "بحث", tabIndex: 4, selectedTab: $selectedTab)
            TabBarButton(icon: "bookmark.fill", title: "المكتبة", tabIndex: 3, selectedTab: $selectedTab)
            TabBarButton(icon: "tv.fill", title: "مسلسلات", tabIndex: 2, selectedTab: $selectedTab)
            TabBarButton(icon: "film.fill", title: "أفلام", tabIndex: 1, selectedTab: $selectedTab)
            TabBarButton(icon: "house.fill", title: "الرئيسية", tabIndex: 0, selectedTab: $selectedTab)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 10)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let tabIndex: Int
    @Binding var selectedTab: Int

    var isSelected: Bool { selectedTab == tabIndex }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tabIndex
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .cyan : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(isSelected ? Color.white.opacity(0.15) : Color.clear)
            .cornerRadius(20)
        }
    }
}

// MARK: - الصفحة الرئيسية
struct HomeView: View {
    @ObservedObject var apiService: APIService
    @Binding var favorites: [MediaItem]
    @State private var showSettings = false
    @State private var selectedMediaForPlayer: MediaItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .trailing, spacing: 20) {
                        // شريط العلوي (Logo + الأزرار)
                        HStack {
                            Button(action: { showSettings.toggle() }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Text("Tvclass")
                                .font(.title2).bold()
                                .foregroundColor(.white)

                            Spacer()

                            Image(systemName: "tv.badge.wifi")
                                .font(.title2)
                                .foregroundColor(.cyan)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // العرض البارز الرئيسي (Featured Poster)
                        if let featured = apiService.featuredMovies.first {
                            ZStack(alignment: .bottom) {
                                AsyncImage(url: featured.backdropURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(height: 440)
                                .clipped()
                                .overlay(
                                    LinearGradient(colors: [.clear, .black.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                                )

                                VStack(spacing: 12) {
                                    Text(featured.displayTitle)
                                        .font(.title).bold()
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)

                                    HStack(spacing: 15) {
                                        Text(String(format: "%.1f ★", featured.voteAverage ?? 0.0))
                                            .foregroundColor(.yellow)
                                            .font(.subheadline).bold()
                                        Text("2026")
                                            .foregroundColor(.gray)
                                            .font(.subheadline)
                                    }

                                    HStack(spacing: 20) {
                                        // زر المفضلات / إضافة للمكتبة
                                        Button(action: {
                                            if favorites.contains(where: { $0.id == featured.id }) {
                                                favorites.removeAll(where: { $0.id == featured.id })
                                            } else {
                                                favorites.append(featured)
                                            }
                                        }) {
                                            Image(systemName: favorites.contains(where: { $0.id == featured.id }) ? "checkmark" : "plus")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Circle())
                                        }

                                        // زر التشغيل
                                        Button(action: { selectedMediaForPlayer = featured }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "play.fill")
                                                Text("تشغيل").bold()
                                            }
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 35)
                                            .padding(.vertical, 12)
                                            .background(Color.white)
                                            .cornerRadius(25)
                                        }
                                    }
                                }
                                .padding(.bottom, 20)
                            }
                        }

                        // الأقسام افقياً
                        MediaHorizontalRow(title: "Trending Movies", items: apiService.trendingMovies, onSelect: { selectedMediaForPlayer = $0 })
                        MediaHorizontalRow(title: "Trending TV Shows", items: apiService.trendingSeries, onSelect: { selectedMediaForPlayer = $0 })
                        
                        Spacer().frame(height: 80)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .fullScreenCover(item: $selectedMediaForPlayer) { item in
                PlayerContainerView(mediaItem: item)
            }
        }
    }
}

// MARK: - صفحة الإعدادات
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                List {
                    Section(header: Text("التطبيق")) {
                        HStack {
                            Text("إصدار التطبيق")
                            Spacer()
                            Text("1.0.0").foregroundColor(.gray)
                        }
                        HStack {
                            Text("لغة التطبيق")
                            Spacer()
                            Text("العربية").foregroundColor(.gray)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("الإعدادات")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("تم") { dismiss() }
                }
            }
        }
    }
}

// MARK: - الصف الأفقـي للأفلام والمسلسلات
struct MediaHorizontalRow: View {
    let title: String
    let items: [MediaItem]
    let onSelect: (MediaItem) -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text(title)
                .font(.title3).bold()
                .foregroundColor(.white)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { item in
                        Button(action: { onSelect(item) }) {
                            VStack(alignment: .trailing, spacing: 6) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 130, height: 190)
                                .cornerRadius(14)

                                Text(item.displayTitle)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: 130, alignment: .trailing)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - التبويبات الأخرى
struct MoviesView: View {
    @ObservedObject var apiService: APIService
    @State private var selectedItem: MediaItem?

    var body: some View {
        MediaGridView(title: "الأفلام", items: apiService.trendingMovies, onSelect: { selectedItem = $0 })
            .fullScreenCover(item: $selectedItem) { item in
                PlayerContainerView(mediaItem: item)
            }
    }
}

struct SeriesView: View {
    @ObservedObject var apiService: APIService
    @State private var selectedItem: MediaItem?

    var body: some View {
        MediaGridView(title: "المسلسلات", items: apiService.trendingSeries, onSelect: { selectedItem = $0 })
            .fullScreenCover(item: $selectedItem) { item in
                PlayerContainerView(mediaItem: item)
            }
    }
}

struct LibraryView: View {
    @Binding var favorites: [MediaItem]
    @State private var selectedItem: MediaItem?

    var body: some View {
        MediaGridView(title: "المكتبة والمفضلة", items: favorites, onSelect: { selectedItem = $0 })
            .fullScreenCover(item: $selectedItem) { item in
                PlayerContainerView(mediaItem: item)
            }
    }
}

struct SearchView: View {
    @ObservedObject var apiService: APIService
    @State private var query = ""
    @State private var selectedItem: MediaItem?

    var body: some View {
        VStack {
            TextField("ابحث عن فيلم أو مسلسل...", text: $query)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding()
                .onChange(of: query) { newValue in
                    apiService.search(query: newValue)
                }

            MediaGridView(title: "نتائج البحث", items: apiService.searchResults, onSelect: { selectedItem = $0 })
        }
        .background(Color.black.ignoresSafeArea())
        .fullScreenCover(item: $selectedItem) { item in
            PlayerContainerView(mediaItem: item)
        }
    }
}

struct MediaGridView: View {
    let title: String
    let items: [MediaItem]
    let onSelect: (MediaItem) -> Void

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .trailing) {
                Text(title)
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .padding([.top, .horizontal])

                if items.isEmpty {
                    Spacer()
                    Text("لا توجد عناصر لعرضها")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(items) { item in
                                Button(action: { onSelect(item) }) {
                                    VStack(alignment: .trailing, spacing: 6) {
                                        AsyncImage(url: item.posterURL) { img in
                                            img.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                        }
                                        .frame(height: 160)
                                        .cornerRadius(12)

                                        Text(item.displayTitle)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, 90)
                    }
                }
            }
        }
    }
}
