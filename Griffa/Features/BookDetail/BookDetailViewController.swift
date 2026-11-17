//
//  BookDetailViewController.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//
import UIKit

final class BookDetailViewController: UIViewController {

    var onAdded: (() -> Void)?

    private let detailView = BookDetailView()
    private let viewModel: BookDetailViewModel

    init(viewModel: BookDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Book details"
        detailView.show(
            coverURL: viewModel.coverURL,
            info: viewModel.infoRows.map { BookInfoItem(label: $0.label, value: $0.value) },
            statusTitles: viewModel.statuses.map(\.title),
            selectedStatus: viewModel.selectedStatusIndex
        )
        bindView()
    }

    private func bindView() {
        detailView.onStatusChange = { [weak self] index in
            self?.viewModel.selectStatus(at: index)
        }
        detailView.onAddTapped = { [weak self] in
            self?.addBook()
        }
    }

    private func addBook() {
        detailView.setAdding(true)

        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.add()
                onAdded?()
            } catch {
                detailView.setAdding(false)
                showError(error)
            }
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Couldn't add the book",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
