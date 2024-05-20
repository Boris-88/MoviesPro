//
//  RWLock.swift
//  HTTP
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation

internal class RWLock {

    // MARK: - Private Properties
    private let queue = DispatchQueue(label: Bundle.main.bundleIdentifier ?? "", attributes: .concurrent)

    // MARK: - Public Functions
    func concurrentlyRead<T>(_ block: (() throws -> T)) rethrows -> T {
        return try queue.sync {
            try block()
        }
    }

    func exclusivelyWrite(_ block: @escaping (() -> Void)) {
        queue.async(flags: .barrier) {
            block()
        }
    }

}
