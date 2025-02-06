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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private lazy var newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private var gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private var gradientLayer: CAGradientLayer?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - layoutSubviews

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = gradientView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
    }

    // MARK: - Setup UI

    private func setupViews() {
        contentView.setupView(containerView)
        containerView.setupView(newsImageView)
        containerView.setupView(gradientView)
        containerView.setupView(titleLabel)

        newsImageView.constraintEdges(to: containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            gradientView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        addGradientView()
    }

    private func addGradientView() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.4).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient
    }
}

// MARK: - Configure Cell

extension NewsCell {

    func configure(with news: News) {
        titleLabel.text = news.title

        if let imageUrlString = news.titleImageUrl, let url = URL(string: imageUrlString) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let image = UIImage(data: data)
                    newsImageView.image = image
                } catch {
                    Logger.shared.log(
                        .error,
                        message: "Failed to load image:",
                        metadata: ["❌": error.localizedDescription]
                    )
                }
            }
        } else {
            newsImageView.image = nil
        }
    }
}
