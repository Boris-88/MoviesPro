//
//  HTTPHeaders.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

/// An order-preserving and case-insensitive representation of HTTP headers.
public struct HTTPHeaders: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral,
                            Sequence, Collection,
                            CustomStringConvertible,
                           Equatable, Hashable {

    // MARK: - Private Properties

    /// Storage for headers.
    fileprivate var headers: [HTTPHeaders.Element] = []

    // MARK: - Keys

    /// All the keys of headers.
    public var keys: [HTTPHeaders.Element.Name] {
        headers.map {
            $0.name
        }
    }

    // MARK: - Initialization

    /// The default set of `HTTPHeaders` used by the library.
    /// It includes encoding, language and user agent.
    public static var `default`: HTTPHeaders {
        HTTPHeaders(headers: [
            .defaultAcceptEncoding,
            .defaultUserAgent
        ])
    }

    /// Create an additional HTTPHeaders set with content length if data is not empty.
    public static func forData(_ data: Data?) -> HTTPHeaders? {
        guard let data = data, data.isEmpty == false else {
            return nil
        }

        return [
            .contentLength(String(data.count))
        ]
    }

    /// Initialize a new HTTPHeaders storage with given data.
    ///
    /// NOTE: It's case insentive so duplicate names are collapsed into the last name
    /// and value encountered.
    /// - Parameter headers: headers.
    public init(headers: [HTTPHeaders.Element] = []) {
        headers.forEach {
            set($0)
        }
    }

    /// Create a new instance of HTTPHeaders from a dictionary of key,values
    ///
    /// NOTE: It's case insentive so duplicate names are collapsed into the last name
    /// and value encountered.
    /// - Parameter headersDictionary: headers dictionary.
    public init(rawDictionary: [String: String]?) {
        rawDictionary?.forEach {
            set(HTTPHeaders.Element(name: $0.key, value: $0.value))
        }
    }

    /// Create a new instance of HTTPHeaders from a dictionary of key,values where
    /// key is the `HTTPHeaderField` and not a raw string.
    ///
    /// - Parameter headersDictionary: headers dictionary.
    public init(_ headersDictionary: [HTTPHeaders.Element.Name: String]?) {
        headersDictionary?.forEach {
            set(HTTPHeaders.Element(name: $0.key, value: $0.value))
        }
    }

    /// Initialize by passing a `ExpressibleByArrayLiteral` array.
    ///
    /// - Parameter elements: elements.
    public init(arrayLiteral elements: HTTPHeaders.Element...) {
        self.init(headers: elements)
    }

    /// Initialize by passing a `ExpressibleByDictionaryLiteral` array.
    ///
    /// - Parameter headersDictionary: elements.
    public init(dictionaryLiteral headersDictionary: (String, String)...) {
        headersDictionary.forEach {
            set($0.0, $0.1)
        }
    }

    // MARK: - Sequence, Collection Conformance

    public func makeIterator() -> IndexingIterator<[HTTPHeaders.Element]> {
        headers.makeIterator()
    }

    public var startIndex: Int {
        headers.startIndex
    }

    public var endIndex: Int {
        headers.endIndex
    }

    public subscript(position: Int) -> HTTPHeaders.Element {
        headers[position]
    }

    public func index(after i: Int) -> Int {
        headers.index(after: i)
    }

    // MARK: - Add Headers Functions

    /// Add of a new header to the list.
    /// NOTE: It's case insensitive.
    ///
    /// - Parameters:
    ///   - name: name of the header.
    ///   - value: value of the header.
    public mutating func set(_ name: String, _ value: String) {
        set(HTTPHeaders.Element(name: name, value: value))
    }

    /// Add of a new header to the list.
    ///
    /// - Parameters:
    ///   - field: field.
    ///   - value: value.
    public mutating func set(_ field: HTTPHeaders.Element.Name, _ value: String) {
        set(HTTPHeaders.Element(name: field.rawValue, value: value))
    }

    /// Update the headers value by adding a new header.
    /// NOTE: It's case insensitive.
    ///
    /// - Parameter header: header to add.
    public mutating func set(_ header: HTTPHeaders.Element) {
        guard let index = headers.index(of: header.name.rawValue) else {
            headers.append(header)
            return
        }

        headers.replaceSubrange(index...index, with: [header])
    }

    /// Update the headers with the ordered list passed.
    /// NOTE: It's case insentive.
    ///
    /// - Parameter headers: headers to add.
    public mutating func set(_ headers: [HTTPHeaders.Element]) {
        headers.forEach {
            set($0)
        }
    }

    /// Add headers from a dictionary.
    ///
    /// - Parameter headers: headers
    public mutating func set(_ headers: [HTTPHeaders.Element.Name: String]) {
        headers.enumerated().forEach {
            set(HTTPHeaders.Element(name: $0.element.key.rawValue, value: $0.element.value))
        }
    }

    /// Merge the contents of self with other headers which has priority over existing items.
    ///
    /// - Parameter otherHeaders: other headers
    public mutating func mergeWith(_ otherHeaders: HTTPHeaders?) {
        guard let otherHeaders = otherHeaders else {
            return
        }

        for header in otherHeaders {
            set(header)
        }
    }

    // MARK: - Remove Headers Functions

    /// Case-insensitively removes an `HTTPHeader`, if it exists, from the instance.
    ///
    /// - Parameter name: The name of the `HTTPHeader` to remove.
    public mutating func remove(name: String) {
        guard let index = headers.index(of: name) else {
            return
        }

        headers.remove(at: index)
    }

    /// Case-insensitively removes an `HTTPHeader`, if it exists, from the instance.
    ///
    /// - Parameter name: The header name.
    public mutating func remove(name: HTTPHeaders.Element.Name) {
        guard let index = headers.index(of: name.rawValue) else {
            return
        }

        headers.remove(at: index)
    }

    /// Case-insensitively find a header's value passing the name.
    ///
    /// - Parameter name: name of the header, search is not case sensitive.
    /// - Returns: String or nil if ket does not exists.
    public func value(for name: String) -> String? {
        guard let index = headers.index(of: name) else {
            return nil
        }

        return headers[index].value
    }

    // MARK: - Other Functions

    /// Sort the current instance by header name.
    /// NOTE: It's case insentive.
    public mutating func sort() {
        headers.sort {
            $0.name.rawValue.lowercased() < $1.name.rawValue.lowercased()
        }
    }

    /// Convert the object to a dictionary of key,value.
    /// Note: duplicate values may be overriden and the order is not preserved.
    public var asDictionary: [String: String] {
        let namesAndValues = headers.map {
            ($0.name.rawValue, $0.value)
        }

        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }

    /// Subscript access to the value of an header.
    /// NOTE: It's case insentive.
    ///
    /// - Parameter name: The name of the header.
    public subscript(_ name: String) -> String? {
        get {
            value(for: name)
        }
        set {
            if let value = newValue {
                set(name, value)
            } else {
                remove(name: name)
            }
        }
    }

    public subscript(_ key: HTTPHeaders.Element.Name) -> String? {
        get {
            self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue
        }
    }

    /// Description of the headers.
    public var description: String {
        headers.map {
            $0.description
        }.joined(separator: "\n")
    }

    public static func + (left: HTTPHeaders, right: HTTPHeaders) -> HTTPHeaders {
        HTTPHeaders(headers: left.headers + right.headers)
    }

    public static func == (lhs: HTTPHeaders, rhs: HTTPHeaders) -> Bool {
        lhs.headers.sorted() == rhs.headers.sorted()
    }

}

