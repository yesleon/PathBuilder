//
//  File.swift
//  
//
//  Created by 許立衡 on 2021/3/12.
//

import Foundation
import Combine

extension URL: PathComponentAppending { }

extension URLRequest: PathComponentAppending {
    
    public func appendingPathComponent(_ pathComponent: String) -> URLRequest {
        var request = self
        request.url?.appendPathComponent(pathComponent)
        return request
    }
}

@available(iOS 13.0, OSX 10.15, *)
public protocol DecodableEndpoint: Endpoint {
    associatedtype Value: Decodable
    associatedtype Decoder: TopLevelDecoder where Decoder.Input == Data
    static var defaultDecoder: Decoder { get }
}

public extension URLSession {
    
    @available(iOS 13.0, OSX 10.15, *)
    func decodedDataTask<E: DecodableEndpoint>(
        with endpoint: PathBuilder<URL, E>,
        completionHandler: @escaping (E.Value?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        
        let url = endpoint.build()
        return dataTask(with: url) { data, response, error in
            do {
                let decoder = E.defaultDecoder
                let value = try data.map { try decoder.decode(E.Value.self, from: $0) }
                completionHandler(value, response, error)
            } catch {
                completionHandler(nil, response, error)
            }
        }
    }
    
    @available(iOS 13.0, OSX 10.15, *)
    func decodedDataTask<E: DecodableEndpoint>(
        with endpoint: PathBuilder<URLRequest, E>,
        completionHandler: @escaping (E.Value?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        
        let request = endpoint.build()
        return dataTask(with: request) { data, response, error in
            do {
                let decoder = E.defaultDecoder
                let value = try data.map { try decoder.decode(E.Value.self, from: $0) }
                completionHandler(value, response, error)
            } catch {
                completionHandler(nil, response, error)
            }
        }
    }
    
    @available(iOS 13.0, OSX 10.15, *)
    func decodedDataTaskPublisher<E: DecodableEndpoint>(
        for endpoint: PathBuilder<URL, E>
    ) -> Publishers.Decode<Publishers.MapKeyPath<URLSession.DataTaskPublisher, Data>, E.Value, E.Decoder> {
        
        let url = endpoint.build()
        return dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: E.Value.self, decoder: E.defaultDecoder)
    }
    
    @available(iOS 13.0, OSX 10.15, *)
    func decodedDataTaskPublisher<E: DecodableEndpoint>(
        for endpoint: PathBuilder<URLRequest, E>
    ) -> Publishers.Decode<Publishers.MapKeyPath<URLSession.DataTaskPublisher, Data>, E.Value, E.Decoder> {
        
        let request = endpoint.build()
        return dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: E.Value.self, decoder: E.defaultDecoder)
    }
}
