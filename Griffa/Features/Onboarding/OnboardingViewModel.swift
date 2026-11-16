//
//  OnboardingViewModel.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//

import Foundation

final class OnboardingViewModel {

    private let store: UserProfileStore

    init(store: UserProfileStore) {
        self.store = store
    }

    /// O nome só é válido se tiver algum caractere além de espaços.
    func isValid(name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Salva o perfil. Retorna `false` se o nome for inválido e nada foi salvo.
    func saveProfile(name: String) -> Bool {
        guard isValid(name: name) else { return false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        store.save(UserProfile(name: trimmedName))
        return true
    }
}
