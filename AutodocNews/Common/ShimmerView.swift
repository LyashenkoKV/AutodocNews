//
//  ShimmerView.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 08.02.2025.
//

import UIKit

final class ShimmerView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    private func setupLayer() {
        updateGradientColors()
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
    }

    private func updateGradientColors() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        gradientLayer.colors = isDarkMode ?
            [
                UIColor(white: 0.1, alpha: 1.0).cgColor,
                UIColor(white: 0.3, alpha: 1.0).cgColor,
                UIColor(white: 0.1, alpha: 1.0).cgColor
            ] :
            [
                UIColor(white: 0.85, alpha: 1.0).cgColor,
                UIColor(white: 0.75, alpha: 1.0).cgColor,
                UIColor(white: 0.85, alpha: 1.0).cgColor
            ]
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateGradientColors()
        }
    }

    func startShimmer() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.0, 0.25]
        animation.toValue = [0.75, 1.0, 1.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }

    func stopShimmer() {
        gradientLayer.removeAnimation(forKey: "shimmerAnimation")
    }
}
