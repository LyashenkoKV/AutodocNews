//
//  ImageProcessor.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 08.02.2025.
//

import UIKit

protocol ImageDownsampleProcessorProtocol {
    func downsample(data: Data, to size: CGSize, scale: CGFloat) throws -> UIImage
}

final class ImageDownsampleProcessor: ImageDownsampleProcessorProtocol {

    func downsample(data: Data, to size: CGSize, scale: CGFloat) throws -> UIImage {
        try autoreleasepool {
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
                throw ImageLoadingError.imageProcessingFailed
            }

            let maxDimension = max(size.width, size.height) * scale
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimension
            ] as CFDictionary

            guard let downsampleImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
                throw ImageLoadingError.imageProcessingFailed
            }

            return UIImage(cgImage: downsampleImage)
        }
    }
}
