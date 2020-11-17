//
//  NetworkRouter.swift
//  NetworkModule
//
//  Created by Fatah on 17/11/20.
//

import Foundation

public enum NetworkServiceError: Error {
    case serverRelated
    case urlGeneration
    case noResponse // = "Response returned with no data to decode."
    case multipartCreation
    case parsing(Error)
    case networkFailure
    case undetermined
}

public enum NetworkResponse<T> {
    case success(T)
    case failure(Error)
    case onProgress(progress: Progress)
}

public protocol NetworkRouter {
    typealias CompletionHandler<T> = (NetworkResponse<T>) -> Void

    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(with endpoint: E, completion: @escaping CompletionHandler<T>) where E.Response == T

    @discardableResult
    func upload<T: Decodable, E: ResponseRequestable>(with endpoint: E, completion: @escaping CompletionHandler<T>) where E.Response == T
}
