//
//  SceneDelegate.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//
import UIKit
import SwiftData

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let profileStore: UserProfileStore = UserDefaultsProfileStore()
    private let booksService: BooksService = GoogleBooksService()

    // Banco local (SwiftData) com os livros e as quotes do usuário
    private let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Book.self, Quote.self)
        } catch {
            fatalError("Não foi possível criar o armazenamento local: \(error)")
        }
    }()
    private lazy var booksStore: BooksStore = SwiftDataBooksStore(container: modelContainer)

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = initialViewController()
        window.makeKeyAndVisible()
        self.window = window
    }

    // MARK: - Fluxo inicial

    private func initialViewController() -> UIViewController {
        profileStore.profile == nil ? makeOnboarding() : makeMainInterface()
    }

    private func makeOnboarding() -> UIViewController {
        let viewModel = OnboardingViewModel(store: profileStore)
        let controller = OnboardingViewController(viewModel: viewModel)
        controller.onFinish = { [weak self] in
            self?.showMainInterface()
        }
        return controller
    }

    private func makeMainInterface() -> UIViewController {
        MainTabBarController(profileStore: profileStore, booksService: booksService, booksStore: booksStore)
    }

    private func showMainInterface() {
        guard let window else { return }
        let tabBarController = makeMainInterface()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = tabBarController
        }
    }
}
