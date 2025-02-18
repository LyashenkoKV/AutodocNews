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

    @Published private(set) var state: State<(newsItems: [News], totalCount: Int, currentPage: Int)> = .idle

    // MARK: - Property

    var newsItems: [News] {
        if case .loaded(let data) = state {
            return data.newsItems
        }
        return []
    }

    // MARK: - Setup Methods

    func loadNews() {
        if case .loading = state { return }

        if case .loaded(let data) = state, data.totalCount != 0, data.newsItems.count >= data.totalCount {
            return
        }

        var previousItems: [News] = []
        var currentPage = 1
        if case .loaded(let data) = state {
            previousItems = data.newsItems
            currentPage = data.currentPage
        }

        state = .loading

        Task {
            do {
                let newsResponse = try await NetworkManager.shared.fetchNews(page: currentPage)
                let newItems = previousItems + newsResponse.news
                state = .loaded((newsItems: newItems,
                                 totalCount: newsResponse.totalCount,
                                 currentPage: currentPage + 1))
            } catch {
                state = .error(error)
            }
        }
    }
}
