//
//  OnboardingViewController.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//
import UIKit

final class OnboardingViewController: UIViewController {

    /// Chamado quando o usuário conclui o onboarding.
    var onFinish: (() -> Void)?

    private let onboardingView = OnboardingView()
    private let viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    override func loadView() {
        view = onboardingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Read Books Page"
        setupKeyboardDismissal()
        bindView()
    }

    // MARK: - View ↔ ViewModel

    private func bindView() {
        onboardingView.onNameChange = { [weak self] name in
            guard let self else { return }
            onboardingView.setContinueEnabled(viewModel.isValid(name: name))
        }

        onboardingView.onContinue = { [weak self] in
            guard let self, viewModel.saveProfile(name: onboardingView.name) else { return }
            onFinish?()
        }
    }

    // MARK: - Teclado

    /// Fecha o teclado ao tocar fora do campo ou ao arrastar a tela.
    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        // Não consome o toque: botão e campo continuam respondendo normalmente
        [tap, pan].forEach {
            $0.cancelsTouchesInView = false
            view.addGestureRecognizer($0)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

#Preview {
    OnboardingViewController(viewModel: OnboardingViewModel(store: UserDefaultsProfileStore()))
}
