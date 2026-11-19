//
//  QuotesViewController.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//
import UIKit
import SwiftData

final class QuotesViewController: UIViewController {

    private let quotesView = QuotesView()
    private let viewModel: QuotesViewModel
    private let booksStore: BooksStore
    private let quotesStore: QuotesStore

    init(viewModel: QuotesViewModel, booksStore: BooksStore, quotesStore: QuotesStore) {
        self.viewModel = viewModel
        self.booksStore = booksStore
        self.quotesStore = quotesStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    override func loadView() {
        view = quotesView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quotes"
        setupGriffaNavigationBar { [weak self] in
            self?.presentAddModal()
        }
        bindView()
    }

    // Recarrega a cada aparição: as quotes podem ter mudado em outra tela
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    // MARK: - View ↔ ViewModel

    private func bindView() {
        quotesView.onQueryChange = { [weak self] text in
            self?.viewModel.search(text)
        }
        viewModel.onChange = { [weak self] in
            guard let self else { return }
            quotesView.show(quotes: viewModel.cards, emptyText: viewModel.emptyText)
        }
    }

    private func presentAddModal() {
        let viewModel = AddQuoteViewModel(booksStore: booksStore, quotesStore: quotesStore)
        let controller = AddQuoteViewController(viewModel: viewModel)
        let navigation = UINavigationController(rootViewController: controller)
        navigation.sheetPresentationController?.detents = [.large()]
        present(navigation, animated: true)
    }
}

#Preview {
    // Banco em memória com algumas quotes de exemplo
    let container = try! ModelContainer(
        for: Book.self, Quote.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let book = Book(title: "Alice's Adventures in Wonderland", author: "Lewis Carroll", numberOfPages: 200)
    container.mainContext.insert(book)
    for day in 0..<3 {
        container.mainContext.insert(Quote(
            textQuote: "I knew who I was when I got up this morning, but I think I must have been changed several times since then.",
            book: book,
            page: 56,
            date: Date.now.addingTimeInterval(Double(-day) * 86_400)
        ))
    }
    let quotesStore = SwiftDataQuotesStore(container: container)
    let viewModel = QuotesViewModel(store: quotesStore)
    return UINavigationController(rootViewController: QuotesViewController(
        viewModel: viewModel,
        booksStore: SwiftDataBooksStore(container: container),
        quotesStore: quotesStore
    ))
}
