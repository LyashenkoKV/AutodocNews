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

    // MARK: - Published Properties

    @Published private(set) var newsItems: [News] = []
    @Published private(set) var totalCount = 0
    @Published private(set) var isLoading = false

    // MARK: - Private Properties

    private var currentPage = 1
    private var isFetching = false

    // MARK: - Setup Methods

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
