//
//  QuoteCard.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//
import UIKit

final class QuoteCard: UIView {

    private let titleLabel = UILabel()
    private let quoteLabel = UILabel()
    private let dividerView = UIView()
    private let bookTitleLabel = UILabel()
    private let authorLabel = UILabel()

    private let horizontalMargin: CGFloat = 20

    init(title: String, quote: String, bookTitle: String, author: String, page: Int) {
        super.init(frame: .zero)
        configure()
        setupTitleLabel(title)
        setupQuoteLabel(quote)
        setupDividerView()
        setupBookTitleLabel(bookTitle)
        setupAuthorLabel(author: author, page: page)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func configure() {
        backgroundColor = UIColor(resource: .backgroundCard)
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.10
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 4)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 250).isActive = true
    }

    private func setupTitleLabel(_ title: String) {
        titleLabel.text = title.uppercased()
        titleLabel.font = Fonts.bodyMedium()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = UIColor(resource: .primaryPurple)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalMargin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalMargin)
        ])
    }

    private func setupQuoteLabel(_ quote: String) {
        quoteLabel.text = "\"\(quote)\""
        quoteLabel.font = Fonts.quote()
        quoteLabel.adjustsFontForContentSizeCategory = true
        quoteLabel.textColor = .label
        quoteLabel.numberOfLines = 0
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(quoteLabel)

        NSLayoutConstraint.activate([
            quoteLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            quoteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalMargin),
            quoteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalMargin)
        ])
    }

    private func setupDividerView() {
        dividerView.backgroundColor = UIColor(resource: .primaryPurple).withAlphaComponent(0.3)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dividerView)

        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(greaterThanOrEqualTo: quoteLabel.bottomAnchor, constant: 24),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalMargin),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalMargin),
            dividerView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupBookTitleLabel(_ bookTitle: String) {
        bookTitleLabel.text = bookTitle
        bookTitleLabel.font = Fonts.headline()
        bookTitleLabel.adjustsFontForContentSizeCategory = true
        bookTitleLabel.textColor = .label
        bookTitleLabel.numberOfLines = 0
        bookTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bookTitleLabel)

        NSLayoutConstraint.activate([
            bookTitleLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 16),
            bookTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalMargin),
            bookTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalMargin)
        ])
    }

    private func setupAuthorLabel(author: String, page: Int) {
        authorLabel.text = "\(author) • p. \(page)"
        authorLabel.font = Fonts.body()
        authorLabel.adjustsFontForContentSizeCategory = true
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 0
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(authorLabel)

        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: bookTitleLabel.bottomAnchor, constant: 2),
            authorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalMargin),
            authorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalMargin),
            authorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}

#Preview {
    QuoteCard(title: "Quote of the day", quote: "I knew who I was when I got up this morning, but I think I must have been changed several times since then.", bookTitle: "Alice's Adventures in Wonderland", author: "Lewis Caroll", page: 56)
}

