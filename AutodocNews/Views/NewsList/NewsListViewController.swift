//
//  NewsListViewController.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit
import Combine

final class NewsListViewController: UIViewController {

    // MARK: - Properties

    var router: Router?

    // MARK: - Private Properties

    private let viewModel = NewsViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let refreshControl = UIRefreshControl()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        return collectionView
    }()

    private lazy var loading: UIActivityIndicatorView = {
        let activityIndicator  = UIActivityIndicatorView()
        activityIndicator.center = view.center
        activityIndicator.style = .large
        return activityIndicator
    }()

    // MARK: - life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        bindViewModel()
        viewModel.loadNews()
        setupViews()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.setupView(collectionView)
    }

    private func configureCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(NewsCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
    }

    // MARK: - Methods

    func setupViews() {
        view.setupView(loading)
        collectionView.setupView(refreshControl)
        loading.constraintCenters(to: view)
        refreshControl.addTarget(self,
                                 action: #selector(self.refresh(_:)),
                                 for: .valueChanged)
    }

    @objc private func refresh(_ sender: AnyObject) {
        viewModel.loadNews()
    }
}

// MARK: - Load animation

extension NewsListViewController {

    private func startLoading() {
        loading.startAnimating()
    }

    private func stopLoading() {
        loading.stopAnimating()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
}

// MARK: - Layout

extension NewsListViewController {

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(Heights.Height600x300))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(Heights.Height600x300))
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
            .sink { [weak self] newItems in
                guard let self else { return }

                let oldCount = self.collectionView.numberOfItems(inSection: 0)
                let newCount = newItems.count

                self.collectionView.performBatchUpdates {
                    let indexPaths = (oldCount..<newCount).map {
                        IndexPath(item: $0, section: 0)
                    }
                    self.collectionView.insertItems(at: indexPaths)
                } completion: { _ in
                    self.stopLoading()
                }
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }

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

extension NewsListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]) {
            if indexPaths.contains(where: { $0.row >= viewModel.newsItems.count - 1 }) && !viewModel.isLoading {
                viewModel.loadNews()
            }
        }
}
