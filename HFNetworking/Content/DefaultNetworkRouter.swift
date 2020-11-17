//
//  NetworkService.swift
//  NetworkModule
//
//  Created by Fatah on 13/11/20.
//

import Foundation
import Alamofire

struct SessionManagerOption {
    let foreground = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
    let background = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier).background-session"))
}

public class DefaultNetworkRouter {
    private let limitUpload: Int
    private let sessionManager = SessionManagerOption.init()
    private let config: NetworkConfigurable

    public init(limitUpload: Int = 5, config: NetworkConfigurable) {
        self.limitUpload = limitUpload
        self.config = config
    }
}

extension DefaultNetworkRouter: NetworkRouter {
    public func request<T, E>(with endpoint: E, completion: @escaping (NetworkResponse<T>) -> Void) where T: Decodable, T == E.Response, E: ResponseRequestable {
        do {
            let urlRequestContainer = try endpoint.urlRequest(with: config)
            let task = sessionManager.foreground.request(urlRequestContainer.urlRequest).responseJSON { (response) in
                switch response.result {
                case .success:
                    let result: NetworkResponse<T> = self.decode(data: response.data, decoder: endpoint.responseDecoder)
                    completion(result)
                case .failure(let error):
                    Logger.errorPrint(error.localizedDescription)
                    completion(.failure(NetworkServiceError.networkFailure))
                }
            }
        } catch {
            Logger.errorPrint(error.localizedDescription)
            completion(.failure(NetworkServiceError.urlGeneration))
        }
    }

    public func upload<T, E>(with endpoint: E, completion: @escaping (NetworkResponse<T>) -> Void) where T: Decodable, T == E.Response, E: ResponseRequestable {
        do {
            let urlRequestContainer = try endpoint.urlRequest(with: config, upload: true)
            let task = sessionManager.foreground.upload(multipartFormData: { (multipart) in
                for (key, value) in urlRequestContainer.updatedBodyParam {
                    multipart.append("\(value)".data(using: .utf8)!, withName: key) // TODO: handle force
                }

                for uploadData in urlRequestContainer.uploadData {
                    // TODO: filename and mimetypes are generic, should we do something about it?
                    multipart.append(uploadData.value, withName: uploadData.key, fileName: UUID().uuidString, mimeType: "application/octet-stream")
                }
            }, usingThreshold: UInt64.init(),
               to: urlRequestContainer.urlRequest.url!, // TODO: handle force
                method: HTTPMethod(rawValue: urlRequestContainer.urlRequest.httpMethod!)!, // TODO: handle force
                headers: urlRequestContainer.urlRequest.allHTTPHeaderFields,
                queue: nil) { (encodingResult) in
                switch encodingResult {
                case .success(let request, let streamingFromDisk, let streamFileURL):
                    request.uploadProgress { (progress) in
                        completion(.onProgress(progress: progress))
                    }

                    request.responseJSON { (response) in
                        switch response.result {
                        case .success:
                            Logger.networkLogger(request: urlRequestContainer.urlRequest, response: response.data)
                            let result: NetworkResponse<T> = self.decode(data: response.data, decoder: endpoint.responseDecoder)
                            completion(result)
                        case .failure(let error):
                            Logger.errorPrint(error.localizedDescription)
                            completion(.failure(NetworkServiceError.parsing(error)))
                        }
                    }
                case .failure(let error):
                    Logger.errorPrint(error.localizedDescription)
                    completion(.failure(NetworkServiceError.multipartCreation))
                }
            }
        } catch {
            Logger.errorPrint(error.localizedDescription)
            completion(.failure(NetworkServiceError.urlGeneration))
        }
    }

    // MARK: - Private
    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> NetworkResponse<T> {
        do {
            guard let data = data else { return .failure(NetworkServiceError.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            Logger.errorPrint(error.localizedDescription)
            return .failure(NetworkServiceError.parsing(error))
        }
    }
}
