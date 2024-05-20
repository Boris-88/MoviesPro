//
//  BaseClient.swift
//  VKClone
//
//  Created by Boris Zverik on 16.04.2024.
//

import Foundation
import Security

open class BaseClient<Target: TargetType> {
    
    public init() {}
    
    open func request(target: Target) -> HTTPRequest {
        return try! HTTPRequest(
            method: target.method,
            target.baseURL.appendingPathComponent(target.path),
            body: target.body
        )
    }
    
    open func fetch<Model: Decodable>(target: Target) async throws -> Model {
        let request = request(target: target)
        guard let response = try? await request.fetch(Model.self) else {
            throw HTTPError(.objectDecodeFailed, message: "Can't decode entity \(Model.self) for target \(Target.self)")
        }
        return response
    }
    
    open func fetch(target: Target) async throws {
        try await request(target: target).fetch()
    }
}
