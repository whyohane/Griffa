//
//  SummaryViewController.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//
import UIKit

final class SummaryViewController: UIViewController {

    private let summaryView = SummaryView()
    private let viewModel: SummaryViewModel

    init(viewModel: SummaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    override func loadView() {
        view = summaryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Summary"
        summaryView.setDate(viewModel.dateText)
        summaryView.setGreeting(viewModel.greeting)
        setupGriffaNavigationBar()      // a Summary não tem o botão "+"
    }

    // Recarrega a cada aparição: o usuário pode ter adicionado um livro na aba Books
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        summaryView.showReadingBooks(viewModel.readingBooks())
    }
}

