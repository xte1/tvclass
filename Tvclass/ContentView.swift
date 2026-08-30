import SwiftUI

struct ContentView: View {
    @StateObject private var apiService = APIService()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(apiService: apiService)
                .tabItem { Label("الرئيسية", systemImage: "house.fill") }
                .tag(0)

            MoviesView(apiService: apiService)
                .tabItem { Label("الأفلام", systemImage: "film") }
                .tag(1)

            SeriesView(apiService: apiService)
                .tabItem { Label("المسلسلات", systemImage: "tv.fill") }
                .tag(2)

            LibraryView()
                .tabItem { Label("المكتبة", systemImage: "rectangle.stack.fill") }
                .tag(3)

            SearchView(apiService: apiService)
                .tabItem { Label("بحث", systemImage: "magnifyingglass") }
                .tag(4)
        }
        .accentColor(.cyan)
        .preferredColorScheme(.dark)
        .onAppear {
            apiService.fetchAllData()
        }
    }
}

// MARK: - الصفحة الرئيسية
struct HomeView: View {
    @ObservedObject var apiService: APIService
    @State private var showDeveloperInfo = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "tv.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)

                            Spacer()

                            Text("Tvclass")
                                .font(.title3).bold()
                                .foregroundColor(.white)

                            Spacer()

                            Menu {
                                Button(action: { showDeveloperInfo.toggle() }) {
                                    Label("معلومات المطور", systemImage: "person.circle.fill")
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(25)
                        .padding(.horizontal)

                        if let featured = apiService.featuredMovies.first {
                            ZStack(alignment: .bottom) {
                                AsyncImage(url: featured.backdropURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(height: 380)
                                .clipped()
                                .overlay(
                                    LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                                )

                                VStack(spacing: 8) {
                                    Text(featured.displayTitle)
                                        .font(.title).bold()
                                        .foregroundColor(.white)

                                    HStack(spacing: 12) {
                                        Text("Drama • 2026")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill").foregroundColor(.yellow)
                                            Text(String(format: "%.1f", featured.voteAverage ?? 0.0))
                                                .font(.caption).bold()
                                        }
                                    }

                                    HStack(spacing: 15) {
                                        Button(action: {}) {
                                            Image(systemName: "info.circle")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(10)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Circle())
                                        }

                                        Button(action: {}) {
                                            HStack {
                                                Image(systemName: "play.fill")
                                                Text("تشغيل").bold()
                                            }
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 10)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                        }

                                        Button(action: {}) {
                                            Image(systemName: "plus")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(10)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(.top, 5)
                                }
                                .padding(.bottom, 20)
                            }
                        }

                        MediaSectionRow(title: "Trending Movies", items: apiService.trendingMovies)
                        MediaSectionRow(title: "Trending TV Shows", items: apiService.trendingSeries)
                    }
                }
            }
            .sheet(isPresented: $showDeveloperInfo) {
                DeveloperInfoView()
            }
        }
    }
}

// MARK: - شبكة عرض الأفلام والمسلسلات (MediaGridView)
struct MediaGridView: View {
    let items: [MediaItem]
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(destination: MovieDetailView(item: item)) {
                            VStack(alignment: .leading, spacing: 6) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(height: 160)
                                .cornerRadius(10)

                                Text(item.displayTitle)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct MediaSectionRow: View {
    let title: String
    let items: [MediaItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(title)
                    .font(.headline).bold()
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { item in
                        NavigationLink(destination: MovieDetailView(item: item)) {
                            VStack(alignment: .leading) {
                                AsyncImage(url: item.posterURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 120, height: 170)
                                .cornerRadius(12)

                                Text(item.displayTitle)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: 120, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MoviesView: View {
    @ObservedObject var apiService: APIService
    var body: some View {
        NavigationStack {
            MediaGridView(items: apiService.trendingMovies)
                .navigationTitle("الأفلام")
        }
    }
}

struct SeriesView: View {
    @ObservedObject var apiService: APIService
    var body: some View {
        NavigationStack {
            MediaGridView(items: apiService.trendingSeries)
                .navigationTitle("المسلسلات")
        }
    }
}

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                Text("المكتبة والمفضلة فارغة حالياً")
                    .foregroundColor(.gray)
            }
            .navigationTitle("المكتبة")
        }
    }
}

struct SearchView: View {
    @ObservedObject var apiService: APIService
    @State private var query = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    TextField("ابحث عن فيلم أو مسلسل...", text: $query)
                        .onChange(of: query) { newValue in
                            apiService.search(query: newValue)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .padding()

                    MediaGridView(items: apiService.searchResults)
                }
            }
            .navigationTitle("البحث")
        }
    }
}
