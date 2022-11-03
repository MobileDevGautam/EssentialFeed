//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by GAUTAM TIWARI on 12/10/22.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    
    associatedtype Error: Swift.Error
    func load(completion: @escaping(LoadFeedResult<Error>) -> Void)
    
}
