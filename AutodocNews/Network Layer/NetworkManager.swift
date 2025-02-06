//
//  NetworkManager.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()

    func fetchNews(page: Int) async throws -> NewsResponse {
        guard let url = URL(string: "https://webapi.autodoc.ru/api/news/\(page)/15") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()

        DateFormatter.dateFormatter(decoder)

        let response = try decoder.decode(NewsResponse.self, from: data)
        return response
    }
}
