//
//  SummaryViewModel.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//
import Foundation

final class SummaryViewModel {

    private let store: UserProfileStore

    init(store: UserProfileStore) {
        self.store = store
    }

    /// Saudação com o nome salvo no onboarding.
    var greeting: String {
        guard let name = store.profile?.name else { return "Hello!" }
        return "Hello, \(name)!"
    }
}
