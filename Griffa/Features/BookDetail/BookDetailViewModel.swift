//
//  BookDetailViewModel.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//
import Foundation

final class BookDetailViewModel {

    struct InfoRow {
        let label: String
        let value: String
    }

    let statuses = ReadingStatus.allCases
    private(set) var status: ReadingStatus = .wantToRead

    private let book: Book
    private let store: BooksStore
    private let coverLoader: CoverDataLoading

    init(book: Book, store: BooksStore, coverLoader: CoverDataLoading = ImageLoader.shared) {
        self.book = book
        self.store = store
        self.coverLoader = coverLoader
    }

    var coverURL: URL? { book.coverURL }

    var infoRows: [InfoRow] {
        [
            InfoRow(label: "Title", value: book.title),
            InfoRow(label: "Author", value: book.author),
            InfoRow(label: "Pages", value: book.numberOfPages > 0 ? "\(book.numberOfPages)" : "Unknown")
        ]
    }

    var selectedStatusIndex: Int {
        statuses.firstIndex(of: status) ?? 0
    }

    func selectStatus(at index: Int) {
        guard statuses.indices.contains(index) else { return }
        status = statuses[index]
    }

    func add() async throws {
        var coverData: Data?
        if let coverURL = book.coverURL {
            coverData = await coverLoader.coverData(for: coverURL)
        }
        try store.add(book, status: status, coverData: coverData)
    }
}
