//
//  ImageLoadingError.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import Foundation

enum ImageLoadingError: Error, LocalizedError {
    case invalidMIMEType
    case downloadFailed(Error)
    case imageProcessingFailed
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidMIMEType: "Неподдерживаемый тип изображения"
        case .downloadFailed(let error): "Ошибка загрузки: \(error.localizedDescription)"
        case .imageProcessingFailed: "Не удалось обработать изображение"
        case .cancelled: "Операция отменена"
        }
    }
}
