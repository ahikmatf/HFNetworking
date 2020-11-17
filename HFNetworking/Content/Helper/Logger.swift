//
//  Logger.swift
//  NetworkModule
//
//  Created by Fatah on 11/11/20.
//

import Foundation

class Logger {
    static func debugPrint(_ text: String) {
        print("[NetworkModule] \(text)")
    }

    static func errorPrint(_ text: String) {
        print("[NetworkModule] Error: \(text)")
    }

    static func request(_ request: URLRequest) {
        print("\n ====> [NetworkModule] Request <==== \n")
        defer { print("\n ====> [NetworkModule] End Request <==== \n") }

        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)

        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"

        var logOutput = """
            \(urlAsString) \n\n
            \(method) \(path)?\(query) HTTP/1.1 \n
            HOST: \(host)\n
        """

        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }

        if let body = request.httpBody {
            logOutput += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }

        print(logOutput)
    }

    static func networkLogger(request: URLRequest, response: Data?) {
        print("\n ====> [NetworkModule] Response <==== \n")
        defer { print("\n ====> [NetworkModule] End Response <==== \n") }

        let urlAsString = request.url?.absoluteString ?? ""

        var responseMessage = ""
        if let responseData = response {
            responseMessage = Logger.toJsonString(responseData)
        }

        let logOutput = """
            URL: \(urlAsString) \n
            Response: \(responseMessage)
        """

        print(logOutput)
    }

    static func toJsonString(_ data: Data) -> String {
        guard let jsonString = String(data: data, encoding: .utf8) else { return "invalid json data" }

        return jsonString
    }
}
