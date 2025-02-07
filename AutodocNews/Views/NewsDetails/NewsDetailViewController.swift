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

        let targetSize = CGSize(width: view.bounds.width, height: 300)
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(NewsHStackCell.self)
        tableView.register(NewsDateCell.self)
        tableView.register(NewsTextCell.self)
        tableView.register(NewsImagesCell.self)
        view.setupView(tableView)
        tableView.constraintEdges(to: view)
    }

    private func bindViewModel() {
        viewModel.$images
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func showShareActions() {
        ActionSheetPresenter.presentShareActions(
            from: self,
            title: viewModel.news.title,
            message: viewModel.news.publishedDate.formattedRelativeDate(),
            url: viewModel.news.fullUrl
        )
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension NewsDetailViewController: UITableViewDelegate, UITableViewDataSource {

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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.font = .bold34
        headerLabel.textAlignment = .left
        headerLabel.text = "Новости"
        return headerLabel
    }
}
