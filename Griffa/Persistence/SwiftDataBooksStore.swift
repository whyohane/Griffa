//
//  SwiftDataBooksStore.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import Foundation
import SwiftData

final class SwiftDataBooksStore: BooksStore {

    // O store guarda o container: o contexto não o mantém vivo sozinho
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init(container: ModelContainer) {
        self.container = container
    }

    func add(_ book: Book, status: ReadingStatus, coverData: Data?) throws {
        if let googleID = book.googleID, try contains(googleID: googleID) {
            throw BooksStoreError.alreadyAdded
        }

        book.status = status
        book.coverData = coverData
        context.insert(book)
        try context.save()

        NotificationCenter.default.post(name: .booksDidChange, object: nil)
    }

    func allBooks() throws -> [Book] {
        let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.addedAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    private func contains(googleID: String) throws -> Bool {
        var descriptor = FetchDescriptor<Book>(predicate: #Predicate { $0.googleID == googleID })
        descriptor.fetchLimit = 1
        return try context.fetchCount(descriptor) > 0
    }
}

extension SwiftDataBooksStore {

    static func inMemory() -> SwiftDataBooksStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: Book.self, Quote.self, configurations: configuration)
            return SwiftDataBooksStore(container: container)
        } catch {
            fatalError("Não foi possível criar o armazenamento em memória: \(error)")
        }
    }
}
