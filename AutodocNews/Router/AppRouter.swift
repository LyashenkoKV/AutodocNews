//
//  AppRouter.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit

@MainActor  protocol Router {
    var navigationController: UINavigationController? { get set }
    func showNewsDetail(with news: News)
}

@MainActor final class AppRouter: Router {
    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func showNewsDetail(with news: News) {
        let detailVC = NewsDetailViewController(news: news)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
