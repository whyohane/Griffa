//
//  GoogleBooksService.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import Foundation

final class GoogleBooksService: BooksService {

    private static let endpoint = "https://www.googleapis.com/books/v1/volumes"

    private let session: URLSession
    private let apiKey: String?
    private let bundleIdentifier: String?

    init(
        session: URLSession = .shared,
        apiKey: String? = APIConfig.googleBooksAPIKey,
        bundleIdentifier: String? = Bundle.main.bundleIdentifier
    ) {
        self.session = session
        self.apiKey = apiKey
        self.bundleIdentifier = bundleIdentifier
    }

    func searchBooks(matching query: String) async throws -> [Book] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }
        guard let apiKey else { throw BooksServiceError.missingAPIKey }

        // URLComponents faz o encoding de espaços e acentos
        var components = URLComponents(string: Self.endpoint)
        components?.queryItems = [
            URLQueryItem(name: "q", value: trimmedQuery),
            URLQueryItem(name: "printType", value: "books"),
            URLQueryItem(name: "maxResults", value: "5"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        guard let url = components?.url else { throw BooksServiceError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue(bundleIdentifier, forHTTPHeaderField: "X-Ios-Bundle-Identifier")

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse {
            switch http.statusCode {
            case 200...299: break
            case 429: throw BooksServiceError.rateLimited
            default: throw BooksServiceError.badStatus(http.statusCode)
            }
        }

        return try Self.books(from: data)
    }

    static func books(from data: Data) throws -> [Book] {
        let decoded = try JSONDecoder().decode(VolumesResponse.self, from: data)
        return (decoded.items ?? []).map { Book(volume: $0) }
    }
}

private struct VolumesResponse: Decodable {
    let items: [Volume]?
}

private struct Volume: Decodable {
    let id: String?
    let volumeInfo: VolumeInfo
}

private struct VolumeInfo: Decodable {
    let title: String?
    let authors: [String]?
    let pageCount: Int?
    let imageLinks: ImageLinks?
}

private struct ImageLinks: Decodable {
    let thumbnail: String?
}

private extension Book {

    convenience init(volume: Volume) {
        let volumeInfo = volume.volumeInfo
        self.init(
            googleID: volume.id,
            title: volumeInfo.title ?? "Untitled",
            author: volumeInfo.authors?.joined(separator: ", ") ?? "Unknown author",
            numberOfPages: volumeInfo.pageCount ?? 0,
            coverURL: Book.coverURL(from: volumeInfo.imageLinks?.thumbnail),
            quotes: []
        )
    }

    static func coverURL(from link: String?) -> URL? {
        guard let link,
              var components = URLComponents(string: link.replacingOccurrences(of: "http://", with: "https://")) else {
            return nil
        }

        components.queryItems = components.queryItems?.compactMap { item in
            switch item.name {
            case "zoom": URLQueryItem(name: "zoom", value: "3")
            case "edge": nil
            default: item
            }
        }
        return components.url
    }
}
