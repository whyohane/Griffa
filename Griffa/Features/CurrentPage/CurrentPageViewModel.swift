//
//  CurrentPageViewModel.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 18/11/26.
//

import Foundation

final class CurrentPageViewModel {

    /// Os atalhos de "+N páginas" mostrados na tela.
    static let quickSteps = [5, 10, 20, 50]

    /// Chamado quando a página muda (para a tela atualizar barra, textos e botão de salvar).
    var onChange: (() -> Void)?

    let title: String
    let author: String
    let coverURL: URL?
    let coverData: Data?

    private(set) var page: Int

    private let initialPage: Int
    private let totalPages: Int
    private let book: Book
    private let store: BooksStore

    init(book: Book, store: BooksStore) {
        self.book = book
        self.store = store
        self.title = book.title
        self.author = book.author
        self.coverURL = book.coverURL
        self.coverData = book.coverData
        self.totalPages = book.numberOfPages
        self.initialPage = book.currentPage
        self.page = min(max(book.currentPage, 0), book.numberOfPages > 0 ? book.numberOfPages : Self.unknownTotalLimit)
    }

    // MARK: - Estado para a tela

    /// Livros sem total de páginas não têm limite superior conhecido.
    private static let unknownTotalLimit = 99_999

    var progress: Float {
        totalPages > 0 ? Float(page) / Float(totalPages) : 0
    }

    var percentText: String {
        guard totalPages > 0 else { return "" }
        return "\(Int((progress * 100).rounded()))% completed"
    }

    var pagesText: String {
        totalPages > 0 ? "p. \(page) of \(totalPages)" : "p. \(page)"
    }

    var canSave: Bool {
        page != initialPage
    }

    // MARK: - Entradas da tela

    /// Soma (ou subtrai, se negativo) páginas. A página fica entre 0 e o total do livro.
    func add(_ delta: Int) {
        setPage(page + delta)
    }

    func setPage(_ value: Int) {
        let upperLimit = totalPages > 0 ? totalPages : Self.unknownTotalLimit
        page = min(max(value, 0), upperLimit)
        onChange?()
    }

    func save() throws {
        try store.setCurrentPage(page, for: book)
    }
}
