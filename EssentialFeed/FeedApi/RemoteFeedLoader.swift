//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by GAUTAM TIWARI on 14/10/22.
//

import Foundation

public enum HTTPClientResults {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResults) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Results: Equatable {
        case success([FeedItem])
        case failure(RemoteFeedLoader.Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Results) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.failure(.invalidData))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}


