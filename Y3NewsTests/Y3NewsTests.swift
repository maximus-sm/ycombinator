//
//  Y3NewsTests.swift
//  Y3NewsTests
//
//  Created by Sundet Mukhtar on 24.02.2025.
//

import Testing
@testable import Y3News
import XCTest
import OHHTTPStubs
import Combine

struct Y3NewsTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}


class UnitTests : XCTestCase {
    
    let viewModel = MainVM()
    var expectation: XCTestExpectation!
    var cancellables: Set<AnyCancellable>!
    

      override func setUpWithError() throws {
        try super.setUpWithError()
        expectation = XCTestExpectation(description: "wait for queue change")
        cancellables = Set<AnyCancellable>()
      }

      override func tearDownWithError() throws {
        cancellables = nil
        expectation = nil
        try super.tearDownWithError()
      }
    
    
    func testCrudCoreData() {
        //viewModel.container = PersistenceController(inMemory: true)
        let story = Story(id: 12345, title: "Test", by: "Me", time: Date.now.timeIntervalSince1970, url: "testing.com")
        
        viewModel.addToFavs(story: story)
        XCTAssert(viewModel.getFavs().count == 1)
        viewModel.addToFavs(story: story)
        XCTAssert(viewModel.getFavs().count == 1)
        
        XCTAssert(viewModel.getFavs().first!.title! == story.title)
        XCTAssert(viewModel.getFavs().first!.id == Int64(story.id))
        
        viewModel.removeFromFavs(by: story.id)
        //viewModel.removeFromFavs(story: viewModel.getFavs().first!)
        
        XCTAssert(viewModel.getFavs().isEmpty == true)
        
        // Arrange: create the necessary dependencies.
        // Act: call my API, using the dependencies created above.
        //XCTAssertTrue("The function didn't return the expected result")
    }
    
    
//    func testCombineAndNetwork() {
//        let networkmanager = NetworkManager(
//            MockURLSession(
//            data: FakeResponseData.correctData,
//            response: FakeResponseData.response200OK,
//            error: nil
//        ))
//        var stories: [Story] = []
//        networkmanager
//            .getNews()
//            .subscribe(on: DispatchQueue.main)
//            .sink (receiveCompletion: { completion in
//                self.expectation.fulfill()
//            }, receiveValue: { dump in
//                print(dump)
//                XCTAssertEqual(dump.count, 1)
//                stories = dump
//            })
//            .store(in: &cancellables)
//        
//        wait(for: [expectation], timeout: 0.8)
//        //XCTAssertEqual(stories.count, 1)
//    }
//    
    
//    func testNetworkCallWithCutomConfiguration() {
//        
//        let storyURL = NetworkManager.EndPoint.story(8863).url
//        let storiesURL = NetworkManager.EndPoint.category(.new).url
//        //print(storiesURL)
//        // attach that to some fixed data in our protocol handler
//        
//        let bundle = Bundle(for: UnitTests.self)
//            let fakeJsonURL = bundle.url(forResource: "mock1", withExtension: "json") // Add your fake json file name in here
//            let fakeJsonData = try! Data(contentsOf: fakeJsonURL!)
//        let sample = Data("""
//                {
//    "by" : "dhouston",
//    "descendants" : 71,
//    "id" : 8863,
//    "time" : 1175714200,
//    "title" : "My YC app: Dropbox - Throw away your USB drive",
//    "url" : "http://www.getdropbox.com/u/2/screencast.html"
//    }
//""".utf8)
//        URLProtocolMock.testURLs = [storyURL: fakeJsonData,
//                                  storiesURL: fakeJsonData]
//        
//
//        // now set up a configuration to use our mock
//        let config = URLSessionConfiguration.ephemeral
//        config.protocolClasses = [URLProtocolMock.self]
//
//        // and create the URLSession from that
//        let session = URLSession(configuration: config)
//        let netmanager = NetworkManager(session)
//        
//        netmanager
//            .story(id: 8863)
//            .subscribe(on: DispatchQueue.main)
//            .handleEvents( receiveOutput:{ story in
//                print("output \(story)")
//                XCTAssertNil(story)
//            }, receiveCompletion: { completion in
//                //self.expectation.fulfill()
//                print("completes with \(completion)")
//                //XCTAssertEqual(completion, ne, accuracy: <#T##FloatingPoint#>)
//            })
//            .sink(receiveCompletion: { _ in }, receiveValue: { story in
//                print("output \(story)")
//            })
//            .store(in: &cancellables)
//        
//        netmanager
//            .getNewsID(sortBy: .category(.new))
//            .subscribe(on: RunLoop.main)
//            .handleEvents( receiveOutput:{ stories in
//                XCTAssert(stories.isEmpty == false)
//                print("stories \(stories)")
//                print()
//            },receiveCompletion: { completion in
//                //self.expectation.fulfill()
//                print("completes with \(completion)")
//                //XCTAssertEqual(completion, ne, accuracy: )
//            })
//            .sink(receiveCompletion: { _ in }, receiveValue: { stories in
//                print("stories \(stories)")
//                print()
//                XCTAssert(stories.isEmpty == false)
//            })
//            .store(in: &cancellables)
//        
//        self.expectation.fulfill()
//        wait(for: [expectation], timeout: 0.1)
//    }
    
    
    
}


