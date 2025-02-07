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
        let pc = UIPageControl()
        pc.hidesForSinglePage = true
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = .lightGray
        pc.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        return pc
    }()

    private var images: [UIImage] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [imageScrollView, pageControl].forEach {
            contentView.setupView($0)
        }
        imageScrollView.delegate = self
        imageScrollView.constraintEdges(to: contentView)
        let height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 600 : 260

        NSLayoutConstraint.activate([
            imageScrollView.heightAnchor.constraint(equalToConstant: height),

            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(with images: [UIImage]) {
        self.images = images

        imageScrollView.subviews.forEach { $0.removeFromSuperview() }

        let width = contentView.bounds.width
        let height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 600 : 260

        for (index, image) in images.enumerated() {
            let iv = UIImageView(image: image)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.frame = CGRect(x: CGFloat(index) * width,
                              y: 0, width: width,
                              height: height)
            imageScrollView.addSubview(iv)
        }
        imageScrollView.contentSize = CGSize(width: width * CGFloat(images.count),
                                             height: height)
        pageControl.numberOfPages = images.count
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        guard width > 0 else { return }
        let page = Int((scrollView.contentOffset.x + width/2) / width)
        pageControl.currentPage = page
    }
}

