//
//  NewsDetailViewController.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit

final class NewsDetailViewController: UIViewController {

    // MARK: - Private Properties

    private let news: News

    // MARK: - Init

    init(news: News) {
        self.news = news
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("News Detail", comment: "Детали")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lyfecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground


    }
}
