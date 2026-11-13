//
//  UserProfileStore.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 13/11/26.
//

import Foundation

protocol UserProfileStore {
    
    var profile: UserProfile? { get }
    func save(_ profile: UserProfile)
    
}

final class UserDefaultsProfileStore: UserProfileStore {

    private let defaults: UserDefaults
    private let key = "userProfile"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var profile: UserProfile? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    func save(_ profile: UserProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: key)
    }
}
