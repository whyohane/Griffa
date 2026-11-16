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
    
    private let quoteCard = QuoteCard(
        title: "Quote of the day",
        quote: "I knew who I was when I got up this morning, but I think I must have been changed several times since then.",
        bookTitle: "Alice's Adventures in Wonderland",
        author: "Lewis Carroll",
        page: 56
    )
    
    private let readingLabelView: UILabel = {
        let readingLabel = UILabel()
        readingLabel.text = "Reading now".uppercased()
        readingLabel.textColor = .label
        readingLabel.font = Fonts.title2()
        readingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return readingLabel
    }()
    
    func setDate(_ text: String) {
        dateLabelView.text = text
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .backgroundPurple)
        setupWelcomeLabel()
        setupDateLabel()
        setupQuoteCard()
        setupReadingLabel()
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
        
        NSLayoutConstraint.activate([
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
}

#Preview {
    let viewModel = SummaryViewModel(store: UserDefaultsProfileStore())
    return UINavigationController(rootViewController: SummaryViewController(viewModel: viewModel))
}
