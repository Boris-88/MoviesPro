//
//  HTTPSecurity.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

public enum HTTPSecurity {
    case acceptSelfSigned
    case credentials(CredentialSecurity.AuthenticationCallback)
    case certs(_ certs: [SSLCertificate], usePublicKeys: Bool)
    case bundledCerts(_ dir: String = ".", usePublicKeys: Bool)
    case custom(HTTPSecurityService)

    /// Returns the conformance classes for security option.
    ///
    /// - Returns: `HTTPSecurityProtocol`
    internal func getService() -> HTTPSecurityService {
        switch self {
        case .acceptSelfSigned:
            return SelfSignedCertsSecurity()
        case let .credentials(callback):
            return CredentialSecurity(callback)
        case let .certs(certs, usePublicKeys):
            return CertificatesSecurity(certificates: certs, usePublicKeys: usePublicKeys)
        case let .bundledCerts(dir, usePublicKeys):
            return CertificatesSecurity(bundledIn: dir, usePublicKeys: usePublicKeys)
        case let .custom(custom):
            return custom
        }
    }
}
