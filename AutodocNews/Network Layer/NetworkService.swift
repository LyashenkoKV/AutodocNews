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
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {

            if (300...399).contains(httpResponse.statusCode) {
                Logger.shared.log(.error, message: "Redirect detected: \(httpResponse.statusCode) for \(url)")
                throw URLError(.badServerResponse)
            }

            if httpResponse.statusCode == 429 {
                Logger.shared.log(.error, message: "Rate limit reached (429) for \(url)")
                throw URLError(.timedOut)
            }

            if httpResponse.statusCode >= 500 {
                Logger.shared.log(.error, message: "Server error \(httpResponse.statusCode) for \(url)")
                throw URLError(.badServerResponse)
            }
        }

        return (data, response)
    }
}

