//
//  States.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 18.02.2025.
//

import UIKit

enum State<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
}
