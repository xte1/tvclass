import SwiftUI

struct ContentView: View {
    @StateObject private var apiService = APIService()
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var favorites: [MediaItem] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    HStack {
                        Image(systemName: "tv.fill")
                            .resizable()
                            .frame(width: 30, height: 25)
                            .foregroundColor(.cyan)

                        Spacer()

                        Text("Tvclass")
                            .font(.title2).bold()

                        Spacer()

                        Menu {
                            NavigationLink(destination: DeveloperInfoView()) {
                                Label("معلومات المطور", systemImage: "person.info.fill")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .liquidGlass()
                    .padding(.horizontal)

                    TextField("ابحث عن فيلم أو مسلسل...", text: $searchText)
                        .onChange(of: searchText) { newValue in
                            apiService.search(query: newValue)
                        }
                        .padding()
                        .liquidGlass()
                        .padding(.horizontal)

                    TabView(selection: $selectedTab) {
                        MediaGridView(items: searchText.isEmpty ? apiService.movies : apiService.searchResults)
                            .tabItem { Label("أفلام", systemImage: "film") }
                            .tag(0)

                        MediaGridView(items: apiService.series)
                            .tabItem { Label("مسلسلات", systemImage: "tv") }
                            .tag(1)

                        MediaGridView(items: favorites)
                            .tabItem { Label("المفضلة", systemImage: "heart.fill") }
                            .tag(2)
                    }
                }
            }
        }
        .onAppear {
            apiService.fetchTrendingMovies()
            apiService.fetchTrendingSeries()
        }
    }
}

struct MediaGridView: View {
    let items: [MediaItem]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(items) { item in
                    NavigationLink(destination: MovieDetailView(item: item)) {
                        VStack {
                            AsyncImage(url: item.posterURL) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(height: 200)
                            .cornerRadius(12)

                            Text(item.displayTitle)
                                .font(.caption).bold()
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(8)
                        .liquidGlass()
                    }
                }
            }
            .padding()
        }
    }
}
