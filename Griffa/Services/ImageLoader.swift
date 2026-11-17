//
//  ImageLoader.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 17/11/26.
//

import UIKit

// Baixa os bytes da capa para serem guardados junto com o livro.
protocol CoverDataLoading {
    // `nil` se o download falhar ou os dados não forem uma imagem válida.
    func coverData(for url: URL) async -> Data?
}

final class ImageLoader {

    static let shared = ImageLoader()

    private let session: URLSession
    private let cache = NSCache<NSURL, UIImage>()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func image(for url: URL) async -> UIImage? {
        if let cached = cache.object(forKey: url as NSURL) { return cached }

        guard let (data, _) = try? await session.data(from: url),
              let image = UIImage(data: data) else { return nil }

        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}

extension ImageLoader: CoverDataLoading {

    func coverData(for url: URL) async -> Data? {
        guard let (data, _) = try? await session.data(from: url),
              UIImage(data: data) != nil else { return nil }
        return data
    }
}
