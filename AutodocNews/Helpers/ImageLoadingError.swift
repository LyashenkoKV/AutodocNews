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
        case .invalidMIMEType: GlobalConstants.invalidMIMEType
        case .downloadFailed(let error): GlobalConstants.downloadFailed + "\(error.localizedDescription)"
        case .imageProcessingFailed: GlobalConstants.imageProcessingFailed
        case .cancelled: GlobalConstants.cancelled
        }
    }
}
