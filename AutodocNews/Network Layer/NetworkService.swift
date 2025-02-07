//
//  NetworkService.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchData(from url: URL) async throws -> (Data, URLResponse)
}

final class NetworkService: NetworkServiceProtocol {
    func fetchData(from url: URL) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(from: url)
    }
}

