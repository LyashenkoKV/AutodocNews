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

    private let viewModel: NewsDetailsViewModel
    private var cancellables = Set<AnyCancellable>()
    private let formatter = DateFormatter()

    private lazy var contentScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.delegate = self
        return scroll
    }()

    private lazy var imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()

    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            hStack,
            dateLabel,
            textView,
            imageScrollView
        ])
        stack.axis = .vertical
        return stack
    }()

    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            headlineLabel,
            sharedButton
        ])
        stack.axis = .horizontal
        return stack
    }()

    private lazy var pageControl = UIPageControl()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новости"
        label.font = .bold34
        return label
    }()

    private lazy var headlineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .regular17
        textView.tintColor = .systemBlue
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.clipsToBounds = true
        textView.textAlignment = .left
//        textView.textContainerInset = UIEdgeInsets(
//            top: 11,
//            left: 16,
//            bottom: 11,
//            right: 16
//        )
        return textView
    }()

    private lazy var sharedButton: UIButton = {
        let button = UIButton()

        return button
    }()

    init(news: News) {
        self.viewModel = NewsDetailsViewModel(news: news)
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("News Detail", comment: "Detail")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureContent()
        bindViewModel()

        let targetSize = CGSize(width: view.bounds.width, height: 300)

        Task {
            await viewModel.fetchImages(with: targetSize)
        }
    }

    private func setupUI() {
//        [pageControl].forEach {
//            view.setupView($0)
//        }
        view.setupView(vStack)

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            vStack.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }

    private func configureContent() {
        headlineLabel.text = viewModel.news.title
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: viewModel.news.publishedDate)
        textView.text = viewModel.news.description
    }

    private func bindViewModel() {
        viewModel.$images
            .receive(on: DispatchQueue.main)
            .sink { [weak self] images in
                self?.updateImageScrollView(with: images)
                self?.pageControl.numberOfPages = images.count
            }
            .store(in: &cancellables)
    }

    private func updateImageScrollView(with images: [UIImage]) {
        imageScrollView.subviews.forEach {
            $0.removeFromSuperview()
        }

        let width = view.bounds.width
        let height: CGFloat = 300

        for (index, image) in images.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.frame = CGRect(
                x: CGFloat(index) * width,
                y: 0,
                width: width,
                height: height
            )
            imageScrollView.setupView(imageView)
        }
        imageScrollView.contentSize = CGSize(
            width: width * CGFloat(images.count),
            height: height
        )
    }
}

// MARK: - UIScrollViewDelegate

extension NewsDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == imageScrollView {
            let width = scrollView.frame.width

            guard width > 0 else { return }
            let page = Int((scrollView.contentOffset.x + width / 2) / width)
            pageControl.currentPage = page
        }
    }
}
