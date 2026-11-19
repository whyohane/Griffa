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
    private let quotesStore: QuotesStore
    private let quoteOfTheDayStore: QuoteOfTheDayStore

    /// Chamado quando a biblioteca muda (ex.: a página de um livro foi atualizada).
    var onBooksChange: (() -> Void)?

    private nonisolated(unsafe) var changesObserver: NSObjectProtocol?

    init(
        store: UserProfileStore,
        booksStore: BooksStore,
        quotesStore: QuotesStore,
        quoteOfTheDayStore: QuoteOfTheDayStore
    ) {
        self.store = store
        self.booksStore = booksStore
        self.quotesStore = quotesStore
        self.quoteOfTheDayStore = quoteOfTheDayStore

        // Observador registrado já aqui, de forma síncrona: nenhuma notificação se perde
        changesObserver = NotificationCenter.default.addObserver(
            forName: .booksDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.onBooksChange?() }
        }
    }

    deinit {
        if let changesObserver {
            NotificationCenter.default.removeObserver(changesObserver)
        }
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

    /// A quote do dia: uma por dia, sorteada entre as quotes salvas e a mesma até virar o dia.
    /// Sem nenhuma quote salva, devolve `nil`.
    func quoteOfTheDay(now: Date = .now) -> QuoteCardContent? {
        let quotes = (try? quotesStore.allQuotes()) ?? []
        guard !quotes.isEmpty else { return nil }

        let saved = quoteOfTheDayStore.current

        // Já sorteada hoje (e a quote ainda existe): reaproveita
        if let saved,
           Calendar.current.isDate(saved.date, inSameDayAs: now),
           let quote = quotes.first(where: { $0.id == saved.quoteID }) {
            return QuoteCardContent(quote: quote, title: "Quote of the day")
        }

        // Dia novo: sorteia evitando repetir a última (se houver outra para escolher)
        let candidates = quotes.count > 1 ? quotes.filter { $0.id != saved?.quoteID } : quotes
        guard let quote = candidates.randomElement() else { return nil }

        quoteOfTheDayStore.save(QuoteOfTheDay(date: now, quoteID: quote.id))
        return QuoteCardContent(quote: quote, title: "Quote of the day")
    }

    /// ViewModel da sheet "Current page" do livro tocado em "Reading now".
    func currentPageViewModel(for bookID: UUID) -> CurrentPageViewModel? {
        let books = (try? booksStore.allBooks()) ?? []
        guard let book = books.first(where: { $0.id == bookID }) else { return nil }
        return CurrentPageViewModel(book: book, store: booksStore)
    }
}
