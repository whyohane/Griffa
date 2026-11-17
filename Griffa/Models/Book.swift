//
//  Book.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import Foundation
import SwiftData

@Model
class Book {
    var id = UUID()
    var googleID: String?
    var title: String
    var author: String
    var numberOfPages: Int
    var coverURL: URL?
    @Attribute(.externalStorage) var coverData: Data?
    var status: ReadingStatus = ReadingStatus.wantToRead
    var currentPage: Int = 0
    var addedAt: Date = Date()
    var quotes: [Quote] = []

    init(
        id: UUID = UUID(),
        googleID: String? = nil,
        title: String,
        author: String,
        numberOfPages: Int,
        coverURL: URL? = nil,
        coverData: Data? = nil,
        status: ReadingStatus = .wantToRead,
        currentPage: Int = 0,
        addedAt: Date = Date(),
        quotes: [Quote] = []
    ) {
        self.id = id
        self.googleID = googleID
        self.title = title
        self.author = author
        self.numberOfPages = numberOfPages
        self.coverURL = coverURL
        self.coverData = coverData
        self.status = status
        self.currentPage = currentPage
        self.addedAt = addedAt
        self.quotes = quotes
    }
}
