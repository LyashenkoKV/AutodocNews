//
//  NewsHStackCell.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import UIKit

final class NewsHStackCell: UITableViewCell, ReuseIdentifying {

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .bold17
        label.numberOfLines = 0
        return label
    }()

    private let sharedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()

    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headlineLabel, sharedButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.setupView(hStack)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),

            sharedButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(headline: String, sharedAction: @escaping () -> Void) {
        headlineLabel.text = headline
        sharedButton.removeTarget(nil, action: nil, for: .allEvents)
        sharedButton.addAction(UIAction { _ in sharedAction() }, for: .touchUpInside)
    }
}
