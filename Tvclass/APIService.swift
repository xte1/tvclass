import Foundation

class APIService: ObservableObject {
    @Published var movies: [MediaItem] = []
    @Published var series: [MediaItem] = []
    @Published var searchResults: [MediaItem] = []

    private let apiKey = "YOUR_TMDB_API_KEY"
    private let baseURL = "https://api.themoviedb.org/3"

    func fetchTrendingMovies() {
        guard let url = URL(string: "\(baseURL)/trending/movie/week?api_key=\(apiKey)&language=ar-SA") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let response = try? JSONDecoder().decode(MediaResponse.self, from: data) {
                DispatchQueue.main.async { self.movies = response.results }
            }
        }.resume()
    }

    func fetchTrendingSeries() {
        guard let url = URL(string: "\(baseURL)/trending/tv/week?api_key=\(apiKey)&language=ar-SA") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let response = try? JSONDecoder().decode(MediaResponse.self, from: data) {
                DispatchQueue.main.async { self.series = response.results }
            }
        }.resume()
    }

    func search(query: String) {
        guard !query.isEmpty, let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search/multi?api_key=\(apiKey)&query=\(encoded)&language=ar-SA") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let response = try? JSONDecoder().decode(MediaResponse.self, from: data) {
                DispatchQueue.main.async { self.searchResults = response.results }
            }
        }.resume()
    }
}
