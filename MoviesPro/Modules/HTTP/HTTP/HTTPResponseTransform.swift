//
//  HTTPResponseTransform.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

public protocol HTTPResponseTransform {

    /// Perform transformation of the object itself.
    ///
    /// - Returns: `HTTPResponse`
    func transform(response: HTTPResponse, ofRequest request: HTTPRequest) throws -> HTTPResponse

}

// MARK: - HTTPResponseTransformerBlock
/// Concrete implementation of the `HTTPResponseTransformer` which uses callbacks.
public struct HTTPResponseTransformer: HTTPResponseTransform {

    public typealias Callback = ((_ response: HTTPResponse, _ request: HTTPRequest) throws -> HTTPResponse)

    // MARK: - Private Properties

    /// Callback function.
    private var callback: Callback

    // MARK: - Initialization

    /// Initialize a new callback.
    ///
    /// - Parameter callback: callback.
    public init(_ callback: @escaping Callback) {
        self.callback = callback
    }

    public func transform(response: HTTPResponse, ofRequest request: HTTPRequest) throws -> HTTPResponse {
        try callback(response, request)
    }
}
