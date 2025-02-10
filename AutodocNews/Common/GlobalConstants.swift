//
//  GlobalConstants.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import Foundation

enum GlobalConstants {
    // Date
    static let today = "Сегодня"
    static let yesterday = "Вчера"

    // Logger
    static let logSubsystem = "KV.Lyashenko.AutodocNews"
    static let logCategory = "news"

    // CustomActionSheetController
    static let copyLink = "Скопировать ссылку"

    // Common
    static let cancel = "Отмена"

    // Error
    static let invalidMIMEType = "Неподдерживаемый тип изображения"
    static let downloadFailed = "Ошибка загрузки:"
    static let imageProcessingFailed = "Не удалось обработать изображение"
    static let cancelled = "Операция отменена"

    // NewsDetailViewController
    static let headerTitle = "Новости"
}
