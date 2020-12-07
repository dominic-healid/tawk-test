//
//  REST.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/3/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import UIKit

public enum NetworkingError: Error {
    /// Indicates the server responded with an unexpected status code.
    /// - parameter Int: The status code the server respodned with.
    /// - parameter Data?: The raw returned data from the server
    case unexpectedStatusCode(Int, Data?)

    /// Indicates that the server responded using an unknown protocol.
    /// - parameter Data?: The raw returned data from the server
    case badResponse(Data?)

    /// Indicates the server's response could not be deserialized using the given Deserializer.
    /// - parameter Data: The raw returned data from the server
    /// - parameter Error?: The original system error (like a DecodingError, etc) that caused the malformedResponse to trigger
    case malformedResponse(Data, Error?)

    /// Inidcates the server did not respond to the request.
    case noResponse
}

/// Options for `REST` calls. Allows you to set an expected HTTP status code, HTTP Headers, or to modify the request timeout.
public struct RestOptions {
    /// The expected status call for the call, defaults to allowing any.
    public var expectedStatusCode: Int?

    /// An optional set of HTTP Headers to send with the call.
    public var httpHeaders: [String : String]?

    /// The amount of time in `seconds` until the request times out.
    public var requestTimeoutSeconds = REST.kDefaultRequestTimeout

    public init() {}
}

public class REST : NSObject, URLSessionDelegate {

    fileprivate static let kDefaultRequestTimeout = 60 as TimeInterval
    private static let kPostType = "POST"
    private static let kPatchType = "PATCH"
    private static let kGetType = "GET"
    private static let kPutType = "PUT"
    private static let kDeleteType = "DELETE"
    private static let kJsonType = "application/json"
    private static let kContentType = "Content-Type"
    private static let kAcceptKey = "Accept"

    private let url: URL
    private var session: URLSession

    public var acceptSelfSignedCertificate = false

    private init(url: URL) {
        self.url = url
        self.session = Foundation.URLSession.shared
    }

    public static func make(urlString: String) -> REST? {
        if let validURL = URL(string: urlString) {
            return make(url: validURL)
        }

        return nil
    }

    public static func make(url: URL) -> REST {
        let rest = REST(url: url)
        rest.session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: rest, delegateQueue: nil)
        return rest
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if(acceptSelfSignedCertificate && challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust && challenge.protectionSpace.host == url.host) {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential);
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    private func dataTask(relativePath: String?, httpMethod: String, accept: String, payload: Data?, options: RestOptions, callback: @escaping (Result<Data>, HTTPURLResponse?) -> ()) throws {
        let restURL: URL;
        if let relativeURL = relativePath {
            restURL = url.appendingPathComponent(relativeURL)
        } else {
            restURL = url
        }

        var request = URLRequest(url: restURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: options.requestTimeoutSeconds)
        request.httpMethod = httpMethod

        request.setValue(accept, forHTTPHeaderField: REST.kAcceptKey)
        if let customHeaders = options.httpHeaders {
            for (httpHeaderKey, httpHeaderValue) in customHeaders {
                request.setValue(httpHeaderValue, forHTTPHeaderField: httpHeaderKey)
            }
        }

        if let payloadToSend = payload {
            request.setValue(REST.kJsonType, forHTTPHeaderField: REST.kContentType)
            request.httpBody = payloadToSend
        }

        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }

        session.dataTask(with: request) { (data, response, error) -> Void in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
                                         
            if let err = error {
                callback(.failure(err), nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                callback(.failure(NetworkingError.badResponse(data)), nil)
                return
            }

            if let expectedStatusCode = options.expectedStatusCode, httpResponse.statusCode != expectedStatusCode {
                callback(.failure(NetworkingError.unexpectedStatusCode(httpResponse.statusCode, data)), httpResponse)
                return
            }

            guard let returnedData = data else {
                callback(.failure(NetworkingError.noResponse), httpResponse)
                return
            }
            
            APIRequestCacheManager.cacheData(returnedData, withKey: self.url.absoluteString)
            callback(.success(returnedData), httpResponse)
        }.resume()
    }

    private func makeCall<T: Deserializer>(_ relativePath: String?, httpMethod: String, payload: Data?, responseDeserializer: T, options: RestOptions, callback: @escaping (Result<T.ResponseType>, HTTPURLResponse?) -> ()) {
        do {
            try dataTask(relativePath: relativePath, httpMethod: httpMethod, accept: responseDeserializer.acceptHeader, payload: payload, options: options) { (result, httpResponse) -> () in
                do {
                    let data = try result.value()
                    let transformedResponse = try responseDeserializer.deserialize(data)
                    callback(.success(transformedResponse), httpResponse)
                } catch {
                    callback(.failure(error), httpResponse)
                }
            }
        } catch {
            callback(.failure(error), nil)
        }
    }
    
    public func get<T: Deserializer>(withDeserializer responseDeserializer: T, at relativePath: String? = nil, options: RestOptions = RestOptions(), callback: @escaping (Result<T.ResponseType>, HTTPURLResponse?) -> ()) {
        
        APIRequestCacheManager.shouldGetCache(self.url.absoluteString) { (isCache, response) in
            guard let response = response else {
                self.makeCall(relativePath, httpMethod: REST.kGetType, payload: nil, responseDeserializer: responseDeserializer, options: options, callback: callback)
                return
            }
            do {

                let transformedResponse = try responseDeserializer.deserialize(response)
                callback(.success(transformedResponse), nil)
            } catch {
                callback(.failure(error), nil)
            }
        }
    }
    
    public func get<D: Decodable>(_ type: D.Type, at relativePath: String? = nil, options: RestOptions = RestOptions(), callback: @escaping (Result<D>, HTTPURLResponse?) -> ()) {
        APIRequestCacheManager.shouldGetCache(self.url.absoluteString) { (isCache, response) in
            let decodableDeserializer = DecodableDeserializer<D>()
            guard let response = response else {
                self.makeCall(relativePath, httpMethod: REST.kGetType, payload: nil, responseDeserializer: decodableDeserializer, options: options, callback: callback)
                return
            }
            do {

                let transformedResponse = try decodableDeserializer.deserialize(response)
                callback(.success(transformedResponse), nil)
            } catch {
                callback(.failure(error), nil)
            }
        }
        
    }
    
}
