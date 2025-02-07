//
//  UIView+Extension.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit

extension UIView {
    func setupView(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        //subview.layer.borderWidth = 1
        addSubview(subview)
    }
}
