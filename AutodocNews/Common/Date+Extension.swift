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

        let currentYear = calendar.component(.year, from: Date())
        let targetYear = calendar.component(.year, from: self)

        if calendar.isDateInToday(self) {
            return GlobalConstants.today
        } else if calendar.isDateInYesterday(self) {
            return GlobalConstants.yesterday
        } else {
            let yearFormat = (targetYear != currentYear) ? " yyyy" : ""
            formatter.dateFormat = "d MMMM\(yearFormat)"
            formatter.locale = russianLocale
            return formatter.string(from: self).lowercased()
        }
    }
}
