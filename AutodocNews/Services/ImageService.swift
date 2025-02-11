//
//  ImageDownsampleService.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit
import ImageIO

protocol ImageServiceProtocol {
    func loadImage(from url: URL, targetSize: CGSize) async -> UIImage?
}

final class ImageService: ImageServiceProtocol {

    // MARK: - Private Properties

    private let cache = NSCache<NSString, UIImage>()
    private let networkService: NetworkServiceProtocol
    private let imageDownsampleProcessor: ImageDownsampleProcessorProtocol

    // MARK: - Init

    init(networkService: NetworkServiceProtocol = NetworkService(),
         imageDownsampleProcessor: ImageDownsampleProcessorProtocol = ImageDownsampleProcessor()
    ) {
        self.networkService = networkService
        self.imageDownsampleProcessor = imageDownsampleProcessor
    }

    // MARK: - Load Image Method

    func loadImage(from url: URL, targetSize: CGSize) async -> UIImage? {
        let cacheKey = url.absoluteString as NSString

        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }

        let scale = await MainActor.run { UIScreen.main.scale }

        var attempts = 3

        while attempts > 0 {
            do {
                let (data, response) = try await networkService.fetchData(from: url)

                guard let mimeType = (response as? HTTPURLResponse)?.mimeType,
                      mimeType.hasPrefix("image") else {
                    Logger.shared.log(.debug, message: "Invalid MIME type:",
                                      metadata: ["⚠️": String(describing: (response as? HTTPURLResponse)?.mimeType)])
                    return nil
                }

                let image = try imageDownsampleProcessor.downsample(data: data, to: targetSize, scale: scale)

                cache.setObject(image, forKey: cacheKey)
                return image
            } catch {
                Logger.shared.log(.error, message: "Image load failed, attempts left: \(attempts - 1)",
                                  metadata: ["❌": error.localizedDescription])
                attempts -= 1

                if attempts == 0 {
                    return nil
                }
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
        }

        return nil
    }
}
