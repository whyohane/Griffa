//
//  SummaryView.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import UIKit

final class SummaryView: UIView {
    
    private let welcomeLabelView: UILabel = {
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Hello!"
        welcomeLabel.textColor = .label
        welcomeLabel.font = Fonts.title()
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return welcomeLabel
    }()
    
    private let dateLabelView: UILabel = {
        let dateLabel = UILabel()
        dateLabel.textColor = .secondaryLabel
        dateLabel.font = Fonts.timeLabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }()
    
    // Começa com o aviso de "sem quotes"; o controller troca pelo conteúdo real
    private let quoteCard: QuoteCard = {
        let card = QuoteCard(content: QuoteCardContent(
            id: UUID(), title: Summary.quoteTitle, quote: "", bookTitle: "", author: "", page: nil
        ))
        card.showMessage(title: Summary.quoteTitle, message: Summary.emptyQuoteMessage)
        return card
    }()

    private let readingLabelView: UILabel = {
        let readingLabel = UILabel()
        readingLabel.text = "Reading now".uppercased()
        readingLabel.textColor = .label
        readingLabel.font = Fonts.title2()
        readingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return readingLabel
    }()
    
    // Os cards rolam, porque podem ser vários livros
    private let readingScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let readingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// O usuário tocou no card de um livro em "Reading now".
    var onSelectBook: ((UUID) -> Void)?

    /// Mostra a quote do dia, ou o aviso quando ainda não há nenhuma quote salva.
    func showQuoteOfTheDay(_ content: QuoteCardContent?) {
        if let content {
            quoteCard.configure(with: content)
        } else {
            quoteCard.showMessage(title: Summary.quoteTitle, message: Summary.emptyQuoteMessage)
        }
    }

    func setDate(_ text: String) {
        dateLabelView.text = text
    }
    
    func showReadingBooks(_ books: [ReadingBookContent]) {
        readingStackView.arrangedSubviews.forEach {
            readingStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        books.forEach { book in
            let card = ReadingBookCard(content: book)
            card.addAction(UIAction { [weak self] _ in
                self?.onSelectBook?(book.id)
            }, for: .touchUpInside)
            readingStackView.addArrangedSubview(card)
        }
        readingLabelView.isHidden = books.isEmpty
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .backgroundPurple)
        setupWelcomeLabel()
        setupDateLabel()
        setupQuoteCard()
        setupReadingLabel()
        setupReadingBooks()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }
    
    func setGreeting(_ text: String) {
        welcomeLabelView.text = text
    }
    
    private func setupWelcomeLabel() {
        addSubview(welcomeLabelView)
        
        NSLayoutConstraint.activate([
            welcomeLabelView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            welcomeLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            welcomeLabelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20)
        ])
    }
    
    private func setupDateLabel() {
        addSubview(dateLabelView)
        
        NSLayoutConstraint.activate([
            dateLabelView.topAnchor.constraint(equalTo: welcomeLabelView.bottomAnchor, constant: 15),
            dateLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            dateLabelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20)
        ])
    }
    
    private func setupQuoteCard() {
        addSubview(quoteCard)
        
        // O card só cresce se o texto exigir; o espaço que sobra fica para a lista de livros abaixo
        let preferredHeight = quoteCard.heightAnchor.constraint(equalToConstant: 250)
        preferredHeight.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            preferredHeight,
            quoteCard.topAnchor.constraint(equalTo: dateLabelView.bottomAnchor, constant: 24),
            quoteCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            quoteCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    private func setupReadingLabel() {
        addSubview(readingLabelView)
        
        NSLayoutConstraint.activate([
            readingLabelView.topAnchor.constraint(equalTo: quoteCard.bottomAnchor, constant: 20),
            readingLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            readingLabelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    private func setupReadingBooks() {
        addSubview(readingScrollView)
        readingScrollView.addSubview(readingStackView)
        
        NSLayoutConstraint.activate([
            readingScrollView.topAnchor.constraint(equalTo: readingLabelView.bottomAnchor, constant: 12),
            readingScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            readingScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            readingScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            readingStackView.topAnchor.constraint(equalTo: readingScrollView.contentLayoutGuide.topAnchor),
            readingStackView.bottomAnchor.constraint(equalTo: readingScrollView.contentLayoutGuide.bottomAnchor),
            readingStackView.leadingAnchor.constraint(equalTo: readingScrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            readingStackView.trailingAnchor.constraint(equalTo: readingScrollView.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
}

private enum Summary {
    static let quoteTitle = "Quote of the day"
    static let emptyQuoteMessage = "Save a quote in the Quotes tab and one of them will show up here every day."
}

#Preview {
    let viewModel = SummaryViewModel(
        store: UserDefaultsProfileStore(),
        booksStore: SwiftDataBooksStore.inMemory(),
        quotesStore: SwiftDataQuotesStore.inMemory(),
        quoteOfTheDayStore: UserDefaultsQuoteOfTheDayStore()
    )
    return UINavigationController(rootViewController: SummaryViewController(viewModel: viewModel))
}
