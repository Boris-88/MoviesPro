//
//  HTTPMethod.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

/// A set of request methods to indicate the desired action to be performed for a given resource.
public enum HTTPMethod: String, Equatable, Hashable, CaseIterable, CustomStringConvertible {

    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"

    public var description: String {
        rawValue.uppercased()
    }
}
