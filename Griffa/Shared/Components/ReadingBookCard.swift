//
//  ReadingBookCard.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//
import UIKit

struct ReadingBookContent {
    let id: UUID
    let title: String
    let author: String
    let currentPage: Int
    let pages: Int
    let coverURL: URL?
}

final class ReadingBookCard: UIControl {
    
    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let percentageCompleted = UILabel()
    private let pagesLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)


    private let coverSize = CGSize(width: 70, height: 100)

    init(title: String, author: String, currentPage: Int, pages: Int, coverURL: URL?) {
        super.init(frame: .zero)
        configure()
        setupCover(url: coverURL)
        let percentage = setupLabels(title: title, author: author, currentPage: currentPage, pages: pages)
        setupAccessibility(title: title, author: author, percentage: percentage, pages: pages)

    }
    
    convenience init(content: ReadingBookContent) {
        self.init(
            title: content.title,
            author: content.author,
            currentPage: content.currentPage,
            pages: content.pages,
            coverURL: content.coverURL
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(resource: .backgroundCard)
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor(resource: .tertiaryPurple).cgColor
        translatesAutoresizingMaskIntoConstraints = false
        // A borda é um CGColor e não acompanha o Dark Mode sozinha
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
            self.layer.borderColor = UIColor(resource: .tertiaryPurple).cgColor
        }
    }
    
    private func setupCover(url: URL?) {
        coverImageView.backgroundColor = UIColor(resource: .tertiaryPurple)
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 4
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(coverImageView)
        
        NSLayoutConstraint.activate([
            // A altura do card é definida pelo texto (ou pela capa, se for maior); a capa fica centralizada
            coverImageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 10),
            coverImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10),
            coverImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
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
    
    /// Monta os labels e devolve a porcentagem lida, para reaproveitar na acessibilidade.
    private func setupLabels(title: String, author: String, currentPage: Int, pages: Int) -> Int {
        // Sem total de páginas não há como calcular o progresso
        let page = min(max(currentPage, 0), pages)
        let progress = pages > 0 ? Float(page) / Float(pages) : 0
        let percentage = Int((progress * 100).rounded())

        titleLabel.text = title
        titleLabel.font = Fonts.title2()
        titleLabel.textColor = .label
        
        authorLabel.text = author
        authorLabel.font = Fonts.body()
        authorLabel.textColor = .secondaryLabel
        
        percentageCompleted.text = "\(percentage)% completed"
        percentageCompleted.font = Fonts.body()
        percentageCompleted.textColor = .secondaryLabel

        pagesLabel.text = pages > 0 ? "p. \(page) of \(pages)" : nil
        pagesLabel.font = Fonts.body()
        pagesLabel.textColor = .secondaryLabel

        [titleLabel, authorLabel, percentageCompleted, pagesLabel].forEach {
            $0.adjustsFontForContentSizeCategory = true
        }

        // Barra fina e arredondada: fundo claro, preenchimento roxo
        progressView.progress = progress
        progressView.progressTintColor = UIColor(resource: .primaryPurple)
        progressView.trackTintColor = UIColor(resource: .tertiaryPurple)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.heightAnchor.constraint(equalToConstant: 8).isActive = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, progressView, percentageCompleted, pagesLabel])
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 5
        textStack.setCustomSpacing(10, after: authorLabel)
//        textStack.isUserInteractionEnabled = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textStack)
        
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            textStack.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 20),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        return percentage
    }

    private func setupAccessibility(title: String, author: String, percentage: Int, pages: Int) {
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = [title, author, pages > 0 ? "\(percentage)% completed" : nil, pages > 0 ? "\(pages) pages" : nil]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

#Preview {
    ReadingBookCard(title: "Midnight Sun", author: "Stephenie Meyer", currentPage: 150, pages: 300, coverURL: nil)
}
