//
//  BooksView.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//
import UIKit

nonisolated struct BookShelf: Hashable, Sendable {
    let id: String
    let title: String
    let cards: [BookCardContent]
}

final class BookCardCell: UICollectionViewCell {

    private let card = BookCard()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        card.prepareForReuse()
    }

    func configure(with content: BookCardContent) {
        card.configure(with: content)
    }
}

final class ShelfHeaderView: UICollectionReusableView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.title2()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            // Sem margem própria: o cabeçalho já respeita o recuo de 20pt da seção
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
}

final class BooksView: UIView {

    var onFilterChange: ((Int) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Books"
        label.font = Fonts.title()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let filterControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.applyGriffaStyle()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            // Cada estante é uma lista horizontal de cards
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(220)
            ))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(BookCard.width),
                    heightDimension: .estimated(220)
                ),
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 9
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 24, trailing: 20)

            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(24)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset.top = 16     // respiro entre o filtro e a primeira estante
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private var dataSource: UICollectionViewDiffableDataSource<String, BookCardContent>?
    private var shelves: [BookShelf] = []

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(resource: .backgroundPurple)

        setupLayout()
        setupDataSource()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(filterControl)
        addSubview(collectionView)

        collectionView.backgroundView = emptyLabel
        emptyLabel.isHidden = true

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            filterControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            filterControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            filterControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<BookCardCell, BookCardContent> { cell, _, content in
            cell.configure(with: content)
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<ShelfHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, indexPath in
            guard let self, shelves.indices.contains(indexPath.section) else { return }
            header.title = shelves[indexPath.section].title
        }

        let dataSource = UICollectionViewDiffableDataSource<String, BookCardContent>(collectionView: collectionView) {
            collectionView, indexPath, content in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: content)
        }
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        self.dataSource = dataSource
    }

    private func setupActions() {
        filterControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onFilterChange?(filterControl.selectedSegmentIndex)
        }, for: .valueChanged)
    }

    func setFilters(titles: [String], selected: Int) {
        filterControl.removeAllSegments()
        for (index, title) in titles.enumerated() {
            filterControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        filterControl.selectedSegmentIndex = selected
    }

    func show(shelves: [BookShelf], emptyText: String?) {
        self.shelves = shelves

        var snapshot = NSDiffableDataSourceSnapshot<String, BookCardContent>()
        for shelf in shelves {
            snapshot.appendSections([shelf.id])
            snapshot.appendItems(shelf.cards, toSection: shelf.id)
        }
        dataSource?.apply(snapshot, animatingDifferences: false)

        emptyLabel.text = emptyText
        emptyLabel.isHidden = emptyText == nil
    }
}
