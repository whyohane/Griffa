//
//  SummaryViewModel.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//
import Foundation

final class SummaryViewModel {

    private let store: UserProfileStore
    private let booksStore: BooksStore

    init(store: UserProfileStore, booksStore: BooksStore) {
        self.store = store
        self.booksStore = booksStore
    }

    var greeting: String {
        guard let name = store.profile?.name else { return "Hello!" }
        return "Hello, \(name)!"
    }

    var dateText: String {
        Date.now.formatted(
            .dateTime
                .weekday(.wide)
                .month(.wide)
                .day()
                .locale(Locale(identifier: "en_US"))
        )
        .uppercased()
    }

    func readingBooks() -> [ReadingBookContent] {
        let books = (try? booksStore.allBooks()) ?? []
        return books
            .filter { $0.status == .reading }
            .map {
                ReadingBookContent(
                    id: $0.id,
                    title: $0.title,
                    author: $0.author,
                    currentPage: $0.currentPage,
                    pages: $0.numberOfPages,
                    coverURL: $0.coverURL
                )
            }
    }
}
