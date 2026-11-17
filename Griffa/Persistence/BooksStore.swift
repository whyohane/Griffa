//
//  BooksStore.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import Foundation

/// Biblioteca do usuário. As telas e ViewModels conhecem só este protocolo, não o SwiftData.
protocol BooksStore {
    /// Adiciona o livro à biblioteca, na estante indicada e com a capa já baixada (se houver).
    func add(_ book: Book, status: ReadingStatus, coverData: Data?) throws

    func allBooks() throws -> [Book]
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
