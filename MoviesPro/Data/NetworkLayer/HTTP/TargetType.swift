//
//  TargetType.swift
//  VKClone
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

/// The protocol to define the specifications for requests
public protocol TargetType {
    /// The target's base `URL`.
    var baseURL: URL { get }
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    /// The HTTP methode used in request.
    var method: HTTPMethod { get }
    var body: HTTPBody? { get }
    var qearyItems: [String: Any]? { get }
    /// The headers to be used in the request
    var headers: HTTPHeaders? { get }
}
