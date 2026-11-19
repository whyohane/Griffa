//
//  CurrentPageView.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 18/11/26.
//

import UIKit

final class CurrentPageView: UIView {

    /// Soma (ou subtrai) páginas: os botões − e + e os atalhos +5, +10...
    var onAdd: ((Int) -> Void)?

    /// O usuário digitou uma página no campo.
    var onPageTyped: ((Int) -> Void)?

    private let coverImageView = UIImageView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.title2()
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let progressView = UIProgressView(progressViewStyle: .default)

    private let percentLabel = CurrentPageView.makeInfoLabel()
    private let pagesLabel = CurrentPageView.makeInfoLabel()

    private let pageField = GriffaTextField(label: "0", keyboardType: .numberPad)

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let buttonSize: CGFloat = 62

    private var coverTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .backgroundSheet)

        setupContent()
        setupKeyboardDismissal()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    deinit {
        coverTask?.cancel()
    }

    // MARK: - Interface para o ViewController

    /// Dados fixos do livro (não mudam enquanto a sheet está aberta).
    func setBook(title: String, author: String, coverData: Data?, coverURL: URL?) {
        titleLabel.text = title
        authorLabel.text = author
        loadCover(data: coverData, url: coverURL)
    }

    /// Parte que muda quando a página muda.
    func setProgress(_ progress: Float, percentText: String, pagesText: String, page: Int) {
        // Anima só depois de a sheet estar na tela (a primeira vez, a barra já nasce no valor certo)
        progressView.setProgress(progress, animated: window != nil)
        percentLabel.text = percentText
        pagesLabel.text = pagesText

        // Não reescreve o campo enquanto o usuário digita o mesmo número (nem apaga tudo para "0")
        let typed = Int(pageField.text ?? "")
        let isClearing = pageField.isFirstResponder && (pageField.text ?? "").isEmpty && page == 0
        if typed != page && !isClearing {
            pageField.text = String(page)
        }
    }

    // MARK: - Layout

    private func setupContent() {
        setupCover()
        setupProgress()

        let progressLabelsStack = UIStackView(arrangedSubviews: [percentLabel, pagesLabel])
        progressLabelsStack.axis = .horizontal
        pagesLabel.textAlignment = .right

        // A capa fica num container para ser centralizada com tamanho fixo; o resto ocupa a largura toda
        let coverContainer = UIView()
        coverContainer.addSubview(coverImageView)
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: coverContainer.topAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: coverContainer.bottomAnchor),
            coverImageView.centerXAnchor.constraint(equalTo: coverContainer.centerXAnchor)
        ])

        [coverContainer, titleLabel, authorLabel, progressView, progressLabelsStack, makeStepperRow(), makeQuickStepsRow()]
            .forEach { contentStackView.addArrangedSubview($0) }

        contentStackView.setCustomSpacing(10, after: coverContainer)
        contentStackView.setCustomSpacing(2, after: titleLabel)
        contentStackView.setCustomSpacing(20, after: authorLabel)
        contentStackView.setCustomSpacing(8, after: progressView)
        contentStackView.setCustomSpacing(20, after: progressLabelsStack)
        contentStackView.setCustomSpacing(12, after: contentStackView.arrangedSubviews[5])

        addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }

    private func setupCover() {
        coverImageView.backgroundColor = UIColor(resource: .tertiaryPurple)     // visível até a capa carregar
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 4
        coverImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            coverImageView.widthAnchor.constraint(equalToConstant: 80),
            coverImageView.heightAnchor.constraint(equalToConstant: 115)
        ])
    }

    private func setupProgress() {
        progressView.progressTintColor = UIColor(resource: .primaryPurple)
        progressView.trackTintColor = UIColor(resource: .tertiaryPurple)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.heightAnchor.constraint(equalToConstant: 8).isActive = true
    }

    /// − [ campo ] +
    private func makeStepperRow() -> UIView {
        let minusButton = makeCircleButton(systemName: "minus", filled: false)
        let plusButton = makeCircleButton(systemName: "plus", filled: true)

        minusButton.addAction(UIAction { [weak self] _ in self?.onAdd?(-1) }, for: .touchUpInside)
        plusButton.addAction(UIAction { [weak self] _ in self?.onAdd?(1) }, for: .touchUpInside)

        pageField.font = Fonts.title()
        pageField.textAlignment = .center
        pageField.clearButtonMode = .never
        pageField.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        pageField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            // Campo vazio conta como 0
            onPageTyped?(Int(pageField.text ?? "") ?? 0)
        }, for: .editingChanged)

        let row = UIStackView(arrangedSubviews: [minusButton, pageField, plusButton])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .fill
        return row
    }

    /// +5  +10  +20  +50
    private func makeQuickStepsRow() -> UIView {
        let buttons = CurrentPageViewModel.quickSteps.map { step -> UIButton in
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString("+\(step)", attributes: AttributeContainer([
                .font: Fonts.button(),
                .foregroundColor: UIColor(resource: .primaryPurple)
            ]))
            configuration.background.backgroundColor = UIColor(resource: .backgroundStatusBar)
            configuration.background.cornerRadius = 22
            let button = UIButton(configuration: configuration)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.addAction(UIAction { [weak self] _ in self?.onAdd?(step) }, for: .touchUpInside)
            return button
        }

        let row = UIStackView(arrangedSubviews: buttons)
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        return row
    }

    private func makeCircleButton(systemName: String, filled: Bool) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        configuration.baseForegroundColor = filled ? .white : .label
        configuration.background.backgroundColor = filled
            ? UIColor(resource: .primaryPurple)
            : UIColor(resource: .backgroundTextField)
        configuration.background.cornerRadius = buttonSize / 2

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonSize),
            button.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
        button.accessibilityLabel = systemName == "plus" ? "Add one page" : "Remove one page"
        return button
    }

    private func loadCover(data: Data?, url: URL?) {
        coverTask?.cancel()

        // Capa já salva no livro: não precisa de rede
        if let data, let image = UIImage(data: data) {
            coverImageView.image = image
            return
        }

        guard let url else { return }
        coverTask = Task { [weak self] in
            let image = await ImageLoader.shared.image(for: url)
            guard !Task.isCancelled else { return }
            self?.coverImageView.image = image
        }
    }

    // Toque fora do campo fecha o teclado (o teclado numérico não tem tecla de retorno)
    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }

    private static func makeInfoLabel() -> UILabel {
        let label = UILabel()
        label.font = Fonts.body()
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        return label
    }
}

#Preview {
    let controller = UIViewController()
    let view = CurrentPageView()
    view.setBook(title: "Coraline", author: "Neil Gaiman", coverData: nil, coverURL: nil)
    view.setProgress(0.53, percentText: "53% completed", pagesText: "p. 160 of 300", page: 160)
    controller.view = view
    return controller
}
