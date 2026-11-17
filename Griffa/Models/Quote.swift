//
//  Quote.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import Foundation
import SwiftData

@Model
class Quote {
    var id = UUID()
    var textQuote: String
    var book: Book
    var date: Date = Date()
    init(id: UUID, textQuote: String, book: Book, date: Date) {
        self.id = id
        self.textQuote = textQuote
        self.book = book
        self.date = date
    }
}
