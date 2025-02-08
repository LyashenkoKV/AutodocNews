//
//  NewsImagesCell.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import UIKit

final class NewsImagesCell: UITableViewCell, UIScrollViewDelegate, ReuseIdentifying {

    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let pageControl: UIPageControl = {
        let page = UIPageControl()
        page.hidesForSinglePage = true
        page.currentPageIndicatorTintColor = .white
        page.pageIndicatorTintColor = .lightGray
        page.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        return page
    }()

    private let shimmerView = ShimmerView()
    private var images: [UIImage] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerView.layoutIfNeeded()
    }

    private func setupUI() {
        [imageScrollView, pageControl].forEach {
            contentView.setupView($0)
        }
        imageScrollView.delegate = self
        imageScrollView.constraintEdges(to: contentView)

        NSLayoutConstraint.activate([
            imageScrollView.heightAnchor.constraint(equalToConstant: Heights.Height600x260),

            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        contentView.setupView(shimmerView)
        shimmerView.constraintEdges(to: imageScrollView)
    }

    func configure(with images: [UIImage]) {
        self.images = images

        if images.isEmpty {
            shimmerView.isHidden = false
            shimmerView.startShimmer()

            imageScrollView.subviews.forEach {
                if $0 is UIImageView { $0.removeFromSuperview() }
            }
            pageControl.isHidden = true
        } else {
            shimmerView.stopShimmer()
            shimmerView.isHidden = true

            imageScrollView.subviews.forEach {
                if $0 is UIImageView { $0.removeFromSuperview() }
            }
            let width = contentView.bounds.width

            for (index, image) in images.enumerated() {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: CGFloat(index) * width,
                                         y: 0, width: width,
                                         height: Heights.Height600x260)
                imageScrollView.addSubview(imageView)
            }
            imageScrollView.contentSize = CGSize(width: width * CGFloat(images.count),
                                                 height: Heights.Height600x260)
            pageControl.numberOfPages = images.count
            pageControl.isHidden = false
        }
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        guard width > 0 else { return }
        let page = Int((scrollView.contentOffset.x + width/2) / width)
        pageControl.currentPage = page
    }
}
