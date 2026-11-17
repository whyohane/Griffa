//
//  BookRow.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import UIKit

final class BookRow: UIControl {
    
    var onTap: (() -> Void)?

    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let pagesLabel = UILabel()
    private let chevronImageView = UIImageView()

    private let coverSize = CGSize(width: 70, height: 100)

    init(title: String, author: String, pages: Int, coverURL: URL?, showsDisclosureIndicator: Bool = false) {
        super.init(frame: .zero)
        configure()
        setupCover(url: coverURL)
        if showsDisclosureIndicator { setupChevron() }
        setupLabels(title: title, author: author, pages: pages, hasChevron: showsDisclosureIndicator)
        setupAccessibility(title: title, author: author, pages: pages)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    // Destaque enquanto a linha está pressionada
    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? .secondarySystemBackground : UIColor(resource: .backgroundCard) }
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addAction(UIAction { [weak self] _ in self?.onTap?() }, for: .touchUpInside)
    }

    private func setupCover(url: URL?) {
        coverImageView.backgroundColor = .tertiaryPurple  // fica visível até a capa carregar
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 6
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coverImageView)

        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            coverImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            coverImageView.widthAnchor.constraint(equalToConstant: coverSize.width),
            coverImageView.heightAnchor.constraint(equalToConstant: coverSize.height)
        ])

        guard let url else { return }
        Task { [weak self] in
            let image = await ImageLoader.shared.image(for: url)
            self?.coverImageView.image = image
        }
    }

    private func setupChevron() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: configuration)
        chevronImageView.tintColor = .tertiaryLabel
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.setContentHuggingPriority(.required, for: .horizontal)
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupLabels(title: String, author: String, pages: Int, hasChevron: Bool) {
        titleLabel.text = title
        titleLabel.font = Fonts.headline()
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        authorLabel.text = author
        authorLabel.font = Fonts.body()
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 2

        pagesLabel.text = pages > 0 ? "\(pages) pages" : nil
        pagesLabel.font = Fonts.body()
        pagesLabel.textColor = .secondaryLabel

        [titleLabel, authorLabel, pagesLabel].forEach {
            $0.adjustsFontForContentSizeCategory = true
        }

        let textStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, pagesLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 5
        textStack.isUserInteractionEnabled = false      // o toque é da linha inteira
        textStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textStack)

        let textTrailing = hasChevron
            ? textStack.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12)
            : textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)

        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: coverImageView.topAnchor, constant: 4),
            textStack.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 20),
            textTrailing,
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
        ])
    }

    private func setupAccessibility(title: String, author: String, pages: Int) {
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = [title, author, pages > 0 ? "\(pages) pages" : nil]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

#Preview {
    BookRow(title: "Midnight Sun", author: "Stephenie Meyer", pages: 379, coverURL: nil, showsDisclosureIndicator: true)
}
