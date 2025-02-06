//
//  DateFormatters+Presets.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import Foundation

extension DateFormatter {

    static func dateFormatter(_ decoder: JSONDecoder) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }

    
}
