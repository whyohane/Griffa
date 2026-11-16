//
//  BooksViewController.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//
import UIKit

final class BooksViewController: UIViewController {

    private let summaryView = BooksView()
    private let viewModel: BooksViewModel

    init(viewModel: BooksViewModel = BooksViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }


    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Books"
        view.backgroundColor = .systemBackground
        setupGriffaNavigationBar { [weak self] in
            self?.presentAddModal()
        }
    }

    private func presentAddModal() {
        let modal = UIViewController()
        modal.view.backgroundColor = .systemBackground
        modal.sheetPresentationController?.detents = [.medium(), .large()]
        present(modal, animated: true)
    }
    
}
