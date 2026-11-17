//
//  BooksViewController.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//
import UIKit

final class BooksViewController: UIViewController {

    private let booksView = BooksView()
    private let viewModel: BooksViewModel
    private let booksService: BooksService
    private let booksStore: BooksStore

    init(viewModel: BooksViewModel, booksService: BooksService, booksStore: BooksStore) {
        self.viewModel = viewModel
        self.booksService = booksService
        self.booksStore = booksStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    override func loadView() {
        view = booksView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Books"
        setupGriffaNavigationBar { [weak self] in
            self?.presentAddBookModal()
        }
        bindView()
        viewModel.reload()
    }

    private func bindView() {
        booksView.setFilters(titles: viewModel.filterTitles, selected: viewModel.selectedFilterIndex)
        booksView.onFilterChange = { [weak self] index in
            self?.viewModel.selectFilter(at: index)
        }
        viewModel.onChange = { [weak self] in
            self?.render()
        }
    }

    private func render() {
        let shelves = viewModel.shelves.map {
            BookShelf(id: $0.status.rawValue, title: $0.status.title.uppercased(), cards: $0.cards)
        }
        booksView.show(shelves: shelves, emptyText: viewModel.emptyText)
    }

    private func presentAddBookModal() {
        let viewModel = AddBookViewModel(service: booksService, store: booksStore)
        let controller = AddBookViewController(viewModel: viewModel)
        let navigation = UINavigationController(rootViewController: controller)
        navigation.sheetPresentationController?.detents = [.large()]
        present(navigation, animated: true)
    }
}

#Preview {
    let store = SwiftDataBooksStore.inMemory()
    return UINavigationController(
        rootViewController: BooksViewController(
            viewModel: BooksViewModel(store: store),
            booksService: GoogleBooksService(),
            booksStore: store
        )
    )
}
