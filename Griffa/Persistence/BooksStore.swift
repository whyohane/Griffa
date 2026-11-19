//
//  BooksStore.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import Foundation

protocol BooksStore {

    func add(_ book: Book, status: ReadingStatus, coverData: Data?) throws

    func allBooks() throws -> [Book]

    func setCurrentPage(_ page: Int, for book: Book) throws
}

extension Notification.Name {

    static let booksDidChange = Notification.Name("booksDidChange")
}

enum BooksStoreError: LocalizedError {
    case alreadyAdded

    var errorDescription: String? {
        switch self {
        case .alreadyAdded:
            return "This book is already in your library."
        }
    }
}
