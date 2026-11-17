//
//  AddBookViewController.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//
import UIKit

final class AddBookViewController: UIViewController {
    
    private let addBookView = AddBookView()
    private let viewModel: AddBookViewModel

    init(viewModel: AddBookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    override func loadView() {
        view = addBookView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add book"
        setupNavigationBar()
        bindView()
    }

    private func bindView() {
        addBookView.onQueryChange = { [weak self] text in
            self?.viewModel.search(text)
        }
        addBookView.onSelectBook = { [weak self] book in
            self?.didSelect(book)
        }
        addBookView.onAddManually = {
            // Mock: vai abrir a sheet com o formulário manual
        }
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: AddBookViewModel.State) {
        switch state {
        case .idle:
            addBookView.showContent(.hidden)
        case .loading:
            addBookView.showContent(.loading)
        case .loaded(let books):
            addBookView.showContent(.books(books))
        case .empty:
            addBookView.showContent(.message("No books found. Try another title or author."))
        case .failed(let message):
            addBookView.showContent(.message(message))
        }
    }

    private func didSelect(_ book: Book) {
        let detail = BookDetailViewController(viewModel: viewModel.detailViewModel(for: book))
        // Livro adicionado: fecha a sheet inteira
        detail.onAdded = { [weak self] in
            self?.dismiss(animated: true)
        }
        navigationController?.pushViewController(detail, animated: true)
    }

    private func setupNavigationBar() {
  
        navigationController?.navigationBar.tintColor = UIColor(resource: .primaryPurple)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )

        // O botão de voltar da tela seguinte (detalhes) mostra "‹ Search"
        navigationItem.backButtonTitle = "Search"
    }
}
