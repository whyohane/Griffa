//
//  MainTabBarController.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//
import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let summary = makeTab(
            root: SummaryViewController(),
            title: "Summary",
            systemImage: "book.fill"
        )
        let books = makeTab(
            root: BooksViewController(),
            title: "Books",
            systemImage: "books.vertical.fill"
        )
        let quotes = makeTab(
            root: QuotesViewController(),
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
