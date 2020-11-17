//
//  ResponseRequestable.swift
//  NetworkModule
//
//  Created by Fatah on 17/11/20.
//

import Foundation

public enum HTTPMethodType: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

public enum BodyEncoding {
    case jsonSerializationData
    case stringEncodingAscii
}

public struct URLRequestContainer {
    public let urlRequest: URLRequest
    public let uploadData: [String: Data]
    public let updatedBodyParam: [String: Any]
}

extension URLRequestContainer {
    init(urlRequest: URLRequest) { // default implementation
        self.init(urlRequest: urlRequest, uploadData: [:], updatedBodyParam: [:])
    }
}

public protocol Requestable {
    typealias updatedBodyParam = (uploadData: [String: Data], updatedBodyParam: [String: Any])

    var path: String { get }
    var isFullPath: Bool { get }
    var method: HTTPMethodType { get }
    var headerParamaters: [String: String] { get }
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    var bodyParamatersEncodable: Encodable? { get }
    var multipartParameters: [String: Data] { get }
    var bodyParamaters: [String: Any] { get }
    var bodyEncoding: BodyEncoding { get }

    func urlRequest(with config: NetworkConfigurable, upload: Bool) throws -> URLRequestContainer
}

public protocol ResponseRequestable: Requestable {
    associatedtype Response

    var responseDecoder: ResponseDecoder { get }
}

enum RequestGenerationError: Error {
    case components
}

// default implementation
extension Requestable {
    private func url(with config: NetworkConfigurable) throws -> URL {
        let baseURL = config.baseURL.absoluteString.last != "/" ? config.baseURL.absoluteString + "/" : config.baseURL.absoluteString
        let endpoint = isFullPath ? path : baseURL.appending(path)

        guard var urlComponents = URLComponents(string: endpoint) else { throw RequestGenerationError.components }
        var urlQueryItems = [URLQueryItem]()

        let queryParameters = try queryParametersEncodable?.toDictionary() ?? self.queryParameters
        queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil

        guard let url = urlComponents.url else { throw RequestGenerationError.components }
        return url
    }

    private func encodeBody(bodyParamaters: [String: Any], bodyEncoding: BodyEncoding) -> Data? {
        switch bodyEncoding {
        case .jsonSerializationData:
            return try? JSONSerialization.data(withJSONObject: bodyParamaters)
        case .stringEncodingAscii:
            return bodyParamaters.queryString.data(using: String.Encoding.ascii, allowLossyConversion: true)
        default:
            return nil
        }
    }

    private func extractDataFromBodyParam(_ bodyParam: [String: Any]) -> updatedBodyParam { // TODO: naming
        var uploadData: [String: Data] = [:]
        var updatedBodyParam: [String: Any] = [:]

        for (key, value) in bodyParam {
            if let valueAsString = value as? String, valueAsString.count > 100, let data = Data(base64Encoded: valueAsString) {
                uploadData[key] = data
            } else {
                updatedBodyParam[key] = value
            }
        }

        return (uploadData, updatedBodyParam)
    }

    public func urlRequest(with config: NetworkConfigurable, upload: Bool = false) throws -> URLRequestContainer {
        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders

        headerParamaters.forEach { allHeaders.updateValue($1, forKey: $0) }

        let bodyParamaters = try bodyParamatersEncodable?.toDictionary() ?? self.bodyParamaters
        if !bodyParamaters.isEmpty && upload {
            // TODO: naming
            let param = extractDataFromBodyParam(bodyParamaters)

            return URLRequestContainer(urlRequest: urlRequest, uploadData: param.uploadData, updatedBodyParam: param.updatedBodyParam)
        } else if !bodyParamaters.isEmpty {
            if !bodyParamaters.isEmpty {
                urlRequest.httpBody = encodeBody(bodyParamaters: bodyParamaters, bodyEncoding: bodyEncoding)
            }
        }

        return URLRequestContainer(urlRequest: urlRequest)
    }
}

private extension Dictionary {
    var queryString: String {
        return self.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}

private extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let josnData = try JSONSerialization.jsonObject(with: data)
        return josnData as? [String: Any]
    }
}
