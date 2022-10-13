//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by GAUTAM TIWARI on 12/10/22.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.getFrom(from: URL(string: "http://a-url.com")!)
    }
}

protocol HTTPClient {
    func getFrom(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    
    func getFrom(from url: URL) {
        self.requestedURL = url
    }
    
    var requestedURL: URL?

}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesnNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
