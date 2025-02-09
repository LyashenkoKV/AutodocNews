# 📱 AutodocNews

NewsApp – это приложение для отображения новостных статей с возможностью загрузки изображений, обновления списка и просмотра деталей новости.  

## 📌 Функциональность

- Загрузка списка новостей с сервера
- Пагинация (подгрузка новостей при прокрутке вниз)
- Обновление списка новостей (Pull-to-Refresh)
- Детальный просмотр новости

## 🏗️ Архитектура

Проект использует MVVM + Combine:
- `NewsListViewController` – отображает список новостей
- `NewsViewModel` – управляет загрузкой списка новостей
- `NewsDetailViewController` – отображает детали новости
- `NewsDetailsViewModel` – управляет загрузкой изображений
- `ImageService` – загружает и кеширует изображения
- `NetworkManager` – выполняет сетевые запросы

## 🔧 Используемые технологии

- Swift + UIKit
- Combine для обработки событий
- `UICollectionViewCompositionalLayout` для списка новостей
- `UITableView` для экрана деталей
- `NSCache` для кеширования изображений
- `URLSession` для сетевых запросов
- `CGImageSource` для оптимизации загрузки изображений

## 📂 Структура проекта

```
📂 NewsApp
├── 📂 Models               # Модели данных
├── 📂 ViewModels           # Логика приложения (MVVM)
├── 📂 Views                # UI-компоненты
├── 📂 Services             # Сетевые запросы и загрузка изображений
├── 📂 Router               # Роутинг
├── 📂 Helpers              # Вспомогательные утилиты
└── AutodocNews.xcodeproj   # Проект Xcode
```

## 🏗 Возможные улучшения  

- Добавление кэширования новостей  
- Улучшение UI/UX  
- Сменить imageScrollView в NewsImagesCell на UICollectionView с UICollectionViewCompositionalLayout
- Сменить ActionSheetPresenter на кастомный модальный контроллер

## 👨‍💻 Автор  

Ляшенко Константин – iOS Developer  
