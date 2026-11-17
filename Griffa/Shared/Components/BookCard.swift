//
//  BookCard.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import UIKit

nonisolated struct BookCardContent: Hashable, Sendable {
    let id: UUID
    let title: String
    let author: String
    let progressText: String
    let pagesText: String?
    let coverURL: URL?
    let coverData: Data?            // capa já salva no livro (tem prioridade sobre a URL)

    // A capa (bytes) não entra na comparação: não muda e seria caro de comparar a cada atualização.
    static func == (lhs: BookCardContent, rhs: BookCardContent) -> Bool {
        lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.author == rhs.author
            && lhs.progressText == rhs.progressText
            && lhs.pagesText == rhs.pagesText
            && lhs.coverURL == rhs.coverURL
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(progressText)
        hasher.combine(pagesText)
    }
}

final class BookCard: UIView {

    static let width: CGFloat = 130

    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let progressLabel = UILabel()
    private let pagesLabel = UILabel()

    private var coverTask: Task<Void, Never>?

    init() {
        super.init(frame: .zero)
        configure()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func configure() {
        backgroundColor = UIColor(resource: .backgroundCard)
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(resource: .tertiaryPurple).cgColor
        translatesAutoresizingMaskIntoConstraints = false

        // A borda é um CGColor e não acompanha o Dark Mode sozinha
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
            self.layer.borderColor = UIColor(resource: .tertiaryPurple).cgColor
        }

        coverImageView.backgroundColor = .tertiaryPurple     // visível até a capa carregar
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 4
        coverImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = Fonts.headline()
        titleLabel.textColor = .label
        authorLabel.font = Fonts.body()
        authorLabel.textColor = .secondaryLabel
        progressLabel.font = Fonts.body()
        progressLabel.textColor = .secondaryLabel
        pagesLabel.font = Fonts.body()
        pagesLabel.textColor = .tertiaryLabel

        [titleLabel, authorLabel, progressLabel, pagesLabel].forEach {
            $0.textAlignment = .center
            $0.numberOfLines = 1
            $0.adjustsFontForContentSizeCategory = true
        }
    }

    private func setupLayout() {
        let coverContainer = UIView()
        coverContainer.addSubview(coverImageView)

        let stackView = UIStackView(arrangedSubviews: [coverContainer, titleLabel, authorLabel, progressLabel, pagesLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.setCustomSpacing(10, after: coverContainer)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            // Capa 75×107 (proporção de uma capa de livro), centralizada
            coverImageView.topAnchor.constraint(equalTo: coverContainer.topAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: coverContainer.bottomAnchor),
            coverImageView.centerXAnchor.constraint(equalTo: coverContainer.centerXAnchor),
            coverImageView.widthAnchor.constraint(equalToConstant: 75),
            coverImageView.heightAnchor.constraint(equalToConstant: 107)
        ])
        // O tamanho da imagem baixada não pode influenciar o layout
        for axis in [NSLayoutConstraint.Axis.horizontal, .vertical] {
            coverImageView.setContentHuggingPriority(UILayoutPriority(1), for: axis)
            coverImageView.setContentCompressionResistancePriority(UILayoutPriority(1), for: axis)
        }
    }

    func configure(with content: BookCardContent) {
        titleLabel.text = content.title
        authorLabel.text = content.author
        progressLabel.text = content.progressText
        pagesLabel.text = content.pagesText
        pagesLabel.isHidden = content.pagesText == nil

        loadCover(for: content)

        isAccessibilityElement = true
        accessibilityLabel = [content.title, content.author, content.progressText, content.pagesText]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    func prepareForReuse() {
        coverTask?.cancel()
        coverImageView.image = nil
    }

    private func loadCover(for content: BookCardContent) {
        coverTask?.cancel()
        coverImageView.image = nil

        // Capa já salva no livro: não precisa de rede
        if let data = content.coverData, let image = UIImage(data: data) {
            coverImageView.image = image
            return
        }

        guard let url = content.coverURL else { return }
        coverTask = Task { [weak self] in
            let image = await ImageLoader.shared.image(for: url)
            guard !Task.isCancelled else { return }
            self?.coverImageView.image = image
        }
    }
}

#Preview {
    let card = BookCard()
    card.configure(with: BookCardContent(
        id: UUID(), title: "Midnight Sun", author: "Stephenie Meyer",
        progressText: "40% completed", pagesText: "p. 132 of 379", coverURL: nil, coverData: nil
    ))
    card.widthAnchor.constraint(equalToConstant: BookCard.width).isActive = true
    return card
}
