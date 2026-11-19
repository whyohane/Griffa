//
//  AddQuoteView.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 18/11/26.
//

import UIKit

final class AddQuoteView: UIView {

    var onQuoteChange: ((String) -> Void)?
    var onBookSelected: ((Int) -> Void)?
    var onPageChange: ((String) -> Void)?
    var onThoughtsChange: ((String) -> Void)?

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

    private let quoteTextView = GriffaTextView(
        placeholder: "Type the quote you want to save...",
        maxLength: AddQuoteViewModel.maxQuoteLength
    )

    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body()
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let bookButton = UIButton(type: .system)

    private let pageField = GriffaTextField(label: "145", keyboardType: .numberPad)

    private let thoughtsTextView = GriffaTextView(placeholder: "Write what it reminded you of, or how it made you feel...")

    private var bookTitles: [String] = []
    private var selectedBookIndex: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .backgroundSheet)

        setupScrollView()
        setupContent()
        setupBookButton()
        setupActions()
        setupKeyboardDismissal()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    // MARK: - Interface para o ViewController

    func setCharacterCount(_ text: String) {
        characterCountLabel.text = text
    }

    func setPageInvalid(_ isInvalid: Bool) {
        pageField.textColor = isInvalid ? .systemRed : .label
    }

    func setBooks(titles: [String], selected: Int?) {
        bookTitles = titles
        selectedBookIndex = selected

        let actions = titles.enumerated().map { index, title in
            UIAction(title: title, state: index == selected ? .on : .off) { [weak self] _ in
                self?.onBookSelected?(index)
            }
        }
        bookButton.menu = UIMenu(children: actions)
        bookButton.isEnabled = !titles.isEmpty
        updateBookButtonTitle()
    }

    // MARK: - Layout

    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            // Acompanha o teclado: o campo em foco nunca fica escondido atrás dele
            scrollView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    private func setupContent() {
        quoteTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        thoughtsTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        // Livro e página lado a lado: o livro ocupa o espaço que sobra
        let bookColumn = makeColumn(title: "Book", content: bookButton)
        let pageColumn = makeColumn(title: "Page", content: pageField)
        let rowStackView = UIStackView(arrangedSubviews: [bookColumn, pageColumn])
        rowStackView.axis = .horizontal
        rowStackView.spacing = 16
        rowStackView.alignment = .top
        pageColumn.widthAnchor.constraint(equalTo: rowStackView.widthAnchor, multiplier: 0.32).isActive = true

        [
            makeSectionLabel("Quote"), quoteTextView, characterCountLabel,
            rowStackView,
            makeSectionLabel("My thoughts"), thoughtsTextView
        ].forEach { contentStackView.addArrangedSubview($0) }

        contentStackView.setCustomSpacing(8, after: contentStackView.arrangedSubviews[0])
        contentStackView.setCustomSpacing(6, after: quoteTextView)
        contentStackView.setCustomSpacing(20, after: characterCountLabel)
        contentStackView.setCustomSpacing(20, after: rowStackView)
        contentStackView.setCustomSpacing(8, after: contentStackView.arrangedSubviews[4])
    }

    private func setupBookButton() {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "chevron.down")
        configuration.imagePlacement = .trailing
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        configuration.background.backgroundColor = UIColor(resource: .backgroundTextField)
        configuration.background.cornerRadius = 12
        configuration.background.strokeColor = UIColor(resource: .strokeTextField)
        configuration.background.strokeWidth = 1
        bookButton.configuration = configuration

        bookButton.showsMenuAsPrimaryAction = true
        bookButton.contentHorizontalAlignment = .fill
        bookButton.tintColor = .label
        bookButton.translatesAutoresizingMaskIntoConstraints = false
        bookButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true

        updateBookButtonTitle()
    }

    private func updateBookButtonTitle() {
        let hasBooks = !bookTitles.isEmpty
        let title: String
        let color: UIColor
        if let selectedBookIndex, bookTitles.indices.contains(selectedBookIndex) {
            title = bookTitles[selectedBookIndex]
            color = .label
        } else {
            title = hasBooks ? "Choose the book..." : "No books being read"
            color = .placeholderText
        }

        bookButton.configuration?.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: Fonts.body(),
            .foregroundColor: color
        ]))
        bookButton.configuration?.titleLineBreakMode = .byTruncatingTail
    }

    private func setupActions() {
        quoteTextView.onTextChange = { [weak self] text in
            self?.onQuoteChange?(text)
        }
        thoughtsTextView.onTextChange = { [weak self] text in
            self?.onThoughtsChange?(text)
        }
        pageField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onPageChange?(pageField.text ?? "")
        }, for: .editingChanged)
    }

    // Toque fora dos campos fecha o teclado (o teclado numérico não tem tecla de retorno)
    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }

    // MARK: - Auxiliares

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = Fonts.title2()
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    private func makeColumn(title: String, content: UIView) -> UIStackView {
        let column = UIStackView(arrangedSubviews: [makeSectionLabel(title), content])
        column.axis = .vertical
        column.spacing = 8
        column.alignment = .fill
        return column
    }
}

#Preview {
    let controller = UIViewController()
    let view = AddQuoteView()
    view.setBooks(titles: ["Coraline", "Alice's Adventures in Wonderland"], selected: nil)
    view.setCharacterCount("0/500 characters")
    controller.view = view
    return controller
}
