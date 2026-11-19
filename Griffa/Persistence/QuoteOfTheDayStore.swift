//
//  QuoteOfTheDayStore.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 19/11/26.
//

import Foundation

/// Qual quote foi escolhida e em que dia.
struct QuoteOfTheDay: Codable, Equatable {
    let date: Date
    let quoteID: UUID
}

/// Guarda a escolha da quote do dia, para ela não mudar a cada vez que a Summary aparece.
protocol QuoteOfTheDayStore {

    var current: QuoteOfTheDay? { get }
    func save(_ quoteOfTheDay: QuoteOfTheDay)
}

final class UserDefaultsQuoteOfTheDayStore: QuoteOfTheDayStore {

    private let defaults: UserDefaults
    private let key = "quoteOfTheDay"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var current: QuoteOfTheDay? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(QuoteOfTheDay.self, from: data)
    }

    func save(_ quoteOfTheDay: QuoteOfTheDay) {
        guard let data = try? JSONEncoder().encode(quoteOfTheDay) else { return }
        defaults.set(data, forKey: key)
    }
}
