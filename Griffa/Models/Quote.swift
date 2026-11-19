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
    var page: Int?
    var thoughts: String?
    var date: Date = Date()
    init(
        id: UUID = UUID(),
        textQuote: String,
        book: Book,
        page: Int? = nil,
        thoughts: String? = nil,
        date: Date = Date()
    ) {
        self.id = id
        self.textQuote = textQuote
        self.book = book
        self.page = page
        self.thoughts = thoughts
        self.date = date
    }
}
