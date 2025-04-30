//
//  Y3NewsTestsNetwork.swift
//  Y3News
//  Created by Maximus on 29.04.2025.
//  Copyright © . All rights reserved.
//

import Testing
@testable import Y3News
import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift
import Combine


class NetworkTests: XCTestCase {
    var network:NetworkManager = NetworkManager()
    var cancellables:Set<AnyCancellable> = []
    var expectation: XCTestExpectation!
    let successid = 1
    let failureid = 2
    var callCounter = 0
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        expectation = XCTestExpectation(description: "wait for queue change")
        cancellables = Set<AnyCancellable>()
        
        stub(condition: isAbsoluteURLString(NetworkManager.EndPoint.category(.new).url.absoluteString)) { _ in
            // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
            let obj = [self.successid,(self.successid),(self.successid)]
            return HTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
            //return HHTTPStubsResponse(JSONObject: obj, statusCode: 200, headers: nil)
        }
        
        stub(condition: isAbsoluteURLString(NetworkManager.EndPoint.story(successid).url.absoluteString)) { _ in
            // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
            let stubPath = OHPathForFile("mock.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        stub(condition:isAbsoluteURLString(NetworkManager.EndPoint.story(failureid).url.absoluteString)) { _ in
            self.callCounter += 1
            print(self.callCounter)
            if self.callCounter <= 1{
                let stubPath = OHPathForFile("mock1.json", type(of: self))
                return fixture(filePath: stubPath!,status: 400 ,headers: ["Content-Type":"application/json"])
            }else{
                let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
                return HTTPStubsResponse(error: notConnectedError)
            }
            // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
            
        }
        
        //stub(condition: , response: <#T##HTTPStubsResponseBlock#>)
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        cancellables = []
        expectation = nil
        HTTPStubs.removeAllStubs()
        //OHHTTPStubsSwift.removeAllStubs()
        
    }
    
    
    func testStoryJson(){
        
        network
            .story(id: successid)
            .subscribe(on: DispatchQueue.main)
            .handleEvents( receiveOutput:{ story in
                //print("output \(story)")
                XCTAssertNotNil(story, "Stroy should not be nil")
                self.expectation.fulfill()
            }, receiveCompletion: { completion in
                //self.expectation.fulfill()
                //print("completes with \(completion)")
                //XCTAssertEqual(completion, ne, accuracy: <#T##FloatingPoint#>)
            })
            .sink(receiveCompletion: { _ in }, receiveValue: { story in
                //print("output \(story)")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    
    func testStoryJsonError(){
        network
            .story(id: failureid)
            .subscribe(on: DispatchQueue.main)
            .handleEvents( receiveOutput:{ story in
                //print("output \(story)")
                XCTAssertNil(story)
            }, receiveCompletion: { completion in
                print(completion)
                self.expectation.fulfill()
                //self.expectation.fulfill()
                //print("completes with \(completion)")
                //XCTAssertEqual(completion, ne, accuracy: <#T##FloatingPoint#>)
            })
            .sink(receiveCompletion: { _ in }, receiveValue: { story in
                //print("output \(story)")
            })
            .store(in: &cancellables)
        
        network
            .story(id: failureid)
            .subscribe(on: DispatchQueue.main)
            .handleEvents( receiveOutput:{ story in
                //print("output \(story)")
                XCTAssertNil(story)
            }, receiveCompletion: { completion in
                print(completion)
                self.expectation.fulfill()
                //self.expectation.fulfill()
                //print("completes with \(completion)")
                //XCTAssertEqual(completion, ne, accuracy: <#T##FloatingPoint#>)
            })
            .sink(receiveCompletion: { _ in }, receiveValue: { story in
                //print("output \(story)")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    
    func testStoriesJson(){
        network.getNews()
            .subscribe(on: RunLoop.main)
            .handleEvents(receiveOutput: { stories in
                XCTAssert(stories.isEmpty == false)
                self.expectation.fulfill()
            }, receiveCompletion: { completion in
                print(completion)
                //self.expectation.fulfill()
            })
            .sink(receiveCompletion: { _ in }, receiveValue: { story in
                //print("output \(story)")
            })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 0.2)
    }
}
