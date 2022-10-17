//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by GAUTAM TIWARI on 12/10/22.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        //Asseting order, quality and count if we compare two arrays
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    
    //Stub means inserting fake values -
    //Capturing means collecting values coming
    func test_load_deliversErrorOnClientError() {
        //Arrange
        let (sut, client) = makeSUT()
        //        client.error = NSError(domain: "Test", code: 0) //Stubbed the client even though our client is spy
        
        //Act
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load {
            capturedErrors.append($0)
        }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        //Assert
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPError() {
        //Arrange
        let (sut, client) = makeSUT()
        //        client.error = NSError(domain: "Test", code: 0) //Stubbed the client even though our client is spy
        
        //Act
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load {
                capturedErrors.append($0)
            }
            
            client.complete(withStatusCode: code, at: index)
            
            //Assert
            XCTAssertEqual(capturedErrors, [.invalidData])
            
            capturedErrors = []
        }
        
    }
    
    //MARK: Helpers
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut:RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs : [URL] {
            return message.map { $0.url }
        }
        
        private var message = [(url: URL, completion: (Error?, HTTPURLResponse?)-> Void)]()
        
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?)-> Void) {
            message.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            message[index].completion(error, nil)
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode:code,
                                           httpVersion: nil,
                                           headerFields: nil)
            
            message[index].completion(nil, response)
        }
    }
    
}
