//
//  AddBookView.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import UIKit

final class AddBookView: UIView {

    var onQueryChange: ((String) -> Void)?

    var onSelectBook: ((Book) -> Void)?

    var onAddManually: (() -> Void)?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let searchBookLabel: UILabel = {
        let searchBook = UILabel()
        searchBook.text = "Search by title or author".uppercased()
        searchBook.textColor = UIColor.label
        searchBook.font = Fonts.title2()
        searchBook.translatesAutoresizingMaskIntoConstraints = false

        return searchBook
    }()

    private let searchBarComponent = GriffaSearchField(placeholder: "Search")

    // Contagem + card. Fica escondido até o usuário começar a digitar ("expande").
    private let resultsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.isHidden = true
        stackView.alpha = 0
        return stackView
    }()

    private let resultsCountLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body()
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let resultsCard = BookResultsCard()

    private let divider = LabeledDivider(text: "Can't find your book?")

    private let manualButton = GriffaButton(title: "Add it manually", style: .outlined)

    init() {
        super.init(frame: .zero)

        setupScrollView()
        setupContent()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            // Acompanha o teclado: o conteúdo nunca fica escondido atrás dele
            scrollView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    private func setupContent() {
        resultsStackView.addArrangedSubview(resultsCountLabel)
        resultsStackView.addArrangedSubview(resultsCard)

        [searchBookLabel, searchBarComponent, resultsStackView, divider, manualButton].forEach {
            contentStackView.addArrangedSubview($0)
        }

        contentStackView.setCustomSpacing(20, after: searchBookLabel)
        contentStackView.setCustomSpacing(16, after: searchBarComponent)
        contentStackView.setCustomSpacing(24, after: resultsStackView)
        contentStackView.setCustomSpacing(16, after: divider)
    }

    private func setupActions() {
        searchBarComponent.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onQueryChange?(searchBarComponent.text ?? "")
        }, for: .editingChanged)

        // Tecla "Search" fecha o teclado
        searchBarComponent.addAction(UIAction { [weak self] _ in
            _ = self?.searchBarComponent.resignFirstResponder()
        }, for: .primaryActionTriggered)

        resultsCard.onSelectBook = { [weak self] book in
            self?.onSelectBook?(book)
        }

        manualButton.addAction(UIAction { [weak self] _ in
            self?.onAddManually?()
        }, for: .touchUpInside)
    }


    func showContent(_ content: Content, animated: Bool = true) {
        switch content {
        case .hidden:
            setResultsVisible(false, animated: animated)
            return
        case .loading:
            resultsCountLabel.isHidden = true
            resultsCard.showLoading()
        case .message(let text):
            resultsCountLabel.isHidden = true
            resultsCard.showMessage(text)
        case .books(let books):
            resultsCountLabel.isHidden = false
            resultsCountLabel.text = books.count == 1 ? "1 result" : "\(books.count) results"
            resultsCard.show(books: books)
        }
        setResultsVisible(true, animated: animated)
    }

    private func setResultsVisible(_ isVisible: Bool, animated: Bool) {
        guard resultsStackView.isHidden == isVisible else { return }

        let changes = {
            self.resultsStackView.isHidden = !isVisible
            self.resultsStackView.alpha = isVisible ? 1 : 0
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: changes)
        } else {
            changes()
        }
    }
}

extension AddBookView {

    enum Content {
        case hidden
        case loading
        case message(String)
        case books([Book])
    }
}

#Preview {
    let controller = UIViewController()
    controller.view = AddBookView()
    return controller
}

#Preview("Results") {
    let view = AddBookView()
    view.showContent(.books([
        Book(title: "Midnight Sun", author: "Stephenie Meyer", numberOfPages: 379, quotes: []),
        Book(title: "Alice's Adventures in Wonderland", author: "Lewis Carroll", numberOfPages: 96, quotes: [])
    ]), animated: false)

    let controller = UIViewController()
    controller.view = view
    return controller
}

#Preview("No results") {
    let view = AddBookView()
    view.showContent(.message("No books found. Try another title or author."), animated: false)

    let controller = UIViewController()
    controller.view = view
    return controller
}
