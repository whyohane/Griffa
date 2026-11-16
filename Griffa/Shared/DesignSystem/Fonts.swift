//
//  Fonts.swift
//  Griffa
//

import UIKit

enum Fonts {

    static func body() -> UIFont {
        scaled("ElmsSans-Regular", size: 14, style: .body)
    }

    static func bodyMedium() -> UIFont {
        scaled("ElmsSans-Medium", size: 14, style: .body)
    }

    static func quote() -> UIFont {
        scaled("ElmsSans-Italic", size: 20, style: .title3)
    }

    static func headline() -> UIFont {
        scaled("ElmsSans-SemiBold", size: 17, style: .headline)
    }

    static func title() -> UIFont {
        scaled("ElmsSans-Bold", size: 28, style: .title1)
    }

    static func button() -> UIFont {
        scaled("ElmsSans-SemiBold", size: 14, style: .subheadline)
    }

    private static func scaled(_ name: String, size: CGFloat, style: UIFont.TextStyle) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            assertionFailure("Fonte \(name) não encontrada. Confira o UIAppFonts e o nome PostScript.")
            return .preferredFont(forTextStyle: style)
        }
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
}
