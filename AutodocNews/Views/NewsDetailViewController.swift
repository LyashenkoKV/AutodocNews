//
//  NewsDetailViewController.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit

@MainActor
final class NewsDetailViewController: UIViewController {
    // MARK: - Свойства
    private let news: News

    // Элементы интерфейса
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let descriptionLabel = UILabel()

    // MARK: - Инициализация
    init(news: News) {
        self.news = news
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("News Detail", comment: "Title for news detail screen")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureContent()
    }

    // MARK: - Настройка интерфейса
    private func setupUI() {
        // Настройка scrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Контейнер для контента
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Настройка stackView
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        // Настройка imageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        // Настройка заголовка
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0

        // Настройка метки даты
        dateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        dateLabel.textColor = .secondaryLabel

        // Настройка описания новости
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.numberOfLines = 0

        // Если для новости задан URL изображения, добавляем imageView в stackView
        if let imageUrlString = news.titleImageUrl, let url = URL(string: imageUrlString) {
            stackView.addArrangedSubview(imageView)
            loadImage(from: url)
        }

        // Добавляем остальные элементы в stackView
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(descriptionLabel)
    }

    // MARK: - Конфигурация контента
    private func configureContent() {
        titleLabel.text = news.title

        // Форматирование даты публикации
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: news.publishedDate)

        descriptionLabel.text = news.description
    }

    // MARK: - Загрузка изображения
    private func loadImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    self.imageView.image = image
                }
            } catch {
                // Можно добавить логирование ошибки или установить placeholder
                print("Ошибка загрузки изображения: \(error)")
            }
        }
    }
}
