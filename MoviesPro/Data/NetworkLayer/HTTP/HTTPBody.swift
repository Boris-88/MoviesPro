//
//  HTTPBody.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

public struct HTTPBody {

    // MARK: - Public Static Properties

    /// No data to send.
    public static let empty = HTTPBody(content: Data())

    // MARK: - Public Properties

    /// Content of the body.
    public var content: HTTPSerializableBody

    // MARK: - Internal Properties

    /// Additional headers to set.
    internal var headers: HTTPHeaders

    // MARK: - Initialization

    /// Initializes a new HTTP body.
    ///
    /// - Parameters:
    ///   - content: the body content.
    ///   - headers: additional headers to set.
    internal init(content: HTTPSerializableBody, headers: HTTPHeaders = .init()) {
        self.content = content
        self.headers = headers
    }

}

// MARK: - HTTPBody for Raw Data
extension HTTPBody {

    /// Instantiates a new HTTP body with raw data.
    ///
    /// - Parameters:
    ///   - content: content data.
    ///   - mimeType: mime type to assign.
    /// - Returns: HTTPBody
    public static func data(_ content: Data, contentType mimeType: MIMEType) -> HTTPBody {
        HTTPBody(content: content, headers: .init([.contentType: mimeType.rawValue]))
    }

    /// Instantiates a new HTTP body with raw string encoded in .utf8.
    ///
    /// - Parameters:
    ///   - content: content string.
    ///   - contentType: content type to assign, defaults to `.text.plain`
    /// - Returns: HTTPBody
    public static func string(_ content: String, contentType: MIMEType = .textPlain) -> HTTPBody {
        .data(content.data(using: .utf8) ?? Data(), contentType: contentType)
    }

}

extension HTTPBody {

    /// Returns the body content as Data.
    public var asData: Data? {
        content as? Data
    }

    /// Returns the body content as String.
    public var asString: String? {
        content as? String
    }

}
