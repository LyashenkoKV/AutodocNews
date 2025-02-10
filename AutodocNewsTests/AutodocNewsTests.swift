//
//  AutodocNewsTests.swift
//  AutodocNewsTests
//
//  Created by Konstantin Lyashenko on 10.02.2025.
//

@testable import AutodocNews
import XCTest

class DummyImageService: ImageServiceProtocol {
    func loadImage(from url: URL, targetSize: CGSize) async -> UIImage? {
        return nil
    }
}

extension NewsDetailsViewModel {
    func parseImageURLComponentsForTesting() -> (base: String, ext: String)? {
        return parseImageURLComponents()
    }
}

final class NewsDetailsViewModelTests: XCTestCase {

    @MainActor func testParseImageURLComponents_CorrectURL() {
        let news = News(
            id: 1,
            title: "Test News",
            description: "Test Description",
            publishedDate: Date(),
            url: "https://example.com",
            fullUrl: "https://example.com",
            titleImageUrl: "https://example.com/path/to_image_12.jpg",
            categoryType: "Test Category"
        )
        let viewModel = NewsDetailsViewModel(news: news, imageService: DummyImageService())

        let result = viewModel.parseImageURLComponentsForTesting()
        XCTAssertNotNil(result, "Метод должен вернуть непустой результат для корректного URL")
        XCTAssertEqual(result?.base, "https://example.com/path/to_image_", "Базовая часть URL сформирована неверно")
        XCTAssertEqual(result?.ext, ".jpg", "Расширение файла сформировано неверно")
    }

    @MainActor func testParseImageURLComponents_MultipleUnderscores() {
        let news = News(
            id: 2,
            title: "Test News 2",
            description: "Test Description",
            publishedDate: Date(),
            url: "https://example.com",
            fullUrl: "https://example.com",
            titleImageUrl: "https://example.com/path/to_image_version_2_34.png",
            categoryType: "Test Category"
        )
        let viewModel = NewsDetailsViewModel(news: news, imageService: DummyImageService())

        let result = viewModel.parseImageURLComponentsForTesting()
        XCTAssertNotNil(result, "Метод должен вернуть непустой результат для корректного URL")
        XCTAssertEqual(result?.base, "https://example.com/path/to_image_version_2_", "Базовая часть URL сформирована неверно")
        XCTAssertEqual(result?.ext, ".png", "Расширение файла сформировано неверно")
    }

    @MainActor func testParseImageURLComponents_InvalidURL() {
        let news = News(
            id: 3,
            title: "Test News 3",
            description: "Test Description",
            publishedDate: Date(),
            url: "https://example.com",
            fullUrl: "https://example.com",
            titleImageUrl: "https://example.com/path/toimage.jpg",
            categoryType: "Test Category"
        )
        let viewModel = NewsDetailsViewModel(news: news, imageService: DummyImageService())

        let result = viewModel.parseImageURLComponentsForTesting()
        XCTAssertNil(result, "Метод должен вернуть nil для URL, не соответствующего ожидаемому формату")
    }

    @MainActor func testParseImageURLComponents_EmptyURL() {
        let news = News(
            id: 4,
            title: "Test News 4",
            description: "Test Description",
            publishedDate: Date(),
            url: "https://example.com",
            fullUrl: "https://example.com",
            titleImageUrl: "",
            categoryType: "Test Category"
        )
        let viewModel = NewsDetailsViewModel(news: news, imageService: DummyImageService())

        let result = viewModel.parseImageURLComponentsForTesting()
        XCTAssertNil(result, "Метод должен вернуть nil для пустой строки URL")
    }
}
