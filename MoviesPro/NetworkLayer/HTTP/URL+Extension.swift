//
//  URL+Extension.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

// MARK: - Array String
extension Array where Element == String {

    internal func joinedWithAmpersands() -> String {
        joined(separator: "&")
    }
}

// MARK: - Data
extension Data {

    /// Write to temporary file location.
    ///
    /// - Returns: URL
    internal func writeToTemporaryFile() -> URL? {
        do {
            let fileURL = FileManager.default.temporaryFileLocation()
            try write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
}

extension URL {

    /// Return suggested mime type for file at given URL.
    ///
    /// - Returns: String
    public func mimeType() -> String {
        self.pathExtension.suggestedMimeType()
    }

    // MARK: - Public Functions
    /// Returns the base URL string build with the scheme, host and path.
    /// For example:
    /// "https://www.apple.com/v1/test?param=test"
    /// would be "https://www.apple.com/v1/test"
    public var baseString: String? {
        guard let scheme = scheme, let host = host else { return nil }
        return scheme + "://" + host + path
    }

    // MARK: - Internal Functions

    /// Copy the temporary file for location in a non deletable path.
    ///
    /// - Parameters:
    ///   - task: task.
    ///   - request: request.
    /// - Returns: URL?
    internal func copyFileToDefaultLocation(task: URLSessionDownloadTask,
                                            forRequest request: HTTPRequest) -> URL? {

        let destinationURL = FileManager.default.temporaryFileLocation()
        do {
            try FileManager.default.copyItem(at: self, to: destinationURL)
            return destinationURL
        } catch {
            return nil
        }
    }

}

// MARK: - FileManager
extension FileManager {

    internal func temporaryFileLocation() -> URL {
        let fileName = UUID().uuidString
        let documentsDir = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first! as NSString
        let destinationURL = URL(fileURLWithPath: documentsDir.appendingPathComponent(fileName))
        return destinationURL
    }

}

import MobileCoreServices

// MARK: - String Extension
extension String {

    // MARK: - Public Properties

    /// Create an RFC 3986 compliant string used to compose query string in URL.
    ///
    /// - Parameter string: source string.
    /// - Returns: String
    public var queryEscaped: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }

    /// Return `true` if it's a valid full URL, `false` if it's relative URL.
    internal var isAbsoluteURL: Bool {
        if hasPrefix("localhost") {
            return true
        }

        let regEx = #"(\b(https?|file):\/\/)?[-A-Za-z0-9+&@#\/%?=~_|!:,.;]+[-A-Za-z0-9+&@#\/%=~_|]"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
        return predicate.evaluate(with: self)
    }

    /// Return the suggested mime type for path extension of the receiver.
    ///
    /// - Returns: String
    internal func suggestedMimeType() -> String {
        if let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue() {
            return contentType as String
        }

        return HTTPContentType.octetStream.rawValue
    }
}

// MARK: - NSNumber Extension
extension NSNumber {

    internal var isBool: Bool {
        String(cString: objCType) == "c"
    }

}
