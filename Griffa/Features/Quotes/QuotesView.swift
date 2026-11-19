//
//  QuotesView.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import UIKit

final class QuotesView: UIView {

    var onQueryChange: ((String) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Quotes"
        label.textColor = .label
        label.font = Fonts.title()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let searchField = GriffaSearchField(placeholder: "Search")

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let cardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .backgroundPurple)
        setupTitleLabel()
        setupSearchField()
        setupCards()
        setupEmptyLabel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func setupTitleLabel() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }

    private func setupSearchField() {
        addSubview(searchField)

        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        searchField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onQueryChange?(searchField.text ?? "")
        }, for: .editingChanged)

        // Tecla "Search" fecha o teclado
        searchField.addAction(UIAction { [weak self] _ in
            _ = self?.searchField.resignFirstResponder()
        }, for: .primaryActionTriggered)
    }

    private func setupCards() {
        addSubview(scrollView)
        scrollView.addSubview(cardsStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            cardsStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            cardsStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            cardsStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            cardsStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    private func setupEmptyLabel() {
        addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            emptyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
    }

    /// Mostra os cards, ou a mensagem quando não há nenhum.
    func show(quotes: [QuoteCardContent], emptyText: String?) {
        cardsStackView.arrangedSubviews.forEach {
            cardsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        quotes.forEach { cardsStackView.addArrangedSubview(QuoteCard(content: $0)) }

        emptyLabel.text = emptyText
        emptyLabel.isHidden = emptyText == nil
    }
}
