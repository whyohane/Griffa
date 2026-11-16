//
//  TextField.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import UIKit

final class GriffaTextField: UITextField {

    private let contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    init(label: String, keyboardType: UIKeyboardType = .default) {

        super.init(frame: .zero)
        configure(label: label, keyboardType: keyboardType)

    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func configure(label: String, keyboardType: UIKeyboardType) {

        placeholder = label
        self.keyboardType = keyboardType
        font = Fonts.body()
        adjustsFontForContentSizeCategory = true
        textColor = .label
        tintColor = UIColor(resource: .primaryPurple)

        backgroundColor = .systemBackground
        layer.cornerRadius = 12

        autocorrectionType = .no
        returnKeyType = .done
        clearButtonMode = .whileEditing

        updateAppearance()

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
            self.updateAppearance()
        }

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
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
        : UIColor(resource: .strokeTextField).cgColor
    }

    // MARK: - Padding interno

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        super.clearButtonRect(forBounds: bounds).offsetBy(dx: -contentInsets.right + 8, dy: 0)
    }

}

#Preview {
    GriffaTextField(label: "Type here your first name...")
}
