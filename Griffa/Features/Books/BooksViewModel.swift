//
//  BooksViewModel.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import Foundation

final class BooksViewModel {

    struct Shelf {
        let status: ReadingStatus
        let cards: [BookCardContent]
    }

    var onChange: (() -> Void)?

    let filterTitles = ["All"] + ReadingStatus.allCases.map(\.title)

    private(set) var selectedFilterIndex = 0
    private(set) var shelves: [Shelf] = []

    private let store: BooksStore
    private var books: [Book] = []
    private nonisolated(unsafe) var changesObserver: NSObjectProtocol?

    init(store: BooksStore) {
        self.store = store

        // Recarrega quando a biblioteca muda (ex.: um livro foi adicionado na sheet).
        // O observador é registrado já aqui, de forma síncrona: nenhuma notificação se perde.
        changesObserver = NotificationCenter.default.addObserver(
            forName: .booksDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.reload() }
        }
    }

    deinit {
        if let changesObserver {
            NotificationCenter.default.removeObserver(changesObserver)
        }
    }

    var emptyText: String? {
        guard shelves.isEmpty else { return nil }
        return books.isEmpty ? "No books yet.\nTap + to add your first book." : "No books here yet."
    }

    func reload() {
        books = (try? store.allBooks()) ?? []
        rebuildShelves()
    }

    func selectFilter(at index: Int) {
        guard filterTitles.indices.contains(index) else { return }
        selectedFilterIndex = index
        rebuildShelves()
    }

    private func rebuildShelves() {
        let statuses: [ReadingStatus] = selectedFilterIndex == 0
            ? ReadingStatus.allCases
            : [ReadingStatus.allCases[selectedFilterIndex - 1]]

        shelves = statuses.compactMap { status in
            let cards = books.filter { $0.status == status }.map(makeCard(for:))
            return cards.isEmpty ? nil : Shelf(status: status, cards: cards)
        }
        onChange?()
    }

    private func makeCard(for book: Book) -> BookCardContent {
        let pages = book.numberOfPages
        // Livro "Finished" conta como lido por inteiro
        let page = book.status == .read ? pages : min(book.currentPage, pages)
        let percent = pages > 0 ? Int((Double(page) / Double(pages) * 100).rounded()) : 0

        return BookCardContent(
            id: book.id,
            title: book.title,
            author: book.author,
            progressText: pages > 0 ? "\(percent)% completed" : "Pages unknown",
            pagesText: pages > 0 ? "p. \(page) of \(pages)" : nil,
            coverURL: book.coverURL,
            coverData: book.coverData
        )
    }
}
