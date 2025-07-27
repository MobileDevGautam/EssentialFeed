//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by GAUTAM TIWARI on 25/10/22.
//

import Foundation

// MARK: - Feed Items Mapper
internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feedItems: [FeedItem] {
            items.map { $0.feedItem }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }
    
    private static var OK_200: Int { 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoaderResult {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feedItems)
    }
}
