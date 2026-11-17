//
//  BookResultsCard.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import UIKit

final class BookResultsCard: UIView {

    var onSelectBook: ((Book) -> Void)?

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init() {
        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func configure() {
        backgroundColor = UIColor(resource: .backgroundCard)
        layer.cornerRadius = 20
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }

    func showLoading() {
        replaceContent(with: [makeMessageView(text: "Searching...", showsSpinner: true)])
    }

    func showMessage(_ text: String) {
        replaceContent(with: [makeMessageView(text: text, showsSpinner: false)])
    }

    func show(books: [Book]) {
        var views: [UIView] = []
        for (index, book) in books.enumerated() {
            if index > 0 { views.append(makeSeparator()) }

            let row = BookRow(
                title: book.title,
                author: book.author,
                pages: book.numberOfPages,
                coverURL: book.coverURL,
                showsDisclosureIndicator: true
            )
            row.onTap = { [weak self] in self?.onSelectBook?(book) }
            views.append(row)
        }
        replaceContent(with: views)
    }

    private func replaceContent(with views: [UIView]) {
        contentStackView.arrangedSubviews.forEach {
            contentStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        views.forEach { contentStackView.addArrangedSubview($0) }
    }

    private func makeMessageView(text: String, showsSpinner: Bool) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = Fonts.body()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 20, bottom: 32, right: 20)

        if showsSpinner {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            stackView.addArrangedSubview(spinner)
        }
        stackView.addArrangedSubview(label)
        return stackView
    }

    private func makeSeparator() -> UIView {
        let container = UIView()
        let line = UIView()
        line.backgroundColor = .separator
        line.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 1),
            line.topAnchor.constraint(equalTo: container.topAnchor),
            line.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        return container
    }
}
