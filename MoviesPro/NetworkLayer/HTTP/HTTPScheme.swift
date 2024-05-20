//
//  HTTPScheme.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

public struct HTTPScheme: Equatable, Hashable, Codable, RawRepresentable, CustomStringConvertible {
    static let http: Self = "http"
    static let https: Self = "https"
    static let tel: Self = "tel"
    static let mailto: Self = "mailto"
    static let file: Self = "file"
    static let data: Self = "data"

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue
    }

}

extension HTTPScheme: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

}
