//
//  Date+Extension.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 07.02.2025.
//

import Foundation

extension Date {
    func formattedRelativeDate() -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let russianLocale = Locale(identifier: "ru_RU")

        if calendar.isDateInToday(self) {
            return "Сегодня"
        } else if calendar.isDateInYesterday(self) {
            return "Вчера"
        } else {
            formatter.dateFormat = "d MMMM"
            formatter.locale = russianLocale
            return formatter.string(from: self)
        }
    }
}
