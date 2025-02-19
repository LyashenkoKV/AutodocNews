//
//  NewsCell.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit

@MainActor
final class NewsCell: UICollectionViewCell, ReuseIdentifying {

    // MARK: - Private Properties

    private let imageService: ImageServiceProtocol
    private var currentNews: News?
    private var imageLoadTask: Task<Void, Never>?

    private lazy var shimmerView: ShimmerView = {
        let view = ShimmerView()
        view.isHidden = true
        return view
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        return view
    }()

    private lazy var newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .regular25x17
        label.textColor = .white
        return label
    }()

    private var gradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    private func applyRoundedCorners() {
        let path = UIBezierPath(roundedRect: containerView.bounds,
                                cornerRadius: 16)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        containerView.layer.mask = maskLayer
    }

    private var gradientLayer: CAGradientLayer?

    // MARK: - Init

    override init(frame: CGRect) {
        self.imageService = ImageService()
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - layoutSubviews

    override func layoutSubviews() {
        super.layoutSubviews()
        applyRoundedCorners()
        updateGradientFrame()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        newsImageView.image = nil
        titleLabel.text = nil
        currentNews = nil
        shimmerView.stopShimmer()
    }

    // MARK: - Setup UI

    private func setupViews() {
        contentView.setupView(containerView)

        [newsImageView, shimmerView, gradientView, titleLabel].forEach {
            containerView.setupView($0)
        }

        newsImageView.constraintEdges(to: containerView)
        shimmerView.constraintEdges(to: newsImageView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        createGradientIfNeeded()
    }

    private func createGradientIfNeeded() {
        guard gradientLayer == nil else { return }

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(1).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradientView.layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient

        updateGradientFrame()
    }

    private func updateGradientFrame() {
        guard let gradientLayer = gradientLayer else { return }

        let gradientHeight: CGFloat = Heights.height50
        let yPosition = containerView.bounds.height - gradientHeight

        gradientView.frame = CGRect(
            x: 0,
            y: yPosition,
            width: containerView.bounds.width,
            height: gradientHeight
        )

        gradientLayer.frame = gradientView.bounds

        gradientLayer.removeAllAnimations()
        gradientView.layer.displayIfNeeded()
    }
}

// MARK: - Configure Cell

extension NewsCell {

    func configure(with news: News) {
        imageLoadTask?.cancel()
        imageLoadTask = nil

        newsImageView.image = nil
        titleLabel.text = news.title
        currentNews = news

        shimmerView.isHidden = false
        shimmerView.startShimmer()

        guard let imageUrlString = news.titleImageUrl, let url = URL(string: imageUrlString) else {
            shimmerView.isHidden = true
            shimmerView.stopShimmer()
            return
        }

        let targetSize = CGSize(width: bounds.width - 32, height: bounds.height - 16)

        imageLoadTask = Task { [weak self] in
            guard let self else { return }
            if Task.isCancelled { return }

            let image = await imageService.loadImage(from: url, targetSize: targetSize)

            await MainActor.run {
                if Task.isCancelled { return }
                guard self.currentNews?.id == news.id else { return }

                self.shimmerView.isHidden = true
                self.shimmerView.stopShimmer()

                UIView.transition(with: self.newsImageView, duration: 0.25, options: .transitionCrossDissolve) {
                    self.newsImageView.image = image
                }
            }
        }
    }
}
