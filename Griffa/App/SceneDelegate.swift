//
//  SceneDelegate.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let profileStore: UserProfileStore = UserDefaultsProfileStore()

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
        profileStore.profile == nil ? makeOnboarding() : MainTabBarController()
    }

    private func makeOnboarding() -> UIViewController {
        let viewModel = OnboardingViewModel(store: profileStore)
        let controller = OnboardingViewController(viewModel: viewModel)
        controller.onFinish = { [weak self] in
            self?.showMainInterface()
        }
        return controller
    }

    private func showMainInterface() {
        guard let window else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = MainTabBarController()
        }
    }
}
