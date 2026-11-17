//
//  GriffaSearchField.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import UIKit

final class GriffaSearchField: UISearchTextField {

    private let height: CGFloat = 48

    private let glassView = UIVisualEffectView()

    init(placeholder prompt: String) {

        super.init(frame: .zero)
        configure(prompt: prompt)

    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func configure(prompt: String) {

        placeholder = prompt
        font = Fonts.body()
        adjustsFontForContentSizeCategory = true
        textColor = .label
        tintColor = UIColor(resource: .primaryPurple)

        borderStyle = .none
        backgroundColor = .clear
        layer.cornerRadius = height / 2
        setupGlassBackground()

        autocorrectionType = .no
        autocapitalizationType = .none
        returnKeyType = .search

        updateAppearance()

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
            self.updateAppearance()
            self.glassView.effect = self.makeGlassEffect()
        }

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    private func setupGlassBackground() {
        glassView.effect = makeGlassEffect()
        glassView.cornerConfiguration = .capsule()
        glassView.isUserInteractionEnabled = false
        glassView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(glassView, at: 0)

        NSLayoutConstraint.activate([
            glassView.topAnchor.constraint(equalTo: topAnchor),
            glassView.bottomAnchor.constraint(equalTo: bottomAnchor),
            glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func makeGlassEffect() -> UIGlassEffect {
        let glass = UIGlassEffect()
        glass.tintColor = UIColor(resource: .backgroundTextField)
        return glass
    }

    override func becomeFirstResponder() -> Bool {
        let didBecome = super.becomeFirstResponder()
        updateAppearance()
        return didBecome
    }

    override func resignFirstResponder() -> Bool {
        let didResign = super.resignFirstResponder()
        updateAppearance()
        return didResign
    }

    private func updateAppearance() {
        let selected = isFirstResponder
        layer.borderWidth = selected ? 2 : 1
        layer.borderColor = selected
            ? UIColor(resource: .primaryPurple).cgColor
        : UIColor.clear.cgColor
    }
}

#Preview {
    GriffaSearchField(placeholder: "Search")
}
