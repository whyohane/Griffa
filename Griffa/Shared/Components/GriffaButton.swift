//
//  GriffaButton.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//

import UIKit

final class GriffaButton: UIButton {

    enum Style {
        case filled      // fundo roxo, texto branco
        case outlined    // só a borda roxa, texto roxo
    }

    init(title: String, style: Style = .filled) {

        super.init(frame: .zero)
        configure(title: title, style: style)

    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func configure(title: String, style: Style) {

        let purple = UIColor(resource: .primaryPurple)

        var configuration: UIButton.Configuration
        switch style {
        case .filled:
            configuration = .filled()
            configuration.baseBackgroundColor = purple
        case .outlined:
            configuration = .plain()
            configuration.baseForegroundColor = purple
            configuration.background.strokeColor = purple
            configuration.background.strokeWidth = 2
        }
        configuration.title = title
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = Fonts.button()
            return outgoing
        }
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 24, bottom: 19, trailing: 24)
        self.configuration = configuration

        // Versão "desabilitada": mesma cor com opacidade reduzida
        configurationUpdateHandler = { button in
            var updated = button.configuration
            let color = button.isEnabled ? purple : purple.withAlphaComponent(0.4)
            switch style {
            case .filled:
                updated?.baseBackgroundColor = color
            case .outlined:
                updated?.baseForegroundColor = color
                updated?.background.strokeColor = color
            }
            button.configuration = updated
        }

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
    }

    func setLoading(_ isLoading: Bool) {
        isEnabled = !isLoading
        configuration?.showsActivityIndicator = isLoading
    }

}

#Preview {
    GriffaButton(title: "Continue")
}

#Preview("Outlined") {
    GriffaButton(title: "Add it manually", style: .outlined)
}
