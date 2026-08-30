import Foundation

struct MediaItem: Identifiable, Codable {
    let id: Int
    let title: String?
    let name: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?

    enum CodingKeys: String, CodingKey {
        case id, title, name, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
    }

    var displayTitle: String { title ?? name ?? "بدون عنوان" }
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}

struct MediaResponse: Codable {
    let results: [MediaItem]
}

struct Episode: Identifiable {
    let id: Int
    let title: String
    let episodeNumber: Int
    let videoURL: URL
}
