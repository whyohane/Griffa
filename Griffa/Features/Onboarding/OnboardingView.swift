//
//  OnboardingView.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//

import UIKit

final class OnboardingView: UIView {
    
    private let mascotImageView: UIImageView = {
        let mascotView = UIImageView(image: UIImage(resource: .catinho))
        mascotView.contentMode = .scaleAspectFit
        mascotView.clipsToBounds = true
        mascotView.translatesAutoresizingMaskIntoConstraints = false
        return mascotView
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .background))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let appNameImageView: UIImageView = {
        let appNameView = UIImageView(image: UIImage(resource: .welcome))
        appNameView.contentMode = .scaleAspectFit
        appNameView.translatesAutoresizingMaskIntoConstraints = false
        return appNameView
    }()
    
    private let formContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabelView: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "What's your first name?"
        titleLabel.textColor = .label
        titleLabel.font = Fonts.bodyMedium()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    private let nameTextField = GriffaTextField (
        label: "Type here your first name...",
        keyboardType: .default
    )

    private let continueButton = GriffaButton (
        title: "Continue"
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupBackground()
        setupFormContainer()
        setupAppName()
        setupMascot()
        setupTitleLabel()
        setupNameTextField()
        setupButton()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    // MARK: - Interface com o controller

    var onNameChange: ((String) -> Void)?

    var onContinue: (() -> Void)?

    var name: String {
        nameTextField.text ?? ""
    }

    func setContinueEnabled(_ isEnabled: Bool) {
        continueButton.isEnabled = isEnabled
    }

    private func setupActions() {
        // Começa desabilitado: o campo está vazio
        continueButton.isEnabled = false

        nameTextField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onNameChange?(name)
        }, for: .editingChanged)

        continueButton.addAction(UIAction { [weak self] _ in
            self?.onContinue?()
        }, for: .touchUpInside)
    }

    private func setupBackground() {
        // Índice 0: fica atrás de qualquer subview adicionada depois
        insertSubview(backgroundImageView, at: 0)
        
        let imageSize = UIImage(resource: .background).size
        let aspectRatio = imageSize.height / imageSize.width
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.heightAnchor.constraint(
                equalTo: backgroundImageView.widthAnchor,
                multiplier: aspectRatio
            )
        ])
    }
    
    private func setupAppName() {
        addSubview(appNameImageView)
        
        NSLayoutConstraint.activate([
            appNameImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            appNameImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -70),
            appNameImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            appNameImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupMascot() {
        addSubview(mascotImageView)

        let imageSize = UIImage(resource: .catinho).size
        let aspectRatio = imageSize.height / imageSize.width

        NSLayoutConstraint.activate([
            mascotImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mascotImageView.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -45),
            mascotImageView.widthAnchor.constraint(equalToConstant: 82),
            mascotImageView.heightAnchor.constraint(
                equalTo: mascotImageView.widthAnchor,
                multiplier: aspectRatio
            )
        ])
    }

    private func setupFormContainer() {
        
        addSubview(formContainerView)
        
        NSLayoutConstraint.activate([
            formContainerView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
            formContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            formContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            formContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupTitleLabel() {
        
        addSubview(titleLabelView)
        
        NSLayoutConstraint.activate([
            titleLabelView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabelView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            titleLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20)
        ])
    }
    
    private func setupNameTextField() {
        addSubview(nameTextField)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: titleLabelView.bottomAnchor, constant: 15),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    private func setupButton() {
        
        addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}

#Preview {
    OnboardingView()
}
