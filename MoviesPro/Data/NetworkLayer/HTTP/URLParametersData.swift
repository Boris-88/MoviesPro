//
//  URLParametersData.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

public typealias HTTPRequestParametersDict = [String: Any]

extension HTTPBody {

    /// Deprecated, see `formURLEncodedBody`.
    ///
    /// - Parameter parameters: parameters to set.
    /// - Returns: HTTPBody
    @available(*, deprecated, message: "Use formURLEncodedBody instead")
    public static func urlParameters(_ parameters: HTTPRequestParametersDict) -> HTTPBody {
        formURLEncodedBody(parameters)
    }

    /// Create a new body which contains the query string with passed parameters.
    ///
    /// - Parameter parameters: parameters.
    /// - Returns: HTTPBody
    public static func formURLEncodedBody(_ parameters: HTTPRequestParametersDict) -> HTTPBody {
        let content = WWWFormURLEncodedBody(parameters)
        let body = HTTPBody(content: content, headers: [
            .contentType(MIMEType.wwwFormUtf8.rawValue)
        ])
        return body
    }

}

// MARK: - WWWFormURLEncoded
extension HTTPBody {

    /// Encode the parameters inside the body with standard url encoding.
    public struct WWWFormURLEncodedBody: HTTPSerializableBody {

        // MARK: - Public Properties

        /// Parameters to set with url encoded body.
        public let parameters: URLParametersData

        // MARK: - Initialziation

        /// Initialize a new body with parameters dictionary.
        ///
        /// - Parameter parameters: parameters.
        public init(_ parameters: HTTPRequestParametersDict) {
            self.parameters = URLParametersData(parameters)
        }

        // MARK: - HTTPSerializableBody Conformance

        public func serializeData() async throws -> (data: Data, additionalHeaders: HTTPHeaders?) {
            try await parameters.serializeData()
        }

    }

}

extension HTTPBody {

    public final class URLParametersData: HTTPSerializableBody {

        // MARK: - Public Properties

        /// Parameters to encode.
        public var parameters: HTTPRequestParametersDict?

        // MARK: - Additional Configuration

        /// Specify how array parameter's value are encoded into the request.
        public let arrayEncoding: ArrayEncodingStyle

        /// Specify how boolean values are encoded into the request.
        public let boolEncoding: BoolEncodingStyle

        // MARK: - Initialization

        /// Initialize a new `URLParametersData` encoder with given destination.
        ///
        /// - Parameters:
        ///   - destination: destination of the url produced.
        ///   - parameters: parameters to encode.
        ///   - boolEncoding: Specify how boolean values are encoded into the request.
        ///                   The default behaviour is `asNumbers` where `true=1`, `false=0`.
        ///   - arrayEncoding: Specify how array parameter's value are encoded into the request.
        ///                    By default the `withBrackets` option is used and array are encoded as `key[]=value`.
        internal init(_ parameters: HTTPRequestParametersDict?,
                      boolEncoding: BoolEncodingStyle = .asNumbers,
                      arrayEncoding: ArrayEncodingStyle = .withBrackets) {
            self.parameters = parameters
            self.arrayEncoding = arrayEncoding
            self.boolEncoding = boolEncoding
        }

        // MARK: - Encoding

        public func serializeData() async throws -> (data: Data, additionalHeaders: HTTPHeaders?) {
            guard let parameters = self.parameters, parameters.isEmpty == false else {
                return (Data(), nil) // no parameters set
            }

            let data = encodeParameters(parameters).data(using: .utf8) ?? Data()
            return (data, nil)
        }

        // MARK: - Private Functions

        /// Encode parameters passed and produce a final string.
        ///
        /// - Parameter parameters: parameters.
        /// - Returns: String encoded
        private func encodeParameters(_ parameters: [String: Any]) -> String {
            var components: [(String, String)] = []

            for key in parameters.keys.sorted(by: <) {
                let value = parameters[key]!
                components += encodeKey(key, withValue: value)
            }

            return components.map {
                "\($0)=\($1)"
            }.joinedWithAmpersands()
        }

        /// Create a dictionary with all the keys of value from params.
        ///
        /// - Returns: [String: String]
        internal func encodedParametersToDictionary() -> [String: String] {
            guard let parameters = self.parameters, parameters.isEmpty == false else {
                return [:]
            }

            var components: [String: String] = [:]

            for key in parameters.keys.sorted(by: <) {
                let value = parameters[key]!
                let results = encodeKey(key, withValue: value)
                for result in results {
                    components[result.0] = result.1
                }
            }

            return components
        }

        /// Encode a single object according to settings.
        ///
        /// - Parameters:
        ///   - key: key of the object to encode.
        ///   - value: value to encode.
        /// - Returns: list of encoded components
        private func encodeKey(_ key: String, withValue value: Any) -> [(String, String)] {
            var allComponents: [(String, String)] = []

            switch value {
                // Encode a Dictionary
            case let dictionary as [String: Any]:
                for (innerKey, value) in dictionary {
                    allComponents += encodeKey("\(key)[\(innerKey)]", withValue: value)
                }

                // Encode an Array
            case let array as [Any]:
                array.forEach {
                    allComponents += encodeKey(arrayEncoding.encode(key), withValue: $0)
                }

                // Encode a Number
            case let number as NSNumber:
                if number.isBool {
                    allComponents += [(key.queryEscaped, boolEncoding.encode(number.boolValue).queryEscaped)]
                } else {
                    allComponents += [(key.queryEscaped, "\(number)".queryEscaped)]
                }

                // Encode a Boolean
            case let bool as Bool:
                allComponents += [(key.queryEscaped, boolEncoding.encode(bool).queryEscaped)]

            default:
                allComponents += [(key, "\(value)")]

            }

            return allComponents
        }
    }

}

// MARK: - HTTPRequestBuilder (ArrayEncoding, BoolEncoding)
extension HTTPBody.URLParametersData {

    /// Configure how arrays objects must be encoded in a request.
    ///
    /// - `withBrackets`: An empty set of square brackets is appended to the key for every value.
    /// - `noBrackets`: No brackets are appended. The key is encoded as is.
    public enum ArrayEncodingStyle {
        case withBrackets
        case noBrackets

        internal func encode(_ key: String) -> String {
            switch self {
            case .withBrackets: return "\(key)[]"
            case .noBrackets:   return key
            }
        }
    }

    /// Configures how `Bool` parameters are encoded in a requext.
    ///
    /// - `asNumbers`:  Encode `true` as `1`, `false` as `0`.
    /// - `asLiterals`: Encode `true`, `false` as string literals.
    public enum BoolEncodingStyle {
        case asNumbers
        case asLiterals

        internal func encode(_ value: Bool) -> String {
            switch self {
            case .asNumbers:    return value ? "1" : "0"
            case .asLiterals:   return value ? "true" : "false"
            }
        }

    }

}
