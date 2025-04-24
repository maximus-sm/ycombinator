//
//  ContentView.swift
//  Y3News
//
//  Created by Sundet Mukhtar on 24.02.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selection:Tab = .list
    @Environment(MainVM.self) var model
    enum Tab {
        case list
        case featured
    }
    var body: some View {
        TabView(selection:$selection) {
            ListView()
                .tag(Tab.list)
                .tabItem { Label("List", systemImage: "list.bullet") }
            FeaturedListView()
                .tag(Tab.featured)
                .tabItem { Label("Featured", systemImage: "star") }
        }.onAppear{
            //model.subscribe()
            model.subscribe()
        }
    }
}

#Preview {
    ContentView()
        .environment(MainVM())
}

