//
//  NewsViewModel.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import Foundation
import Combine

@MainActor
final class NewsViewModel {
    @Published var newsItems: [News] = []
    @Published var totalCount = 0

    private var currentPage = 1
    private var isFetching = false

    func loadNews() {
        guard !isFetching else { return }
        isFetching = true

        Task {
            do {
                let newsResponse = try await NetworkManager.shared.fetchNews(page: currentPage)
                self.newsItems.append(contentsOf: newsResponse.news)
                self.totalCount = newsResponse.totalCount
                self.currentPage += 1
                self.isFetching = false
            } catch {
                Logger.shared.log(
                    .error,
                    message: "Error loading news:",
                    metadata: ["❌": error.localizedDescription]
                )
                self.isFetching = false
            }
        }
    }
}
