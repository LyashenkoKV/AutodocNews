//
//  NewsListViewController.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit
import Combine

final class NewsListViewController: UIViewController {

    private let viewModel = NewsViewModel()
    private var cancellables = Set<AnyCancellable>()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(NewsCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    var router: Router?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadNews()
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("News", comment: "Autodoc News")
        view.setupView(collectionView)
    }
}

// MARK: - Layout

extension NewsListViewController {

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(300))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(300))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }

}

// MARK: - Binding

extension NewsListViewController {

    private func bindViewModel() {
        viewModel.$newsItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDelegate

extension NewsListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let news = viewModel.newsItems[indexPath.row]
        router?.showNewsDetail(with: news)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height * 2 {
            viewModel.loadNews()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension NewsListViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.newsItems.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: NewsCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let news = viewModel.newsItems[indexPath.row]
        cell.configure(with: news)
        return cell
    }
}
