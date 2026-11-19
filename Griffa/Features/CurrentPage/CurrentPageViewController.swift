//
//  CurrentPageViewController.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 18/11/26.
//
import UIKit

final class CurrentPageViewController: UIViewController {

    private let currentPageView = CurrentPageView()
    private let viewModel: CurrentPageViewModel

    private let saveButton = UIBarButtonItem()

    init(viewModel: CurrentPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    override func loadView() {
        view = currentPageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Current page"
        setupNavigationBar()
        bindView()
        currentPageView.setBook(
            title: viewModel.title,
            author: viewModel.author,
            coverData: viewModel.coverData,
            coverURL: viewModel.coverURL
        )
        render()
    }

    // MARK: - Barra de navegação

    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = UIColor(resource: .primaryPurple)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
        navigationItem.leftBarButtonItem?.tintColor = .label

        saveButton.style = .prominent
        saveButton.tintColor = UIColor(resource: .primaryPurple)
        saveButton.primaryAction = UIAction(image: UIImage(systemName: "checkmark")) { [weak self] _ in
            self?.save()
        }
        navigationItem.rightBarButtonItem = saveButton
    }

    // MARK: - View ↔ ViewModel

    private func bindView() {
        currentPageView.onAdd = { [weak self] in self?.viewModel.add($0) }
        currentPageView.onPageTyped = { [weak self] in self?.viewModel.setPage($0) }
        viewModel.onChange = { [weak self] in
            self?.render()
        }
    }

    private func render() {
        currentPageView.setProgress(
            viewModel.progress,
            percentText: viewModel.percentText,
            pagesText: viewModel.pagesText,
            page: viewModel.page
        )
        saveButton.isEnabled = viewModel.canSave
    }

    private func save() {
        do {
            try viewModel.save()
            dismiss(animated: true)
        } catch {
            let alert = UIAlertController(title: "Couldn't save the page", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
