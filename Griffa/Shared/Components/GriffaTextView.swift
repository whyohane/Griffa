//
//  GriffaTextView.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 18/11/26.
//

import UIKit

final class GriffaTextView: UITextView {

    var onTextChange: ((String) -> Void)?

    var maxLength: Int?

    private let placeholderLabel = UILabel()

    private let insets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

    init(placeholder: String, maxLength: Int? = nil) {
        super.init(frame: .zero, textContainer: nil)
        self.maxLength = maxLength
        configure()
        setupPlaceholder(placeholder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func configure() {
        font = Fonts.body()
        adjustsFontForContentSizeCategory = true
        textColor = .label
        tintColor = UIColor(resource: .primaryPurple)
        backgroundColor = UIColor(resource: .backgroundTextField)
        layer.cornerRadius = 12

        textContainerInset = insets
        textContainer.lineFragmentPadding = 0
        autocorrectionType = .default
        delegate = self

        updateAppearance()

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
            self.updateAppearance()
        }

        translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupPlaceholder(_ text: String) {
        placeholderLabel.text = text
        placeholderLabel.font = Fonts.body()
        placeholderLabel.adjustsFontForContentSizeCategory = true
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor, constant: insets.left),
            placeholderLabel.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor, constant: -insets.right)
        ])
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
}

extension GriffaTextView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        // Texto colado acima do limite é cortado
        if let maxLength, text.count > maxLength {
            text = String(text.prefix(maxLength))
        }
        placeholderLabel.isHidden = !text.isEmpty
        onTextChange?(text)
    }
}

#Preview {
    let textView = GriffaTextView(placeholder: "Write what it reminded you of...")
    textView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    return textView
}
