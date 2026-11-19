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
        bindView()
    }

    private func bindView() {
        summaryView.onSelectBook = { [weak self] id in
            self?.presentCurrentPage(for: id)
        }
        // Página atualizada na sheet: a lista de "Reading now" se atualiza sozinha
        viewModel.onBooksChange = { [weak self] in
            guard let self else { return }
            summaryView.showReadingBooks(viewModel.readingBooks())
        }
    }

    private func presentCurrentPage(for bookID: UUID) {
        guard let currentPageViewModel = viewModel.currentPageViewModel(for: bookID) else { return }
        let controller = CurrentPageViewController(viewModel: currentPageViewModel)
        let navigation = UINavigationController(rootViewController: controller)
        if let sheet = navigation.sheetPresentationController {
            // Sheet pequena: só a altura do conteúdo
            sheet.detents = [.custom { _ in 500 }]
            sheet.prefersGrabberVisible = true
        }
        present(navigation, animated: true)
    }

    // Recarrega a cada aparição: o usuário pode ter adicionado um livro na aba Books
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        summaryView.showReadingBooks(viewModel.readingBooks())
        // Estável durante o dia: só muda quando vira o dia
        summaryView.showQuoteOfTheDay(viewModel.quoteOfTheDay())
    }
}

