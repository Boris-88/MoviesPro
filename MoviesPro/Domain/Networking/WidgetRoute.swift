//
//  WidgetRoute.swift
//  MoviesPro
//
//  Created by Boris Zverik on 28.05.2024.
//

import Foundation
import HTTP

enum WidgetRoute: TargetType {
    case details(id: Int)
    case widget(category: MovieCategory, page: Int)
    case poster(posterPath: String)
}

extension WidgetRoute {
    static var firstLoad: [WidgetRoute] {
        return MovieCategory.allCases.map {
            self.widget(category: $0, page: 0)
        }
    }
}
