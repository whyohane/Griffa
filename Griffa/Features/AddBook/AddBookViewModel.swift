//
//  AddBookViewModel.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//
import Foundation

final class AddBookViewModel {

    enum State {
        case idle                   // campo vazio: nada para mostrar
        case loading                // primeira busca em andamento
        case loaded([Book])         // resultados
        case empty                  // buscou e não achou nada
        case failed(String)         // erro, com a mensagem para o usuário
    }

    var onStateChange: ((State) -> Void)?

    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }

    private let service: BooksService
    private let store: BooksStore
    private let debounce: Duration
    private var searchTask: Task<Void, Never>?

    init(service: BooksService, store: BooksStore, debounce: Duration = .milliseconds(400)) {
        self.service = service
        self.store = store
        self.debounce = debounce
    }

    func detailViewModel(for book: Book) -> BookDetailViewModel {
        BookDetailViewModel(book: book, store: store)
    }

    func search(_ text: String) {
        searchTask?.cancel()

        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            state = .idle
            return
        }

        // Se já há resultados (ou o "loading") na tela, eles ficam até chegarem os novos
        switch state {
        case .loaded, .loading: break
        default: state = .loading
        }

        searchTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }

            do {
                let books = try await service.searchBooks(matching: query)
                // Uma busca mais nova pode ter cancelado esta enquanto a resposta vinha
                guard !Task.isCancelled else { return }
                state = books.isEmpty ? .empty : .loaded(books)
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(error.localizedDescription)
            }
        }
    }
}