//// MARK: - Custom URLSession configuration(handler) for URLRequest.
//class URLProtocolMock: URLProtocol {
//    // this dictionary maps URLs to test data
//    static var testURLs = [URL?: Data]()
//
//    // say we want to handle all types of request
//    override class func canInit(with request: URLRequest) -> Bool {
//        return true
//    }
//
//    // ignore this method; just send back what we were given
//    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
//        return request
//    }
//
//    override func startLoading() {
//        // if we have a valid URL…
//        if let url = request.url {
//            // …and if we have test data for that URL…
//            if let data = URLProtocolMock.testURLs[url] {
//                print("data request loading \(url)")
//                // …load it immediately.
//                self.client?.urlProtocol(self, didLoad: data)
//            }
//        }
//
//        // mark that we've finished
//        self.client?.urlProtocolDidFinishLoading(self)
//    }
//
//    // this method is required but doesn't need to do anything
//    override func stopLoading() { }
//}
//
//// MARK: - URLSession mock. Directly subclassing the URLSession.
//class MockURLSession: URLSession {
//
//  var data: Data?
//  var response: URLResponse?
//  var error: Error?
//
//  init(data: Data?, response: URLResponse?, error: Error?) {
//    self.data = data
//    self.response = response
//    self.error = error
//  }
//
//  override func dataTask(with request: URLRequest,
//                         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//    let data = self.data
//    let response = self.response
//    let error = self.error
//    return MockURLSessionDataTask {
//      completionHandler(data, response, error)
//    }
//  }
//}
//
//
//class MockURLSessionDataTask: URLSessionDataTask {
//  private let closure: () -> Void
//
//  init(closure: @escaping () -> Void) {
//    self.closure = closure
//  }
//
//  override func resume() {
//    closure()
//  }
//}
//
//
//class FakeResponseData {
//
//  static let response200OK = HTTPURLResponse(url: URL(string: "https://test.com")!,
//                                             statusCode: 200,
//                                             httpVersion: nil,
//                                             headerFields: nil)!
//
//  static let responseKO = HTTPURLResponse(url: URL(string: "https://test.com")!,
//                                          statusCode: 500,
//                                          httpVersion: nil,
//                                          headerFields: nil)!
//
//  class RessourceError: Error {}
//  static let error = RessourceError()
//
//  static var correctData: Data {
//    let bundle = Bundle(for: FakeResponseData.self)
//    let fakeJsonURL = bundle.url(forResource: "mock1", withExtension: "json") // Add your fake json file name in here
//    let fakeJsonData = try! Data(contentsOf: fakeJsonURL!)
//    return fakeJsonData
//  }
//
//  static let incorrectData = "error".data(using: .utf8)!
//}
