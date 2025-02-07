//
//  NewsDetailsViewModel.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import UIKit
import Combine

@MainActor
final class NewsDetailsViewModel: ObservableObject {

    private let newsData: News

    var news: News { newsData }

    @Published var images: [UIImage] = []

    init(news: News) {
        self.newsData = news
    }

    func fetchImages(with targetSize: CGSize) async {
        guard let (baseUrl, fileExtension) = parseImageURLComponents() else { return }

        var index = 1
        while index <= 10 {
            let urlString = "\(baseUrl)\(index)\(fileExtension)"
            guard let url = URL(string: urlString) else { break }

            if let image = await ImageDownsampleService.shared.loadImage(from: url, targetSize: targetSize) {
                images.append(image)
                index += 1
            } else {
                break
            }
        }
    }

    private func parseImageURLComponents() -> (base: String, ext: String)? {
        guard let urlString = newsData.titleImageUrl, !urlString.isEmpty else { return nil }

        if let underscore = urlString.lastIndex(of: "_"),
           let dot = urlString.lastIndex(of: ".") {
            let base = String(urlString[..<underscore]) + "_"
            let ext = String(urlString[dot...])
            return (base, ext)
        }
        return nil
    }
}
