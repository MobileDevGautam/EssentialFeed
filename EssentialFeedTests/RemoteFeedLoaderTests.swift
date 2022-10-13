//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by GAUTAM TIWARI on 12/10/22.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.getFrom(from: URL(string: "http://a-url.com")!)
    }
}

class HTTPClient {
    
    static var shared = HTTPClient()
    
    func getFrom(from url: URL) { }
}

class HTTPClientSpy: HTTPClient {
    
    override func getFrom(from url: URL) {
        self.requestedURL = url
    }
    
    var requestedURL: URL?

}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesnNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client

        
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
