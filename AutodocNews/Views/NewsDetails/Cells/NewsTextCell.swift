//
//  NewsTextCell.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import UIKit

final class NewsTextCell: UITableViewCell, ReuseIdentifying {

    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .regular20x13
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 8,
                                             left: 0,
                                             bottom: 8,
                                             right: 0)
        return tv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.setupView(textView)
        textView.constraintEdges(to: contentView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String) {
        textView.text = text
    }
}
