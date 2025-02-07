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
    @Published var isLoading = false

    private var currentPage = 1
    private var isFetching = false

    func loadNews() {
        guard !isFetching, (newsItems.count < totalCount || totalCount == 0) else { return }
        isFetching = true
        isLoading = true

        Task {
            do {
                let newsResponse = try await NetworkManager.shared.fetchNews(page: currentPage)
                let newItems = newsResponse.news

                await MainActor.run {
                    let updatedItems = self.newsItems + newItems
                    self.newsItems = updatedItems
                    self.totalCount = newsResponse.totalCount
                    self.currentPage += 1
                }
            } catch {
                Logger.shared.log(.error,
                                  message: "Error loading news:",
                                  metadata: ["❌": error.localizedDescription])
            }
            await MainActor.run {
                isFetching = false
                isLoading = false
            }
        }
    }
}
