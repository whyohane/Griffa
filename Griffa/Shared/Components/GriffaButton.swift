//
//  GriffaButton.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//

import UIKit

final class GriffaButton: UIButton {
    
    init(title: String) {
        
        super.init(frame: .zero)
        configure(title: title)
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }
    
    private func configure(title: String) {
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = Fonts.button()
            return outgoing
        }
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 24, bottom: 19, trailing: 24)
        configuration.baseBackgroundColor = UIColor(resource: .primaryPurple)
        self.configuration = configuration

        // Versão "desabilitada": mesma cor com opacidade reduzida
        configurationUpdateHandler = { button in
            var updated = button.configuration
            let purple = UIColor(resource: .primaryPurple)
            updated?.baseBackgroundColor = button.isEnabled ? purple : purple.withAlphaComponent(0.4)
            button.configuration = updated
        }

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
    }
    
}

#Preview {
    GriffaButton(title: "Continue")
}