// MARK: HTTPHeaders (HTTPURLResponse Extension)
extension HTTPURLResponse {

    /// Returns `allHeaderFields` as `HTTPHeaders`.
    public var headers: HTTPHeaders {
        HTTPHeaders(rawDictionary: allHeaderFields as? [String: String])
    }

}

// MARK: HTTPHeaders (URLSessionConfiguration Extension)
extension URLSessionConfiguration {

    /// `httpAdditionalHeaders` as `HTTPHeaders` object.
    public var headers: HTTPHeaders {
        get {
            HTTPHeaders(rawDictionary: httpAdditionalHeaders as? [String: String])
        }
        set {
            httpAdditionalHeaders = newValue.asDictionary
        }
    }

}

// MARK: - Array Extensions
extension Array where Element == HTTPHeaders.Element {

    /// Search for index of an HTTPHeader's field inside the list.
    /// Search is made as case insensitive.
    ///
    /// - Parameter name: name of the header.
    /// - Returns: Int?
    internal func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.rawValue.lowercased() == lowercasedName }
    }

}

public extension HTTPHeaders {

    /// A representation of a single HTTP header's name & value pair.
    struct Element: Hashable, Equatable, Comparable, CustomStringConvertible {

        // MARK: - Public Properties

        /// Name of the header.
        public let name: Name

        /// Value of the header.
        public let value: String

        // MARK: - Static Initialization

        /// Create the default `Accept-Encoding` header.
        public static let defaultAcceptEncoding: Element = {
            .acceptEncoding(["gzip"].encodedWithQuality())
        }()

