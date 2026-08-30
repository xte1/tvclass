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
        .environment(\.layoutDirection, .rightToLeft) // اتجاه الواجهة من اليمين لليسار
        .onAppear {
            apiService.fetchAllData()
        }
    }
}
