//
//  NewsCell.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit

@MainActor
final class NewsCell: UICollectionViewCell, ReuseIdentifying {

    // MARK: - UI Elements

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
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
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private var gradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    private var gradientLayer: CAGradientLayer?

    // MARK: - Init

    override init(frame: CGRect) {
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

        gradientView.frame = CGRect(
            x: 0.0,
            y: containerView.bounds.height - 50.0,
            width: containerView.bounds.width,
            height: 50.0
        )
        gradientLayer?.frame = gradientView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
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
        addGradientView()
    }

    private func addGradientView() {
        gradientView.frame = CGRect(
            x: 0.0,
            y: containerView.bounds.height - 50.0,
            width: containerView.bounds.width,
            height: 50.0
        )
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor,
                           UIColor.black.withAlphaComponent(1).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradientView.layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient

        if gradientView.superview == nil {
            containerView.setupView(gradientView)
        }
    }
}

// MARK: - Configure Cell

extension NewsCell {

    func configure(with news: News) {
        titleLabel.text = news.title

        if let imageUrlString = news.titleImageUrl, let url = URL(string: imageUrlString) {
            let targetSize = CGSize(width: bounds.width - 32, height: bounds.height - 16)

            Task {
                if let image = await ImageDownsampleService.shared.loadImage(from: url, targetSize: targetSize) {
                    newsImageView.image = image
                } else {
                    newsImageView.image = UIImage(systemName: "photo")
                }
            }
        } else {
            newsImageView.image = UIImage(systemName: "photo")
        }
    }
}
