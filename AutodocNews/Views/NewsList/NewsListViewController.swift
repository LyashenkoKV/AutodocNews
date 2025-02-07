//
//  NewsListViewController.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit
import Combine

final class NewsListViewController: UIViewController {

    var router: Router?

    private let viewModel = NewsViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let refreshControl = UIRefreshControl()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(NewsCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    private lazy var loading: UIActivityIndicatorView = {
        let activityIndicator  = UIActivityIndicatorView()
        activityIndicator.center = view.center
        activityIndicator.style = .large
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadNews()
        setupViews()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.setupView(collectionView)
    }

    func startLoading() {
        loading.startAnimating()
    }

    func stopLoading() {
        loading.stopAnimating()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    func setupViews() {
        view.setupView(loading)
        collectionView.setupView(refreshControl)
        loading.constraintCenters(to: view)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }

    @objc func refresh(_ sender: AnyObject) {
        viewModel.loadNews()
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
                self?.stopLoading()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }

                if self.refreshControl.isRefreshing {
                    return
                }

                if isLoading {
                    self.startLoading()
                } else {
                    self.stopLoading()
                }
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
        guard indexPath.row < viewModel.newsItems.count else {
            return
        }
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

        guard indexPath.row < viewModel.newsItems.count else {
            return cell
        }

        let news = viewModel.newsItems[indexPath.row]
        cell.configure(with: news)
        return cell
    }
}
