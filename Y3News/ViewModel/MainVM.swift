//
//  MainVM.swift
//  Y3News
//  Created by Maximus on 06.03.2025.
//  Copyright © . All rights reserved.
//

import Foundation
import Combine
import CoreData

@Observable
class MainVM{
    let container = PersistenceController.shared.container
    
    var stories: [Story] = []
    var storyIDs = [Int]()
    var favs: [FeaturedStory] = []
    var favsIDs = Set<Int>()
    var loading = false
    var page = CurrentValueSubject<Int, NetworkManager.Error>(1)
    let netManager:NetworkManager = NetworkManager()
    var cancellables: Set<AnyCancellable> = []
    
    var context: NSManagedObjectContext{
        get{ container.viewContext }
    }
    
    init() {
        getNews()
        favsStory()
        try? context.save()
    }
    
    
    func getNews(by category:Category = .new ){
        netManager.getNewsID(sortBy:.category(category))
            .receive(on: RunLoop.current)
            .share()
            .sink(receiveCompletion: { [weak self] _ in
                self?.page.send(1)
                self?.stories = []
            }, receiveValue: { [weak self] ids in
                self?.storyIDs = ids
            })
            .store(in: &cancellables)
    }
    
    
    func subscribe(){
        page.flatMap {  [unowned self] num in
            loading = true
            return netManager.getNews(on: (num - 1,num), for: storyIDs)
        }
        .receive(on: RunLoop.main)
        .share()
        .sink(receiveCompletion: { _ in
  
        }, receiveValue: { [weak self] stories in
            self?.loading = false
            self?.stories += stories
        })
        .store(in: &cancellables)
    }
    
    
    func loadMore(){
        guard !loading else { return }
        page.send(page.value + 1)
    }
    
    func favsStory(){
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSaveObjectIDs, object: context)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [unowned self] _ in
                self.favs = self.getFavs()
                favsIDs = Set(self.favs.map{Int($0.id)})
            })
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    
    func story(by id:Int){
        netManager.story(id: id)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] stories in
                self?.stories = [stories]
            })
            .store(in: &cancellables)
    }

    
}

// MARK: - CoreData releated methods

extension MainVM {
    
    
    func getFavs() -> [FeaturedStory]{
        let request: NSFetchRequest<FeaturedStory> = FeaturedStory.fetchRequest()
        let sort: NSSortDescriptor = NSSortDescriptor(keyPath: \FeaturedStory.timestamp, ascending: true)
        request.sortDescriptors = [sort]
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
    
    
    func isAlreadyFav(id:Int) -> Bool{
        let request:NSFetchRequest<FeaturedStory> = FeaturedStory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %ld", Int64(id))
        do{
            return try context.count(for: request) > 0
        }catch{
            return false
        }
    }
    
    
    func addToFavs(story:Story){
        guard !isAlreadyFav(id: story.id) else { return }
        let s = FeaturedStory(context: context)
        s.id = Int64(story.id)
        s.by = story.by
        s.title = story.title
        s.url = story.url
        s.timestamp = Date.now
        do {
            try container.viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            //fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            print(error.localizedDescription)
        }
    }
    
    func removeFromFavs(story:FeaturedStory){
        context.delete(story)
        do {
            try context.save()
        } catch {
            /**
             Real-world apps should consider better handling the error in a way that fits their UI.
            */
            let nsError = error as NSError
            fatalError("Failed to save Core Data changes: \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    func removeFromFavs(by id:Int){
        //guard favsIDs.contains(id) else { return }
        let request = FeaturedStory.fetchRequest()
        let predicate = NSPredicate(format: "id == %ld ", Int64(id))
        request.predicate = predicate
        do{
            if let result = try? context.fetch(request){
                for obj in result {
                    context.delete(obj)
                }
            }
            try context.save()
        }catch{
            print(error.localizedDescription)
        }
        
    }
    
}
