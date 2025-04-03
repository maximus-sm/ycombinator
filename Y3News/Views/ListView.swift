//
//  MainView.swift
//  Y3News
//  Created by Maximus on 06.03.2025.
//  Copyright © . All rights reserved.
//  

import SwiftUI

struct ListView: View {
    @State private var model = MainVM()
    var body: some View {
        NavigationView {
            List {
                ForEach(model.stories) { story in
                    NavigationLink(story.title) {
                        DetailView(url: story.url)
                    }
                }
            }
        }.onAppear {
            model.subscribe()
        }
    }
}

#Preview {
    ListView()
}
