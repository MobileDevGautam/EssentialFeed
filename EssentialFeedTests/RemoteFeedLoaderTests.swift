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
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPError() {
        //Arrange
        let (sut, client) = makeSUT()
        //        client.error = NSError(domain: "Test", code: 0) //Stubbed the client even though our client is spy
        
        //Act
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErroron200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("Invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithAnEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([FeedItem]()), when: {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversIetmsOn200HTTPResponseWithJSOnItems() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "http://a-url.com")!)
        
        let item1JSON = [
            "id": item1.id.uuidString,
            "image" : item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "http://another-url.com")!)
        
        let item2JSON = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image" : item2.imageURL.absoluteString
        ]
        
        let itemsJSON = [
            "items": [item1JSON, item2JSON]
        ]
        
        expect(sut, toCompleteWith: .success([item1, item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatusCode: 200, data: json)
        }
        
    }

    //MARK: Helpers
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut:RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Results, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedResults = [RemoteFeedLoader.Results]()
        sut.load {
            capturedResults.append($0)
        }
        
        action()
        //Assert
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs : [URL] {
            return message.map { $0.url }
        }
        
        private var message = [(url: URL, completion: (HTTPClientResults)-> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResults) -> Void) {
            message.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            message[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode:code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            message[index].completion(.success(data, response))
        }
    }
    
}
