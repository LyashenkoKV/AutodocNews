//
//  AppRouter.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit

protocol Router {
    var navigationController: UINavigationController? { get set }
    func showNewsDetail(with news: News)
}

final class AppRouter: @preconcurrency Router {
    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    @MainActor func showNewsDetail(with news: News) {
        let detailVC = NewsDetailViewController(news: news)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
