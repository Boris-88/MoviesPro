//
//  HTTPContentType.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

/// A set of HTTP content types
public enum HTTPContentType: String, CustomStringConvertible {
    case octetStream = "application/octet-stream"
    case gif = "image/gif"
    case html = "text/html"
    case htmlUTF8 = "text/html; charset=utf-8"
    case jpeg = "image/jpeg"
    case json = "application/json"
    case jsonUTF8 = "application/json; charset=utf-8"
    case png = "image/png"
    case pdf = "application/pdf"
    case zip = "application/zip"
    case formUrlEncoded = "application/x-www-form-urlencoded"
    case formDataMultipart = "multipart/form-data"

    public var description: String {
        rawValue
    } 
}
