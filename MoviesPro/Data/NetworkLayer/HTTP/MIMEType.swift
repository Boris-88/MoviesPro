//
//  MIMEType.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

public enum MIMEType: ExpressibleByStringLiteral {
    case wwwFormUtf8
    case jsonUtf8
    case json
    case pdf
    case zip

    // Text
    case textPlain

    // Image
    case jpg
    case gif
    case png

    case custom(String)

    // MARK: - Public Properties

    public var rawValue: String {
        switch self {
        case .wwwFormUtf8:  return "application/x-www-form-urlencoded; charset=utf-8"
        case .jsonUtf8:     return "application/json; charset=utf-8"
        case .json:         return "application/json"
        case .pdf:          return "application/pdf"
        case .zip:          return "application/zip"
        case .textPlain:    return "text/plain"
        case .jpg:          return "image/jpeg"
        case .gif:          return "image/gif"
        case .png:          return "image/png"
        case .custom(let v): return v
        }
    }

    // MARK: - Initialization with literal

    public init(stringLiteral value: StringLiteralType) {
        self = .custom(value)
    }

}
