import Foundation

class APIService: ObservableObject {
    @Published var featuredMovies: [MediaItem] = []
    @Published var trendingMovies: [MediaItem] = []
    @Published var trendingSeries: [MediaItem] = []
    @Published var searchResults: [MediaItem] = []

    // مفتاح الـ API الخاص بك من الصورة
    private let apiKey = "12bae60f08973cb30c741d0844769d9d"
    private let baseURL = "https://api.themoviedb.org/3"

    func fetchAllData() {
        fetchTrendingMovies()
        fetchTrendingSeries()
    }

    func fetchTrendingMovies() {
        guard let url = URL(string: "\(baseURL)/trending/movie/week?api_key=\(apiKey)&language=ar-SA") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let response = try? JSONDecoder().decode(MediaResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.trendingMovies = response.results
                    self.featuredMovies = Array(response.results.prefix(5))
                }
            }
        }.resume()
    }

    func fetchTrendingSeries() {
        guard let url = URL(string: "\(baseURL)/trending/tv/week?api_key=\(apiKey)&language=ar-SA") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let response = try? JSONDecoder().decode(MediaResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.trendingSeries = response.results
                }
            }
        }.resume()
    }

    func search(query: String) {
        guard !query.isEmpty, let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search/multi?api_key=\(apiKey)&query=\(encoded)&language=ar-SA") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let response = try? JSONDecoder().decode(MediaResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.searchResults = response.results
                }
            }
        }.resume()
    }
}
