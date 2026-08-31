import Foundation
import Combine

class APIService: ObservableObject {
    @Published var featuredMovies: [MediaItem] = []
    @Published var trendingMovies: [MediaItem] = []
    @Published var trendingSeries: [MediaItem] = []
    
    // مفتاح API الخاص بـ TMDB أو الرابط الافتراضي لجلب البيانات
    private let apiKey = "c935334336f322304892c90bcbc94fb4" // يمكنك وضع مفتاحك هنا
    
    func fetchAllData() {
        fetchData(from: "https://api.themoviedb.org/3/trending/all/day?api_key=\(apiKey)&language=ar-AR") { [weak self] items in
            DispatchQueue.main.async {
                self?.featuredMovies = Array(items.prefix(3))
                self?.trendingMovies = items.filter { $0.mediaType == "movie" || $0.title != nil }
                self?.trendingSeries = items.filter { $0.mediaType == "tv" || $0.name != nil }
            }
        }
    }
    
    private func fetchData(from urlString: String, completion: @escaping ([MediaItem]) -> Void) {
        guard let url = URL(string: urlurlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                // بيانات افتراضية تجريبية في حال عدم توفر إنترنت أو مفتاح API لضمان عدم ظهور الشاشة فارغة
                completion(self.getMockData())
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(MediaResponse.self, from: data)
                completion(decoded.results)
            } catch {
                completion(self.getMockData())
            }
        }.resume()
    }
    
    // بيانات احتياطية لضمان عمل الواجهة والبحث فوراً
    private func getMockData() -> [MediaItem] {
        return [
            MediaItem(id: 1, title: "الإنقاذ الأخير", name: nil, overview: "فيلم إثارة وحركة مشوق للغاية بدقة 4K.", posterPath: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg", backdropPath: "/zfbjgQE1uSd9wiPTX4VzsLi0rGG.jpg", voteAverage: 8.5, mediaType: "movie"),
            MediaItem(id: 2, title: nil, name: "مملكة الصمت", overview: "مسلسل درامي غموض وحصري على المنصة.", posterPath: "/rktDFPbfHfUbArZ6OOOKsXcv0Bm.jpg", backdropPath: "/suopoADq0k8YZr4dQXcU6pToj6s.jpg", voteAverage: 9.1, mediaType: "tv"),
            MediaItem(id: 3, title: "رحلة الفضاء", name: nil, overview: "مغامرة علمية خيالية في أعماق الفضاء.", posterPath: "/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg", backdropPath: "/62HCnUTziyWcpDaBO2i1DX17ljH.jpg", voteAverage: 7.9, mediaType: "movie"),
            MediaItem(id: 4, title: nil, name: "الظل الخفي", overview: "تحقيقات بوليسية مثيرة في مدينة مظلمة.", posterPath: "/plyggGICaOhpPjGBwG6R7i3mZ0q.jpg", backdropPath: "/9yBVqNruk6Ykrwc32qrK2TUI5xw.jpg", voteAverage: 8.2, mediaType: "tv")
        ]
    }
}
