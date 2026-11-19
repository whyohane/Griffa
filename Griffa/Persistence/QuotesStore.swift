//
//  QuotesStore.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 18/11/26.
//

import Foundation

/// Quotes salvas pelo usuário. As telas e ViewModels conhecem só este protocolo, não o SwiftData.
protocol QuotesStore {
    /// Todas as quotes, da mais recente para a mais antiga.
    func allQuotes() throws -> [Quote]

    /// Salva uma quote nova e avisa com `.quotesDidChange`.
    func add(_ quote: Quote) throws
}

extension Notification.Name {

    static let quotesDidChange = Notification.Name("quotesDidChange")
}
