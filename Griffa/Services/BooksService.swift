//
//  BooksService.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import Foundation

protocol BooksService {
    func searchBooks(matching query: String) async throws -> [Book]
}

enum BooksServiceError: LocalizedError {
    case invalidURL
    case missingAPIKey
    case rateLimited
    case badStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not build the search URL."
        case .missingAPIKey:
            return "Google Books API key is missing. Set GOOGLE_BOOKS_API_KEY in Config/Secrets.xcconfig."
        case .rateLimited:
            return "Search is unavailable right now. Try again later."
        case .badStatus(let code):
            return "The books service answered with status \(code)."
        }
    }
}
