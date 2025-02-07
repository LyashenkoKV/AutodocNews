//
//  ActionSheetPresenter.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import UIKit

struct ActionSheetPresenter {
    static func presentShareActions(
        from viewController: UIViewController,
        title: String?,
        message: String?,
        url: String?
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )

        let copyAction = UIAlertAction(title: "Скопировать ссылку", style: .default) { _ in
            UIPasteboard.general.string = url
        }
        copyAction.setValue(UIImage(systemName: "doc.on.doc"), forKey: "image")

        let shareAction = UIAlertAction(title: "Поделиться", style: .default) { _ in
            guard let url = url else { return }
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            viewController.present(activityVC, animated: true)
        }
        shareAction.setValue(UIImage(systemName: "square.and.arrow.up"), forKey: "image")

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)

        alertController.addAction(copyAction)
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)

        viewController.present(alertController, animated: true)
    }
}
