//
//  Endpoint.swift
//  App
//
//  Created by Fatah on 20/02/19.
//

import Foundation
import Alamofire

public class Endpoint<R>: ResponseRequestable {
    public typealias Response = R

    public var path: String
    public var isFullPath: Bool
    public var method: HTTPMethodType
    public var headerParamaters: [String: String]
    public var queryParametersEncodable: Encodable?
    public var queryParameters: [String: Any]
    public var bodyParamatersEncodable: Encodable?
    public var bodyParamaters: [String: Any]
    public var multipartParameters: [String: Data]
    public var bodyEncoding: BodyEncoding
    public var responseDecoder: ResponseDecoder

    public init(path: String,
         isFullPath: Bool = false,
         method: HTTPMethodType,
         headerParamaters: [String: String] = [:],
         queryParametersEncodable: Encodable? = nil,
         queryParameters: [String: Any] = [:],
         bodyParamatersEncodable: Encodable? = nil,
         bodyParamaters: [String: Any] = [:],
         multipartParameters: [String: Data] = [:],
         bodyEncoding: BodyEncoding = .jsonSerializationData,
         responseDecoder: ResponseDecoder = JSONResponseDecoder()) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParamaters = headerParamaters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParamatersEncodable = bodyParamatersEncodable
        self.bodyParamaters = bodyParamaters
        self.multipartParameters = multipartParameters
        self.bodyEncoding = bodyEncoding
        self.responseDecoder = responseDecoder
    }
}
