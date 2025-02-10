//
//  NewsDetailViewController.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit
import Combine

@MainActor
final class NewsDetailViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: NewsDetailsViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Init

    init(news: News) {
        self.viewModel = NewsDetailsViewModel(news: news)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        bindViewModel()

        let targetSize = CGSize(width: view.bounds.width, height: Heights.Height600x260)
        Task {
            await viewModel.fetchImages(with: targetSize)
        }
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground
        configureTableView()
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(NewsHStackCell.self)
        tableView.register(NewsDateCell.self)
        tableView.register(NewsTextCell.self)
        tableView.register(NewsImagesCell.self)
        view.setupView(tableView)
        tableView.constraintEdges(to: view)
    }

    private func showShareActions() {
        let actionSheet = CustomActionSheetController()
        actionSheet.present(
            in: self,
            link: viewModel.news.fullUrl,
            title: viewModel.news.title,
            date: viewModel.news.publishedDate.formattedRelativeDate()
        )
    }
}

// MARK: - Binding

extension NewsDetailViewController {

    private func bindViewModel() {
        viewModel.$images
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource

extension NewsDetailViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 4
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        NewsCellFactory.configureCell(
            for: indexPath,
            tableView: tableView,
            viewModel: viewModel) { [weak self] in
                self?.showShareActions()
            }
    }
}

// MARK: - UITableViewDelegate

extension NewsDetailViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.font = .bold41x34
        headerLabel.textAlignment = .left
        headerLabel.text = GlobalConstants.headerTitle
        return headerLabel
    }
}
