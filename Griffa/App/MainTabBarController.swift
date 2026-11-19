//
//  MainTabBarController.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//
import UIKit

final class MainTabBarController: UITabBarController {

    private let profileStore: UserProfileStore
    private let booksService: BooksService
    private let booksStore: BooksStore
    private let quotesStore: QuotesStore

    init(
        profileStore: UserProfileStore,
        booksService: BooksService,
        booksStore: BooksStore,
        quotesStore: QuotesStore
    ) {
        self.profileStore = profileStore
        self.booksService = booksService
        self.booksStore = booksStore
        self.quotesStore = quotesStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        setupTabs()
    }

    private func setupTabBarAppearance() {
        tabBar.tintColor = UIColor(resource: .primaryPurple)
    }

    private func setupTabs() {
        let summary = makeTab(
            root: SummaryViewController(viewModel: SummaryViewModel(store: profileStore, booksStore: booksStore)),
            title: "Summary",
            systemImage: "book.fill"
        )
        let books = makeTab(
            root: BooksViewController(
                viewModel: BooksViewModel(store: booksStore),
                booksService: booksService,
                booksStore: booksStore
            ),
            title: "Books",
            systemImage: "books.vertical.fill"
        )
        let quotes = makeTab(
            root: QuotesViewController(
                viewModel: QuotesViewModel(store: quotesStore),
                booksStore: booksStore,
                quotesStore: quotesStore
            ),
            title: "Quotes",
            systemImage: "bookmark.fill"
            )
        
        setViewControllers([summary, books, quotes], animated: true)
    }

    private func makeTab(root: UIViewController, title: String, systemImage: String) -> UINavigationController {
        let navigation = UINavigationController(rootViewController: root)
        navigation.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: systemImage),
            selectedImage: nil
        )
        return navigation
    }
    
    
}