        /// Create the default `User-Agent` header.
        /// See <https://tools.ietf.org/html/rfc7231#section-5.5.3>.
        public static let defaultUserAgent: Element = {
            let defaultName = "Sberfriend-IOS"
            return .userAgent(defaultName)
        }()

        // MARK: - Initialization

        public init(name: String, value: String) {
            self.init(name: .custom(name), value: value)
        }

        /// Initialize a new instance of the header with given data where name of the field
        /// is taken from our list of pre-builts fields.
        ///
        /// - Parameters:
        ///   - name: name of the field.
        ///   - value: value of the field.
        public init(name: Name, value: String) {
            self.name = name
            self.value = value
        }

        /// Description of the header.
        public var description: String {
            "\(name.rawValue): \(value)"
        }

        public static func ==(lhs: Element, rhs: Element) -> Bool {
            lhs.name.rawValue == rhs.name.rawValue && lhs.value == rhs.value
        }

        public static func < (lhs: Element, rhs: Element) -> Bool {
            lhs.name.rawValue.lowercased().compare(rhs.name.rawValue.lowercased()) == .orderedAscending
        }

    }

}

    // MARK: - HTTPHeader + Authorization
public extension HTTPHeaders.Element {

    // MARK: - Authorization

    /// The HTTP Authorization request header can be used to provide credentials
    /// that authenticate a user agent with a server, allowing access to a protected resource.
    /// Example: `Authorization: <auth-scheme> <authorisation-parameters>`
    ///
    /// NOTE:
    /// Consider using one of the built-in methods provided by this library
    /// in order to create valid authorization tokens styles.
    ///
    /// - Parameter rawValue: value of the header.
    /// - Returns: `HTTPHeaders.Element`
    static func auth(_ rawValue: String) -> HTTPHeaders.Element {
        .init(name: "Authorization", value: rawValue)
    }

    /// `Basic` `Authorization` header using the `username`, `password` provided.
    /// It is a simple authentication scheme built into the HTTP protocol.
    /// The client sends HTTP requests with the Authorization header that
    /// contains the word Basic, followed by a space and a base64-encoded
    /// in form of `string username: password` (non-encrypted).
    ///
    /// Example: `Authorization: Basic AXVubzpwQDU1dzByYM==`
    ///
    /// - Parameters:
    ///   - username: username of the header.
    ///   - password: password of the header.
    /// - Returns: `HTTPHeaders.Element`
    static func authBasic(username: String, password: String) -> HTTPHeaders.Element {
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()
        return auth("Basic \(credential)")
    }

    /// Commonly known as token authentication. It is an HTTP authentication
    /// scheme that involves security tokens called bearer tokens.
    /// As the name depicts “Bearer Authentication” gives access to the bearer of this token.
    ///
    /// The bearer token is a cryptic string, usually generated by the server in
    /// response to a login request. The client must send this token in the
    /// Authorization header while requesting to protected resources.
    /// It's commonly used for JWT authentication.
    ///
    /// Example: `Authorization: Bearer <token>`
    ///
    /// - Parameter bearerToken: Arbitrary string that specifies how the bearer token is formatted.
    /// - Returns: `HTTPHeaders.Element`
    static func authBearerToken(_ bearerToken: String) -> HTTPHeaders.Element {
        auth("Bearer \(bearerToken)")
    }

    /// OAuth 1.0 permits client applications to access data provided by a third-party API.
    /// With OAuth 2.0, you first retrieve an access token for the API, then use that token
    /// to authenticate future requests. Getting to information via OAuth 2.0
    /// flow varies greatly between API service providers, but typically involves
    /// a few requests back and forward between client application, user, and API.
    ///
    /// Example: `Authorization: Bearer hY_9.B5f-4.1BfE`
    ///
    /// - Parameter oAuthToken: The token value.
    /// - Returns: `HTTPHeaders.Element`
    static func authOAuth(_ oAuthToken: String) -> HTTPHeaders.Element {
        auth("OAuth \(oAuthToken)")
    }

    /// An API key is a token that a client provides when making API calls.
    /// Example: `X-API-Key: abcdefgh123456789`
    ///
    /// - Parameter xAPIKey: value of the key.
    /// - Returns: `HTTPHeaders.Element`
    static func xAPIKey(_ xAPIKey: String) -> HTTPHeaders.Element {
        .init(name: "X-API-Key", value: xAPIKey)
    }

}

// MARK: - HTTPHeader + Accept
/// Documentation for available HTTP Headers can be found here:
/// <https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html>
public extension HTTPHeaders.Element {

