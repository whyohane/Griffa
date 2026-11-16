//
//  Fonts.swift
//  Griffa
//

import UIKit

enum Fonts {

    static func timeLabel() -> UIFont {
        scaled("ElmsSans-Bold", size: 12, style: .body)
    }
    
    static func cardQuoteLabel() -> UIFont {
        scaled("ElmsSans-SemiBold", size: 12, style: .body)
    }

    static func body() -> UIFont {
        scaled("ElmsSans-Regular", size: 14, style: .body)
    }

    static func bodyMedium() -> UIFont {
        scaled("ElmsSans-Medium", size: 14, style: .body)
    }

    static func quote() -> UIFont {
        scaled("SourceSerif4-SemiBoldItalic", size: 16, style: .body)
    }

    static func headline() -> UIFont {
        scaled("ElmsSans-SemiBold", size: 14, style: .headline)
    }

    static func title() -> UIFont {
        scaled("Quicksand-Bold", size: 28, style: .title1)
    }
    
    static func title2() -> UIFont {
        scaled("ElmsSans-Bold", size: 14, style: .title2)
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
