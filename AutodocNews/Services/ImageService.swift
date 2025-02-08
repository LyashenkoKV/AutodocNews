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

    private let cache = NSCache<NSString, UIImage>()
    private let networkService: NetworkServiceProtocol
    private let imageDownsampleProcessor: ImageDownsampleProcessorProtocol

    init(networkService: NetworkServiceProtocol = NetworkService(),
         imageDownsampleProcessor: ImageDownsampleProcessorProtocol = ImageDownsampleProcessor()
    ) {
        self.networkService = networkService
        self.imageDownsampleProcessor = imageDownsampleProcessor
    }

    func loadImage(from url: URL, targetSize: CGSize) async -> UIImage? {
        let cacheKey = url.absoluteString as NSString

        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }

        let scale = await MainActor.run { UIScreen.main.scale }

        do {
            let (data, response) = try await networkService.fetchData(from: url)

            guard let mimeType = (response as? HTTPURLResponse)?.mimeType, mimeType.hasPrefix("image") else {
                Logger.shared.log(.debug,
                                  message: "Invalid MIME type:",
                                  metadata: ["⚠️": String(describing: (response as? HTTPURLResponse)?.mimeType)]
                )
                return nil
            }

            let image = try imageDownsampleProcessor.downsample(data: data,
                                                                to: targetSize,
                                                                scale: scale)

            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            Logger.shared.log(
                .error,
                message: "Failed to load image:",
                metadata: ["❌": error.localizedDescription]
            )
        }
        return nil
    }
}
