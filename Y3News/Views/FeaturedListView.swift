//
//  FeaturedListView.swift
//  Y3News
//  Created by Maximus on 07.03.2025.
//  Copyright © . All rights reserved.
//  
import SwiftUI

struct FeaturedListView: View {
    @Environment(MainVM.self) var model
    //@State var like: Bool = true
//    @FetchRequest(sortDescriptors: [SortDescriptor(\.timestamp)])
//    private var s: FetchedResults<FeaturedStory>
    var body: some View {
        NavigationView {
            ListBody(type: .featured)
                .navigationTitle("Liked")
            Text("If you remove this text the ListBody will not show up")
                //.environment(model)
        }.onAppear {
            //model.subscribe()
        }

    }
    
    
    private func deleteFavs(at offsets: IndexSet) {
        withAnimation {
            offsets.map { model.favs[$0] }.forEach(model.removeFromFavs(story:))
        }
    }
}
