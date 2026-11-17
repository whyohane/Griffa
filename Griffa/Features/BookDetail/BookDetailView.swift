//
//  BookDetailView.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import UIKit

nonisolated struct BookInfoItem: Hashable, Sendable {
    let label: String
    let value: String
}

final class SelfSizingCollectionView: UICollectionView {

    override var contentSize: CGSize {
        didSet {
            if oldValue != contentSize { invalidateIntrinsicContentSize() }
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: max(contentSize.height, 1))
    }
}

final class BookDetailView: UIView {

    var onStatusChange: ((Int) -> Void)?

    var onAddTapped: (() -> Void)?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let coverContainer = UIView()

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiaryPurple     // visível até a capa carregar
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // Lista nativa no estilo "inset grouped": card arredondado com divisores
    private let infoListView: SelfSizingCollectionView = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .clear
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)

        let collectionView = SelfSizingCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Int, BookInfoItem>?

    private let addToLabel: UILabel = {
        let label = UILabel()
        label.text = "Add to".uppercased()
        label.textColor = .label
        label.font = Fonts.title2()
        return label
    }()

    private let statusControl = UISegmentedControl()

    private let addButton = GriffaButton(title: "Add to my books")

    init() {
        super.init(frame: .zero)
        backgroundColor = .systemGroupedBackground

        setupLayout()
        setupCover()
        setupInfoList()
        setupStatusControl()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func setupLayout() {
        addSubview(scrollView)
        addSubview(addButton)
        scrollView.addSubview(contentStackView)

        let addToStackView = UIStackView(arrangedSubviews: [addToLabel, statusControl])
        addToStackView.axis = .vertical
        addToStackView.spacing = 12
        addToStackView.isLayoutMarginsRelativeArrangement = true
        addToStackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        [coverContainer, infoListView, addToStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        contentStackView.setCustomSpacing(8, after: coverContainer)
        contentStackView.setCustomSpacing(16, after: infoListView)

        // O conteúdo nunca passa da altura visível (a capa encolhe). Prioridade 999 em vez de obrigatória:
        // em casos extremos (ex.: texto muito grande) a rolagem volta a funcionar em vez de quebrar o layout.
        let fitsVisibleHeight = contentStackView.heightAnchor.constraint(
            lessThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor,
            constant: -21       // margens de cima (5) e de baixo (16)
        )
        fitsVisibleHeight.priority = UILayoutPriority(999)
        infoListView.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            fitsVisibleHeight,
            addButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),

            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -12),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 5),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor)
        ])
    }

    private func setupCover() {
        coverContainer.addSubview(coverImageView)

        for axis in [NSLayoutConstraint.Axis.horizontal, .vertical] {
            coverImageView.setContentCompressionResistancePriority(UILayoutPriority(1), for: axis)
            coverImageView.setContentHuggingPriority(UILayoutPriority(1), for: axis)
        }

        let preferredHeight = coverContainer.heightAnchor.constraint(equalToConstant: 300)
        preferredHeight.priority = UILayoutPriority(700)

        NSLayoutConstraint.activate([
            preferredHeight,
            coverContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            coverImageView.centerXAnchor.constraint(equalTo: coverContainer.centerXAnchor),
            coverImageView.topAnchor.constraint(equalTo: coverContainer.topAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: coverContainer.bottomAnchor),
            // Mantém a proporção da capa (197×300) em qualquer altura
            coverImageView.widthAnchor.constraint(equalTo: coverImageView.heightAnchor, multiplier: 197.0 / 300.0)
        ])
    }

    private func setupInfoList() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, BookInfoItem> { cell, _, item in
            var content = UIListContentConfiguration.subtitleCell()
            content.text = item.label
            content.textProperties.font = Fonts.body()
            content.textProperties.color = .secondaryLabel
            content.secondaryText = item.value
            content.secondaryTextProperties.font = Fonts.bodyMedium()
            content.secondaryTextProperties.color = .label
            content.textToSecondaryTextVerticalPadding = 4
            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: infoListView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    private func setupStatusControl() {
        statusControl.applyGriffaStyle()
    }

    private func setupActions() {
        statusControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onStatusChange?(statusControl.selectedSegmentIndex)
        }, for: .valueChanged)

        addButton.addAction(UIAction { [weak self] _ in
            self?.onAddTapped?()
        }, for: .touchUpInside)
    }

    func show(coverURL: URL?, info: [BookInfoItem], statusTitles: [String], selectedStatus: Int) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, BookInfoItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(info)
        dataSource?.apply(snapshot, animatingDifferences: false)

        statusControl.removeAllSegments()
        for (index, title) in statusTitles.enumerated() {
            statusControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        statusControl.selectedSegmentIndex = selectedStatus

        guard let coverURL else { return }
        Task { [weak self] in
            let image = await ImageLoader.shared.image(for: coverURL)
            self?.coverImageView.image = image
        }
    }

    func setAdding(_ isAdding: Bool) {
        addButton.setLoading(isAdding)
        statusControl.isEnabled = !isAdding
    }
}

// A view precisa ocupar a tela inteira, por isso o preview a coloca em um controller.
#Preview {
    let view = BookDetailView()
    view.show(
        coverURL: nil,
        info: [
            BookInfoItem(label: "Title", value: "Coraline"),
            BookInfoItem(label: "Author", value: "Neil Gaiman"),
            BookInfoItem(label: "Pages", value: "192")
        ],
        statusTitles: ReadingStatus.allCases.map(\.title),
        selectedStatus: 0
    )

    let controller = UIViewController()
    controller.view = view
    return controller
}
