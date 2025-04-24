//
//  NetworkManager.swift
//  Y3News
//  Created by Maximus on 24.02.2025.
//  Copyright © . All rights reserved.
//

import Foundation
import Combine

class NetworkManager{
    //var url: URL;
    //var baseUrl: String? = "https://hacker-news.firebaseio.com/v0/"
    static let pageChangedNotification = Notification.Name("PageDidChange")
    var httpMethod: String? = "GET"
    var body: Data?
    
    //var a = Category()
    var maxStories = 20
    var page = 1
    let total = 60 // constrained by Backend
    //var loadedIDs = [Int]()
    private let decoder = JSONDecoder()
    private let apiQueue = DispatchQueue(label: "API", qos: .default, attributes: .concurrent)
    
    init(){
        //        NotificationCenter.default.addObserver(self, selector: #selector(pageDidChange(_:)), name: NetworkManager.pageChangedNotification, object: nil)
        //        NotificationCenter.default.addObserver(forName: NetworkManager.pageChangedNotification, object: nil, queue: nil, using: pageDidChange(_:))
    }
    
    
    enum EndPoint{
        
        static let baseURL = URL(string: "https://hacker-news.firebaseio.com/v0/")!
        
//        case new
//        case top
//        case best
        case category(Category)
        
        case story(Int)
        
        
        var url: URL {
            switch self {
//            case .new:
//                return EndPoint.baseURL.appendingPathComponent("newstories.json")
//            case .top:
//                return EndPoint.baseURL.appendingPathComponent("topstories.json")
//            case .best:
//                return EndPoint.baseURL.appendingPathComponent("beststories.json")
            case .story(let id):
                return EndPoint.baseURL.appendingPathComponent("item/\(id).json")
            case .category(let cat):
                switch cat {
                case .new:
                    return EndPoint.baseURL.appendingPathComponent("newstories.json")
                case .top:
                    return EndPoint.baseURL.appendingPathComponent("topstories.json")
                case .best:
                    return EndPoint.baseURL.appendingPathComponent("beststories.json")
                }
            }
        }
        
    }
    
    enum Error: LocalizedError, Identifiable {
        var id: String { localizedDescription }
        
        case addressUnreachable(URL)
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "The server responded with garbage."
            case .addressUnreachable(let url): return "\(url.absoluteString) is unreachable."
            }
        }
    }
    
    
    func getNews(sortBy:EndPoint = .category(.new)) -> AnyPublisher<[Story], Error>{
        URLSession.shared.dataTaskPublisher(for: sortBy.url)
            .map { $0.0 }
            .decode(type: [Int].self, decoder: decoder)
            .mapError { error -> Error in
                switch error {
                case is URLError:
                    return Error.addressUnreachable(sortBy.url)
                default: return Error.invalidResponse
                }
            }
            .filter { !$0.isEmpty }
            .flatMap { [unowned self] storyIDs in
                return self.mergedStories(ids: storyIDs)
            }
            .scan([], { (stories, story) -> [Story] in
                return stories + [story]
            })
            .map { stories in
                return stories.sorted()
            }
            .eraseToAnyPublisher()
    }
    
    
    func getNewsID(sortBy:EndPoint = .category(.new)) -> AnyPublisher<[Int], Error>{
        URLSession.shared.dataTaskPublisher(for: sortBy.url)
            .map { $0.0 }
            .decode(type: [Int].self, decoder: decoder)
            .mapError { error -> Error in
                switch error {
                case is URLError:
                    return Error.addressUnreachable(sortBy.url)
                default: return Error.invalidResponse
                }
            }
            .filter { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    
    func getNews(on page:(Int,Int),for ids: [Int]) -> AnyPublisher<[Story], Error>{
        mergedStories(ids: ids,page)
            .reduce([], { (stories, story) -> [Story] in
                return stories + [story]
            })
            .map { stories in
                return stories.sorted()
            }
            .eraseToAnyPublisher()
    }
    
    
    private func mergedStories(ids storyIDs: [Int],_ page:(Int,Int) = (0,1)) -> AnyPublisher<Story, Error> {
        guard !storyIDs.isEmpty else { return Empty<Story, Error>().eraseToAnyPublisher() }
        //precondition(!storyIDs.isEmpty)
        let start = min(storyIDs.count - 1,page.0 * maxStories)
        let end = min(storyIDs.count - 1,page.1 * maxStories)
        let partialIDs = Array(storyIDs[start..<end])
        
        guard !partialIDs.isEmpty else { return Empty<Story, Error>().eraseToAnyPublisher() }
        //precondition(!storyIDs.isEmpty)
        let initialPublisher = story(id: partialIDs[0])
        let remainder = Array(partialIDs.dropFirst())
        
        return remainder.reduce(initialPublisher) { (combined, id) -> AnyPublisher<Story, Error> in
            return combined.merge(with: story(id: id))
                .eraseToAnyPublisher()
        }
    }
    
    
    func story(id: Int) -> AnyPublisher<Story, Error> {
        URLSession.shared.dataTaskPublisher(for: EndPoint.story(id).url)
            .receive(on: apiQueue)
            .map { $0.0 }
            .decode(type: Story.self, decoder: decoder)
            .catch { _ in Empty() }
            .eraseToAnyPublisher()
    }
}
