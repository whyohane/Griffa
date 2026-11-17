//
//  LabeledDivider.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import UIKit

final class LabeledDivider: UIView {

    private let label = UILabel()
    private let leadingLine = UIView()
    private let trailingLine = UIView()

    private let lineSpacing: CGFloat = 12

    init(text: String) {
        super.init(frame: .zero)
        configure(text: text)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) não é usado")
    }

    private func configure(text: String) {
        translatesAutoresizingMaskIntoConstraints = false

        label.text = text
        label.font = Fonts.body()
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        [leadingLine, trailingLine].forEach {
            $0.backgroundColor = .separator
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),

            leadingLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingLine.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -lineSpacing),
            leadingLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            leadingLine.heightAnchor.constraint(equalToConstant: 1),

            trailingLine.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: lineSpacing),
            trailingLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            trailingLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

#Preview {
    LabeledDivider(text: "Can't find your book?")
}
