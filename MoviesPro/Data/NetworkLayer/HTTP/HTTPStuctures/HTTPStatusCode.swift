//
//  HTTPStatusCode.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

/// A set of HTTP response status codes
public enum HTTPStatusCode: Int, Error {
    case none = 0

    // MARK: - Informational - 1xx

    case `continue` = 100
    case switchingProtocols = 101
    case processing = 102

    // MARK: - Success - 2xx

    case ok = 200
    case created = 201
    case accepted = 202
    case nonAuthoritativeInformation = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    case multiStatus = 207
    case alreadyReported = 208
    case IMUsed = 226

    // MARK: - Redirection - 3xx
    case multipleChoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case notModified = 304
    case useProxy = 305
    case switchProxy = 306
    case temporaryRedirect = 307
    case permenantRedirect = 308

    // MARK: - Client Errors - 4xx
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case requestTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconditionFailed = 412
    case payloadTooLarge = 413
    case URITooLong = 414
    case unsupportedMediaType = 415
    case rangeNotSatisfiable = 416
    case expectationFailed = 417
    case teapot = 418
    case misdirectedRequest = 421
    case unprocessableEntity = 422
    case locked = 423
    case failedDependency = 424
    case upgradeRequired = 426
    case preconditionRequired = 428
    case tooManyRequests = 429
    case requestHeaderFieldsTooLarge = 431
    case noResponse = 444
    case unavailableForLegalReasons = 451
    case SSLCertificateError = 495
    case SSLCertificateRequired = 496
    case HTTPRequestSentToHTTPSPort = 497
    case clientClosedRequest = 499

    // MARK: - Server Errors - 5xx
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case HTTPVersionNotSupported = 505
    case variantAlsoNegotiates = 506
    case insufficientStorage = 507
    case loopDetected = 508
    case notExtended = 510
    case networkAuthenticationRequired = 511

    // MARK: - Public Properties
    /// The class (or group) to which the status code belongs to.
    public var responseType: ResponseType {
        ResponseType(httpStatusCode: self.rawValue)
    }

    /// Initializes an HTTPStatusCode from a URLResponse object.
    /// If no valid code can be extracted the `.none` is set.
    ///
    /// - Parameter urlResponse: url response instance
    public static func fromResponse(_ URLResponse: URLResponse?) -> HTTPStatusCode {
        guard let statusCode = (URLResponse as? HTTPURLResponse)?.statusCode else {
            return .none
        }

        return HTTPStatusCode(rawValue: statusCode) ?? .none
    }
}

// MARK: HTTPStatusCode + ResponseType
public extension HTTPStatusCode {

    /// An enum which represents a set of HTTP response status codes grouped by class..
    ///
    /// - `informal`: This class of status code indicates a provisional response,
    ///               consisting only of the Status-Line and optional headers,
    ///               and is terminated by an empty line.
    /// - `success`: This class of status codes indicates the action requested by
    ///              the client was received, understood, accepted, and processed successfully.
    /// - `redirection`: This class of status code indicates the client must take additional action to complete the request.
    /// - `clientError`: This class of status code is intended for situations in which the client seems to have erred.
    /// - `serverError`: This class of status code indicates the server failed to fulfill an apparently valid request.
    /// - `undefined`: The class of the status code cannot be resolved.
    enum ResponseType {
        case informational
        case success
        case redirection
        case clientError
        case serverError
        case undefined

        /// ResponseType by HTTP status code
        public init(httpStatusCode: Int?) {
            guard let httpStatusCode = httpStatusCode else {
                self = .undefined
                return
            }

            switch httpStatusCode {
                case 100 ..< 200: self = .informational
                case 200 ..< 300: self = .success
                case 300 ..< 400: self = .redirection
                case 400 ..< 500: self = .clientError
                case 500 ..< 600: self = .serverError
                default:          self = .undefined
            }
        }
    }
}

// MARK: HTTPURLResponse + Extension
extension HTTPURLResponse {

    /// The object representation of HTTP status code
    var status: HTTPStatusCode? {
        HTTPStatusCode(rawValue: statusCode)
    }
}
