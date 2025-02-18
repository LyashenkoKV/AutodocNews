//
//  States.swift
//  AutodocNews
//
//  Created by Konstantin Lyashenko on 18.02.2025.
//

import UIKit

enum NewsState {
    case idle
    case loading
    case loaded(newsItems: [News], totalCount: Int, currentPage: Int)
    case imageLoaded([UIImage])
    case error(Error)
}

//enum ImageLoadState {
//    case idle
//    case loading
//    case loaded([UIImage])
//    case error(Error)
//}
