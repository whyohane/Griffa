//
//  SwiftDataQuotesStore.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 18/11/26.
//

import Foundation
import SwiftData

final class SwiftDataQuotesStore: QuotesStore {

    // O store guarda o container: o contexto não o mantém vivo sozinho
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init(container: ModelContainer) {
        self.container = container
    }

    func add(_ quote: Quote) throws {
        context.insert(quote)
        try context.save()
        NotificationCenter.default.post(name: .quotesDidChange, object: nil)
    }

    func allQuotes() throws -> [Quote] {
        let descriptor = FetchDescriptor<Quote>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try context.fetch(descriptor)
    }
}
