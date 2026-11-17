//
//  ReadingStatus.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import Foundation

/// Em que "estante" o livro está.
enum ReadingStatus: String, Codable, CaseIterable {
    case reading
    case wantToRead
    case read

    var title: String {
        switch self {
        case .reading: "Reading"
        case .wantToRead: "To read"
        case .read: "Finished"
        }
    }
}
