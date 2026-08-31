import Foundation
import Combine

class APIService: ObservableObject {
    @Published var featuredMovies: [MediaItem] = []
    @Published var trendingMovies: [MediaItem] = []
    @Published var trendingSeries: [MediaItem] = []
    @Published var searchResults: [MediaItem] = []
    @Published var isLoading = false
    
    private let apiKey = "c935334336f322304892c90bcbc94fb4"
    
    func fetchAllData() {
        // جلب الأفلام الرائجة والشائعة بكثرة
        fetchMedia(from: "https://api.themoviedb.org/3/trending/movie/day?api_key=\(apiKey)&language=ar-AR") { [weak self] movies in
            DispatchQueue.main.async {
                self?.trendingMovies = movies
                if let first = movies.first {
                    self?.featuredMovies = [first]
                }
            }
        }
        
        // جلب المسلسلات الرائجة والشائعة بكثرة
        fetchMedia(from: "https://api.themoviedb.org/3/trending/tv/day?api_key=\(apiKey)&language=ar-AR") { [weak self] series in
            DispatchQueue.main.async {
                self?.trendingSeries = series
            }
        }
    }
    
    // محرك البحث الشامل لجلب أي فيلم أو مسلسل في قاعدة البيانات
    func searchMedia(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            DispatchQueue.main.async { self.searchResults = [] }
            return
        }
        
        let encodedQuery = trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.themoviedb.org/3/search/multi?api_key=\(apiKey)&language=ar-AR&query=\(encodedQuery)&page=1&include_adult=false"
        
        isLoading = true
        fetchMedia(from: urlString) { [weak self] items in
            DispatchQueue.main.async {
                self?.searchResults = items.filter { $0.mediaType == "movie" || $0.mediaType == "tv" || $0.title != nil || $0.name != nil }
                self?.isLoading = false
            }
        }
    }
    
    private func fetchMedia(from urlString: String, completion: @escaping ([MediaItem]) -> Void) {
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(MediaResponse.self, from: data)
                completion(decoded.results)
            } catch {
                completion([])
            }
        }.resume()
    }
}
