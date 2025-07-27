//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by GAUTAM TIWARI on 12/10/22.
//

import Foundation

// MARK: - Feed Loading
public enum FeedLoaderResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResult) -> Void)
}
