//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by GAUTAM TIWARI on 12/10/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
