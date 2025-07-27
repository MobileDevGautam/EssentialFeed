//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by GAUTAM TIWARI on 25/10/22.
//

import Foundation

// MARK: - HTTP Client
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success((Data, HTTPURLResponse))
    case failure(Error)
}
