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
    private var currentNewsId: Int?
    private var imageLoadTask: Task<Void, Never>?

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
        newsImageView.image = nil
        currentNewsId = nil
        imageLoadTask?.cancel()
        imageLoadTask = nil
    }

    // MARK: - Setup UI

    private func setupViews() {
        contentView.setupView(containerView)

        [newsImageView, gradientView, titleLabel].forEach {
            containerView.setupView($0)
        }

        newsImageView.constraintEdges(to: containerView)

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
        currentNewsId = news.id
        titleLabel.text = news.title

        imageLoadTask?.cancel()

        if let imageUrlString = news.titleImageUrl, let url = URL(string: imageUrlString) {
            let targetSize = CGSize(width: bounds.width - 32, height: bounds.height - 16)

            imageLoadTask = Task { [weak self] in
                guard let self else { return }
                let image = await imageService.loadImage(from: url, targetSize: targetSize)
                if self.currentNewsId == news.id {
                    UIView.transition(with: self.newsImageView, duration: 0.25, options: .transitionCrossDissolve) {
                        self.newsImageView.image = image
                    }
                }
            }
        }
    }
}
