//
//  ListBody.swift
//  Y3News
//  Created by Maximus on 04.04.2025.
//  Copyright © . All rights reserved.
//  
import SwiftUI

struct ListBody:View {
    @Environment(MainVM.self) var model;
    var type:ListType;
    enum ListType:Equatable {
        case category(Category)
        case featured
    }
    var body: some View {
        //Text("Hello, world!")
        if(type != .featured){
            List {
                ForEach(model.stories) { story in
                    HStack {
                        Label("Love", systemImage: loved(story.id) ? "heart.fill":"heart" )
                            .labelStyle(.iconOnly)
                            .foregroundStyle(loved(story.id) ? .red : .gray)
                            .padding(.trailing)
                            .imageScale(.large)
                        //Text(story.title)
                        NavigationLink(story.title) {
                            DetailView(url: story.url,id: story.id,story: story)
                        }
                    }.onAppear(perform: {
                        loadMore(story)
                    })
                }
            }
        }
        
        
        if(type == .featured){
            List {
                //let _ = print(model.favs.count)
                //Text("adaff")
                ForEach(model.favs) { story in
                    HStack {
                        Label("Love", systemImage: loved(story.id) ? "heart.fill":"heart" )
                            .labelStyle(.iconOnly)
                            .foregroundStyle(loved(story.id) ? .red : .gray)
                            .padding(.trailing)
                            .imageScale(.large)
                        //Text(story.title ?? "None")
                        NavigationLink(story.title ?? "") {
                            DetailView(url: story.url ?? "",id: Int(story.id))
                        }
                    }
                }
            }
        }
       
        
    }
                       
    private func loadMore(_ story:Story) {
        guard model.stories.last == story else { return }
        model.loadMore()
    }
    
    private func loved(_ id:Int) -> Bool{
        return model.favsIDs.contains(id)
    }
    
    private func loved(_ id:Int64) -> Bool{
        return model.favsIDs.contains(Int(id))
    }
}
