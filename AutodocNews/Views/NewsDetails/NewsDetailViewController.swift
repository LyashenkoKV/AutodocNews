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
    private let formatter = DateFormatter()
    private let calendar = Calendar.current

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.estimatedRowHeight = 44
        tv.rowHeight = UITableView.automaticDimension
        tv.register(NewsHStackCell.self)
        tv.register(NewsDateCell.self)
        tv.register(NewsTextCell.self)
        tv.register(NewsImagesCell.self)
        return tv
    }()

    // MARK: - Init

    init(news: News) {
        self.viewModel = NewsDetailsViewModel(news: news)
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("News Detail", comment: "Detail")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        bindViewModel()

        let targetSize = CGSize(width: view.bounds.width, height: 300)
        Task {
            await viewModel.fetchImages(with: targetSize)
        }
    }

    // MARK: - Setup UI

    private func setupTableView() {
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

    private func showSortActionSheet() {
        let alertController = UIAlertController(
            title: viewModel.news.title,
            message: viewModel.news.publishedDate.formattedRelativeDate(),
            preferredStyle: .actionSheet
        )

        let copyAction = UIAlertAction(title: "Скопировать ссылку", style: .default) { [weak self] _ in
            guard let url = self?.viewModel.news.fullUrl else { return }
            UIPasteboard.general.string = url
        }

        let image = UIImage(systemName: "doc.on.doc")
        image?.withTintColor(.white, renderingMode: .alwaysOriginal)

        copyAction.setValue(image, forKey: "image")

        let shareAction = UIAlertAction(title: "Поделиться", style: .default) { [weak self] _ in
            guard let url = self?.viewModel.news.fullUrl else { return }
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self?.present(activityVC, animated: true)
        }
        shareAction.setValue(UIImage(systemName: "square.and.arrow.up"), forKey: "image")

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

        alertController.addAction(copyAction)
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
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

        switch indexPath.row {
        case 0:
            let cell: NewsHStackCell = tableView.dequeueReusableCell()
            cell.configure(headline: viewModel.news.title) { [weak self] in
                self?.showSortActionSheet()
            }
            return cell
        case 1:
            let cell: NewsDateCell = tableView.dequeueReusableCell()
            cell.configure(date: viewModel.news.publishedDate.formattedRelativeDate())
            return cell
        case 2:
            let cell: NewsTextCell = tableView.dequeueReusableCell()
            cell.configure(text: viewModel.news.description)
            return cell
        case 3:
            let cell: NewsImagesCell = tableView.dequeueReusableCell()
            cell.configure(with: viewModel.images)
            return cell
        default:
            fatalError("Unexpected row")
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
