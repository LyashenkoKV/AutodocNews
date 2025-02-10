//
//  NewsCellFactory.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import UIKit

@MainActor
enum NewsCellFactory {
    static func configureCell(
        for indexPath: IndexPath,
        tableView: UITableView,
        viewModel: NewsDetailsViewModel,
        completion: @escaping () -> Void?
    ) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: NewsHStackCell = tableView.dequeueReusableCell()
            cell.configure(headline: viewModel.news.title) {
                completion()
            }
            return cell
        case 1:
            let cell: NewsDateCell = tableView.dequeueReusableCell()
            cell.configure(date: viewModel.news.publishedDate.formattedRelativeDate())
            return cell
        case 2:
            let cell: NewsTextCell = tableView.dequeueReusableCell()
            // Беру только описание, т.к. апи дает только его
            // Возможные варианты получения полного текста из урла:
            // Можно использовать библиотеку к примеру SwiftSoup, для скрининга Html-страницы и достать текст,
            // Можно открывать webWiew (или SafariVC)
            // Лучшим вариантом все же получать текст из апихи
            cell.configure(text: viewModel.news.description)
            return cell
        case 3:
            let cell: NewsImagesCell = tableView.dequeueReusableCell()
            cell.configure(with: viewModel.images)
            return cell
        default:
            Logger.shared.log(.error, message: "Unexpected cell index")
            fatalError()
        }
    }
}
