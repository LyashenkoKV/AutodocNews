//
//  ImageDownsampleService.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit
import ImageIO

final class ImageDownsampleService {

    static let shared = ImageDownsampleService()

    private let cache = NSCache<NSString, UIImage>()

    private func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData,
                                                            imageSourceOptions) else { return nil }

        let maxDimension = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ] as CFDictionary

        guard let downsampleImage = CGImageSourceCreateThumbnailAtIndex(
            imageSource,
            0,
            downsampleOptions
        ) else {
            return nil
        }

        return UIImage(cgImage: downsampleImage)
    }

    func loadImage(from url: URL, targetSize: CGSize) async -> UIImage? {
        let cacheKey = url.absoluteString as NSString

        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }

        let scale = await MainActor.run { UIScreen.main.scale }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = downsample(imageData: data, to: targetSize, scale: scale) {
                cache.setObject(image, forKey: cacheKey)
                return image
            }
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
