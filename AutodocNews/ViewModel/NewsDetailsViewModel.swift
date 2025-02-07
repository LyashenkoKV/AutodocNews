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
        guard let urlString = newsData.titleImageUrl, !urlString.isEmpty else { return }

        if let underscore = urlString.range(of: "_", options: .backwards),
           let dot = urlString.range(of: ".", options: .backwards) {
            let baseUrl = String(urlString[..<underscore.lowerBound]) + "_"
            let fileExtension = String(urlString[dot.lowerBound...])

            var index = 1

            while true {
                let fullUrlString = baseUrl + "\(index)" + fileExtension

                guard let url = URL(string: fullUrlString) else { break }

                if let image = await ImageDownsampleService.shared.loadImage(from: url, targetSize: targetSize) {
                    images.append(image)
                    index += 1
                } else {
                    break
                }
            }
        } else {
            if let url = URL(string: urlString),
               let image = await ImageDownsampleService.shared.loadImage(from: url, targetSize: targetSize) {
                images.append(image)
            }
        }
    }
}
