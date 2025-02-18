//
//  NewsDetailsViewModel.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import UIKit
import Combine

@MainActor
final class NewsDetailsViewModel {

    // MARK: - Published Properties

    @Published private(set) var state: State<[UIImage]> = .idle

    // MARK: - Private Properties

    private let newsData: News
    private let imageService: ImageServiceProtocol
    private var isLoading = false

    // MARK: - Properties

    var images: [UIImage] {
        if case .loaded(let images) = state {
            return images
        }
        return []
    }

    var news: News { newsData }

    // MARK: - Init

    init(news: News,
         imageService: ImageServiceProtocol = ImageService()
    ) {
        self.newsData = news
        self.imageService = imageService
    }

    // MARK: - Parse Method

    private func parseImageURLComponents() -> (base: String, ext: String)? {
        guard let urlString = newsData.titleImageUrl,
              !urlString.isEmpty else {
            return nil
        }

        let pattern = "(.*_)(\\d+)(\\.[a-zA-Z]+)$"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }

        let nsString = urlString as NSString
        let results = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: nsString.length))

        guard let match = results.first, match.numberOfRanges == 4 else {
            return nil
        }

        let base = nsString.substring(with: match.range(at: 1))
        let ext = nsString.substring(with: match.range(at: 3))
        return (base, ext)
    }

    // MARK: - Fetch Method

    func fetchImages(with targetSize: CGSize) async {
        if isLoading { return }
        isLoading = true

        guard let (baseUrl, fileExtension) = parseImageURLComponents() else {
            isLoading = false
            return
        }

        var currentImages = images
        state = .loading

        var newImages: [UIImage] = []
        var index = currentImages.count + 1

        while index <= currentImages.count + 10 {
            let urlString = "\(baseUrl)\(index)\(fileExtension)"
            guard let url = URL(string: urlString) else { break }

            if let image = await imageService.loadImage(from: url, targetSize: targetSize) {
                newImages.append(image)
                index += 1
            } else {
                break
            }
        }

        currentImages.append(contentsOf: newImages)
        state = .loaded(currentImages)
        isLoading = false
    }
}
