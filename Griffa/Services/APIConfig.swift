//
//  APIConfig.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import Foundation

enum APIConfig {

    static var googleBooksAPIKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "GoogleBooksAPIKey") as? String,
              !value.isEmpty,
              !value.hasPrefix("$(") else { return nil }
        return value
    }
}
