//
//  CredentialSecurity.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

// MARK: - HTTPSecurity Protocol
/// This protocol allows you to customize the logic to handle custom authentication styles.
public protocol HTTPSecurityService {

    /// Receive challange for authentication.
    ///
    /// - Parameters:
    ///   - challenge: challange.
    ///   - request: request.
    ///   - task: task associated with request.
    ///   - completionHandler: completion handler.
    func receiveChallenge(
        _ challenge: URLAuthenticationChallenge,
        forRequest request: HTTPRequest, task: URLSessionTask,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
}

/// This a concrete class of the `CredentialSecurity` which allows you to perform
/// authenticated session using the `URLSession`'s `URLAuthenticationChallenge`.
public struct CredentialSecurity: HTTPSecurityService {
    public typealias AuthenticationCallback = ((URLAuthenticationChallenge) -> URLCredential?)

    // MARK: - Public Properties

    /// Callback for credentials based authorization.
    public var callback: AuthenticationCallback

    // MARK: - Initialization

    /// Initialize a new credentials security with callback for authentication.
    ///
    /// - Parameter callback: callback.
    public init(_ callback: @escaping AuthenticationCallback) {
        self.callback = callback
    }

    // MARK: - Conformance
    public func receiveChallenge(
        _ challenge: URLAuthenticationChallenge,
        forRequest request: HTTPRequest,
        task: URLSessionTask, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard 
            let cred = callback(challenge) else {
            completionHandler(.rejectProtectionSpace, nil)
            return
        }
        completionHandler(.useCredential, cred)
    }
}
