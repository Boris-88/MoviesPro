//
//  HTTPSerializableBody.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

public protocol HTTPSerializableBody {

    /// Returns an encoded data from the body structure.
    ///
    /// The operation dispatches asynchronously in another actor.
    /// Throws an exception if something went wrong.
    /// - Returns: Data and additional headers to append before making the call. (тут мне немного непонятно какой будет производиться вызов)
    func serializeData() async throws -> (data: Data, additionalHeaders: HTTPHeaders?)

}

// MARK: - HTTPEncodableBody (Data)
/// A simple Data instance as body of the request.
extension Data: HTTPSerializableBody {

    public func serializeData() async throws -> (data: Data, additionalHeaders: HTTPHeaders?) {
        (self, .forData(self))
    }

}

// MARK: - HTTPEncodableBody (String)
/// A simple String instance as body of the request.
extension String: HTTPSerializableBody {

    public func serializeData() async throws -> (data: Data, additionalHeaders: HTTPHeaders?) {
        let data = self.data(using: .utf8) ?? Data()
        return (data, .forData(data))
    }

}
