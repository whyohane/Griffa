//
//  UISegmentedControl+Griffa.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import UIKit

extension UISegmentedControl {
    
    func applyGriffaStyle() {
        backgroundColor = UIColor(resource: .backgroundStatusBar)
        selectedSegmentTintColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(resource: .primaryPurple) : .white
        }
        setTitleTextAttributes([.font: Fonts.body(), .foregroundColor: UIColor.label], for: .normal)
        setTitleTextAttributes([.font: Fonts.bodyMedium(), .foregroundColor: UIColor.label], for: .selected)
    }
}
