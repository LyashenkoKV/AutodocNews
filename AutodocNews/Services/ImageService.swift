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

    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()

    private var failedURLs = Set<String>()
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

        return await withTaskGroup(of: UIImage?.self) { group in
            group.addTask {
                do {
                    if Task.isCancelled { return nil }

                    let (data, response) = try await self.networkService.fetchData(from: url)

                    if Task.isCancelled { return nil }

                    guard let mimeType = (response as? HTTPURLResponse)?.mimeType, mimeType.hasPrefix("image") else {
                        Logger.shared.log(.debug, message: "Invalid MIME type: \(String(describing: (response as? HTTPURLResponse)?.mimeType))")
                        return nil
                    }

                    let image = try self.imageDownsampleProcessor.downsample(data: data, to: targetSize, scale: scale)

                    if Task.isCancelled { return nil }

                    self.cache.setObject(image, forKey: cacheKey)
                    return image
                } catch is CancellationError {
                    Logger.shared.log(.debug, message: "Task cancelled for \(url)")
                    return nil
                } catch {
                    Logger.shared.log(.error, message: "Image load failed: \(error.localizedDescription)")
                    return nil
                }
            }

            for await result in group {
                return result
            }

            return nil
        }
    }
}
