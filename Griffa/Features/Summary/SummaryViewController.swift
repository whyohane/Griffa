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
        setupGriffaNavigationBar { [weak self] in
            self?.presentAddModal()
        }
    }

    private func presentAddModal() {
        let modal = UIViewController()
        modal.view.backgroundColor = UIColor(resource: .backgroundPurple)
        modal.sheetPresentationController?.detents = [.medium(), .large()]
        present(modal, animated: true)
    }
}

