import Foundation

// نموذج الحلقات
struct Episode: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let episodeNumber: Int
    let videoURL: URL
}

// نموذج الأفلام والمسلسلات الرئيسي
struct MediaItem: Identifiable, Codable, Equatable {
    let id: Int
    let title: String?
    let name: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let mediaType: String?

    enum CodingKeys: String, CodingKey {
        case id, title, name, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case mediaType = "media_type"
    }

    var displayTitle: String { title ?? name ?? "بدون عنوان" }

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w1280\(path)")
    }
}

struct MediaResponse: Codable {
    let results: [MediaItem]
}