    /// The `Accept` request-header field can be used to specify certain media types which
    /// are acceptable for the response.
    /// Example: `audio/*; q=0.2, audio/basic`.
    ///
    /// - Parameter value: `Accept` value
    /// - Returns: `HTTPHeader.Element`
    static func accept(_ value: String) -> HTTPHeaders.Element {
        .init(name: .accept, value: value)
    }

    /// The Accept-Encoding request-header field is similar to Accept, but restricts
    /// the content-codings (<https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.5>)
    /// that are acceptable in the response.
    ///
    /// Example: `compress, gzip`
    ///
    /// - Parameter encoding: `Accept-Encoding` value.
    /// - Returns: `HTTPHeader.Element`
    static func acceptEncoding(_ encoding: String) -> HTTPHeaders.Element {
        .init(name: .acceptEncoding, value: encoding)
    }

}

// MARK: - HTTPHeader + Content
public extension HTTPHeaders.Element {

    /// `Content-Disposition` header.
    /// The `Content-Disposition` header indicate if the content is expected to be displayed inline
    /// in the browser, that is, as a Web page or as part of a Web page, or as an attachment,
    /// that is downloaded and saved locally.
    /// More info <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition>
    ///
    /// Example: `Content-Disposition: inline`
    ///
    /// - Parameter value: `Content-Disposition` value.
    /// - Returns: HTTPHeader
    static func contentDisposition(_ value: String) -> HTTPHeaders.Element {
        .init(name: .contentDisposition, value: value)
    }

    /// The `Content-Type` entity-header field indicates the media type of the entity-body
    /// sent to the recipient or, in the case of the HEAD method,
    /// the media type that would have been sent had the request been a GET.
    /// The following method it's not type-safe.
    ///
    /// Example: `text/html; charset=ISO-8859-4`
    ///
    /// - Parameter value: `Content-Type` value.
    /// - Returns: HTTPHeader
    static func contentType(_ value: String) -> HTTPHeaders.Element {
        .init(name: .contentType, value: value)
    }

    /// The `Content-Type` entity-header field indicates the media type of the entity-body
    /// sent to the recipient or, in the case of the HEAD method,
    /// the media type that would have been sent had the request been a GET.
    /// The following method it's type-safe.
    ///
    /// Example: `text/html; charset=ISO-8859-4`
    ///
    /// - Parameter value: `HTTPContentType` presets value.
    /// - Returns: HTTPHeader.
    static func contentType(_ value: HTTPContentType) -> HTTPHeaders.Element {
        contentType(value.rawValue)
    }

    /// The `Content-Length` entity-header field indicates the size of the entity-body,
    /// in decimal number of OCTETs, sent to the recipient or,
    /// in the case of the HEAD method, the size of the entity-body
    /// that would have been sent had the request been a GET.
    ///
    /// Example: `3495`
    ///
    /// - Parameter value: `Content-Length` value.
    /// - Returns: HTTPHeader.
    static func contentLength(_ value: String) -> HTTPHeaders.Element {
        .init(name: .contentLength, value: value)
    }

}

// MARK: - HTTPHeader + Other
public extension HTTPHeaders.Element {

    /// The `User-Agent` request-header field contains information about the
    /// user agent originating the request.
    ///
    /// Example: `CERN-LineMode/2.15 libwww/2.17b3`
    ///
    /// - Parameter value: `User-Agent` value.
    /// - Returns: HTTPHeader
    static func userAgent(_ value: String) -> HTTPHeaders.Element {
        .init(name: .userAgent, value: value)
    }
}

// MARK: - Extensions
internal extension Collection where Element == String {

    /// See https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html.
    ///
    /// - Returns: String
    func encodedWithQuality() -> String {
        enumerated().map { index, encoding in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(encoding);q=\(quality)"
        }.joined(separator: ", ")
    }

}

public extension HTTPHeaders.Element {

    enum Name: ExpressibleByStringLiteral, Hashable, Equatable {
        case accept
        case acceptEncoding
        case authorization
        case contentLength
        case contentDisposition
        case contentType
        case cookie
        case userAgent
        case custom(String)

        /// You can create a custom header name from a literal string.
        ///
        /// - Parameter value: value.
        public init(stringLiteral value: StringLiteralType) {
            self = .custom(value)
        }

        // MARK: - Public Properties

        /// Raw value of the header name.
        public var rawValue: String {
            switch self {
            case .accept: return "Accept"
            case .acceptEncoding: return "Accept-Encoding"
            case .authorization: return "Authorization"
            case .contentLength: return "Content-Length"
            case .contentDisposition: return "Content-Disposition"
            case .contentType: return "Content-Type"
            case .cookie: return "Cookie"
            case .userAgent: return "User-Agent"
            case .custom(let v): return v
            }
        }
    }

}
