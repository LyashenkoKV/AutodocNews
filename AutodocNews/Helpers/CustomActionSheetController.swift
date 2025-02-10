//
//  ActionSheetPresenter.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import UIKit

final class CustomActionSheetController: UIViewController {

    // MARK: - Private properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold25x17
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .medium18x10
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .label
        button.contentHorizontalAlignment = .center
        return button
    }()

    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)

        var configuration = UIButton.Configuration.plain()
        configuration.title = GlobalConstants.copyLink
        configuration.image = UIImage(systemName: "doc.on.doc")
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .label
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 15,
            leading: 20,
            bottom: 15,
            trailing: 20
        )

        var background = UIBackgroundConfiguration.listPlainCell()
        background.backgroundColor = .tertiarySystemFill
        background.cornerRadius = 10
        configuration.background = background

        button.configuration = configuration

        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(GlobalConstants.cancel, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        button.backgroundColor = .tertiarySystemBackground
        button.contentHorizontalAlignment = .center
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()

    private var link: String?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateAppearance()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.setupView(backgroundView)
        view.setupView(containerView)

        backgroundView.frame = view.bounds

        let hStack = UIStackView(arrangedSubviews: [titleLabel, shareButton])
        hStack.axis = .horizontal
        hStack.spacing = 10
        hStack.alignment = .center

        let vStack = UIStackView(arrangedSubviews: [hStack, dateLabel, copyButton])
        vStack.axis = .vertical
        vStack.spacing = 15
        vStack.alignment = .fill

        containerView.setupView(vStack)
        view.setupView(cancelButton)

        vStack.constraintEdges(to: containerView, with: 20)

        if traitCollection.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                containerView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),
                containerView.widthAnchor.constraint(equalToConstant: 500),
                containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.9),

                cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                cancelButton.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                cancelButton.heightAnchor.constraint(equalToConstant: 50),

                shareButton.widthAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                containerView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),

                cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                cancelButton.heightAnchor.constraint(equalToConstant: 50),

                shareButton.widthAnchor.constraint(equalToConstant: 40)
            ])
        }
    }

    // MARK: - Private Methods

    private func setupActions() {
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSheet)))
        cancelButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyLink), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareLink), for: .touchUpInside)
    }

    @objc private func dismissSheet() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.cancelButton.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.backgroundView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    @objc private func copyLink() {
        guard let link = link else { return }
        UIPasteboard.general.string = link
        dismissSheet()
    }

    @objc private func shareLink() {
        guard let link = link else { return }
        let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    private func animateAppearance() {
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        cancelButton.transform = CGAffineTransform(translationX: 0, y: cancelButton.frame.height)
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = .identity
            self.cancelButton.transform = .identity
            self.backgroundView.alpha = 1
        }
    }

    // MARK: - Setup Method

    func present(in parent: UIViewController,
                 link: String,
                 title: String,
                 date: String
    ) {
        self.link = link
        titleLabel.text = title
        dateLabel.text = date
        modalPresentationStyle = .overFullScreen
        parent.present(self, animated: false)
    }
}
