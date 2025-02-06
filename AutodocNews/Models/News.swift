//
//  News.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import Foundation

struct News: Codable {
    let id: Int
    let title: String
    let description: String
    let publishedDate: Date
    let url: String
    let fullUrl: String
    let titleImageUrl: String?
    let categoryType: String
}

struct NewsResponse: Codable {
    let news: [News]
    let totalCount: Int
}
