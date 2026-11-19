//
//  QuotesViewModel.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import Foundation

final class QuotesViewModel {

    /// Chamado sempre que a lista muda (recarga ou busca).
    var onChange: (() -> Void)?

    private(set) var cards: [QuoteCardContent] = []

    private let store: QuotesStore
    private var allCards: [QuoteCardContent] = []
    private var query = ""
    private nonisolated(unsafe) var changesObserver: NSObjectProtocol?

    init(store: QuotesStore) {
        self.store = store

        // Recarrega quando uma quote é salva. O observador é registrado já aqui, de forma síncrona
        changesObserver = NotificationCenter.default.addObserver(
            forName: .quotesDidChange,
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

    /// Mensagem para quando não há nada a mostrar.
    var emptyText: String? {
        guard cards.isEmpty else { return nil }
        return allCards.isEmpty ? "No quotes yet.\nTap + to save your first quote." : "No quotes found."
    }

    func reload() {
        let quotes = (try? store.allQuotes()) ?? []
        allCards = quotes.map(makeCard(for:))
        applyQuery()
    }

    func search(_ text: String) {
        query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        applyQuery()
    }

    private func applyQuery() {
        cards = query.isEmpty ? allCards : allCards.filter(matchesQuery)
        onChange?()
    }

    // Busca no texto da quote, no título do livro e no autor
    private func matchesQuery(_ card: QuoteCardContent) -> Bool {
        [card.quote, card.bookTitle, card.author].contains { $0.localizedStandardContains(query) }
    }

    private func makeCard(for quote: Quote) -> QuoteCardContent {
        QuoteCardContent(
            quote: quote,
            title: quote.date.formatted(
                .dateTime
                    .weekday(.wide)
                    .month(.wide)
                    .day()
                    .locale(Locale(identifier: "en_US"))
            )
        )
    }
}
