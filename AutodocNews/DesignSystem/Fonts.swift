//
//  Fonts.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 06.02.2025.
//

import UIKit

extension UIFont {
    static var medium18x10 = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 10, weight: .medium)

    static var regular20x13 = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 13, weight: .regular)
    static var regular25x17 = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 25 : 17, weight: .regular)

    static var bold25x17 = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 25 : 17, weight: .bold)
    static var bold41x34 = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 41 : 34, weight: .bold)
}
