//
//  AddQuoteViewModel.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 18/11/26.
//

import Foundation

final class AddQuoteViewModel {

    static let maxQuoteLength = 500

    var onChange: (() -> Void)?

    let books: [Book]

    private(set) var selectedBookIndex: Int?

    private var quoteText = ""
    private var pageText = ""
    private var thoughts = ""

    private let quotesStore: QuotesStore

    init(booksStore: BooksStore, quotesStore: QuotesStore) {
        self.quotesStore = quotesStore
        self.books = ((try? booksStore.allBooks()) ?? []).filter { $0.status == .reading }
    }

    // MARK: - Estado para a tela

    var bookTitles: [String] { books.map(\.title) }

    var characterCountText: String {
        "\(quoteText.count)/\(Self.maxQuoteLength) characters"
    }

    /// A página é opcional; se preenchida, precisa ser um número positivo dentro do livro.
    var isPageValid: Bool {
        let trimmed = pageText.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return true }
        guard let page = Int(trimmed), page > 0 else { return false }
        guard let book = selectedBook, book.numberOfPages > 0 else { return true }
        return page <= book.numberOfPages
    }

    /// Precisa de texto (sem contar espaços), de um livro e de uma página válida.
    var canSave: Bool {
        !trimmedQuote.isEmpty && selectedBook != nil && isPageValid
    }

    // MARK: - Entradas da tela

    func setQuote(_ text: String) {
        quoteText = text
        onChange?()
    }

    func selectBook(at index: Int) {
        guard books.indices.contains(index) else { return }
        selectedBookIndex = index
        onChange?()
    }

    func setPage(_ text: String) {
        pageText = text
        onChange?()
    }

    func setThoughts(_ text: String) {
        thoughts = text
    }

    func save() throws {
        guard canSave, let book = selectedBook else { return }
        let trimmedThoughts = thoughts.trimmingCharacters(in: .whitespacesAndNewlines)
        let quote = Quote(
            textQuote: trimmedQuote,
            book: book,
            page: Int(pageText.trimmingCharacters(in: .whitespaces)),
            thoughts: trimmedThoughts.isEmpty ? nil : trimmedThoughts
        )
        try quotesStore.add(quote)
    }

    // MARK: - Auxiliares

    private var selectedBook: Book? {
        selectedBookIndex.map { books[$0] }
    }

    private var trimmedQuote: String {
        quoteText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
