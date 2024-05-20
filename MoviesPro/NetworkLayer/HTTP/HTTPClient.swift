//
//  HTTPClient.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

final public class HTTPClient: NSObject {

    /// Shared HTTPClient instance.
    public static let shared = HTTPClient(baseURL: nil)

    /// Base URL used to compose each request.
    ///
    /// NOTE:
    /// If request is executed by passing a complete URL with scheme this
    /// value will be automatically ignored.
    public var baseURL: URL?

    /// URLSessionConfiguration used by the HTTP client to perform requests.
    public var session: URLSession {
        loader.session
    }

    /// The cache policy for the request. Defaults to `.useProtocolCachePolicy`.
    /// Requests may override this behaviour.
    public var cachePolicy: URLRequest.CachePolicy {
        get { loader.cachePolicy }
        set { loader.cachePolicy = newValue }
    }

    public var redirectMode: HTTPRequest.RedirectMode = .follow

    /// Validators for response. Values are executed in order.
    public var validators: [HTTPValidator] = [
        HTTPDefaultValidator() // standard validator for http responses
    ]

    /// Allows to set the transformer applied to each response executed by the client.
    public var responseTransformers: [HTTPResponseTransform] = []

    /// Headers which are automatically attached to each request.
    public var headers = HTTPHeaders()

    /// A list of query params values which will be appended to each request.
    public var queryParams: [URLQueryItem] = []

    /// Timeout interval for requests, expressed in seconds.
    /// The default value is HTTPRequest.DefaultTimeout but another option may be assigned.
    public var timeout: TimeInterval = HTTPRequest.DefaultTimeout

    /// Security settings.
    public var security: HTTPSecurity?

    // MARK: - Private Properties

    /// Event monitor used to execute http requests.
    private var loader: HTTPDataLoader

    public init(
        baseURL: URL?,
        maxConcurrentOperations: Int? = nil,
        configuration: URLSessionConfiguration = .default
    ) {
        self.baseURL = baseURL
        self.loader = HTTPDataLoader(
            configuration: configuration,
            maxConcurrentOperations: maxConcurrentOperations ?? OperationQueue.defaultMaxConcurrentOperationCount
        )
        super.init()
        self.loader.client = self
    }

    // MARK: - Internal Functions

    /// Executes the request and returns the promise.
    ///
    /// - Parameter request: HTTP request to be executed.
    /// - Returns: HTTP response
    internal func fetch(_ request: HTTPRequest) async throws -> HTTPResponse {
        try await loader.fetch(request)
    }

    /// Validate the response using the ordered list of validators.
    ///
    /// - Parameters:
    ///   - response: response received from server.
    ///   - request: origin request.
    /// - Returns: HTTPResponseValidatorAction
    internal func validate(response: HTTPResponse, forRequest request: HTTPRequest) -> HTTPResponseValidatorResult {
        for validator in validators {
            let result = validator.validate(response: response, forRequest: request)
            guard case .nextValidator = result else {
                return result
            }
        }

        return .nextValidator
    }
}

extension HTTPClient: URLSessionDelegate {

}
