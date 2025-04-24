//
//  MainView.swift
//  Y3News
//  Created by Maximus on 06.03.2025.
//  Copyright © . All rights reserved.
//  

import SwiftUI


enum Category:String,CaseIterable,Identifiable {
    case new = "New"
    case top = "Top"
    case best = "Best"
    
    var id:Category {
        self
    }
}


struct ListView: View {
    @Environment(MainVM.self) var model
    @State private var category = Category.new
    var body: some View {
        ZStack {
            NavigationView {
                ListBody(type: .category(category))
                    .toolbar {
                        ToolbarItem {
                            Menu {
                                Picker("Category", selection: $category) {
                                    ForEach(Category.allCases) { category in
                                        Text(category.rawValue).tag(category)
                                    }
                                }.pickerStyle(.inline)
                                    .onChange(of: category) {
                                        model.getNews(by: category)
                                    }
                            } label: {
                                Label("Category", systemImage:
                                        "list.bullet")
                            }
                            
                        }
                    }.navigationTitle(category.rawValue)
            }
            if(model.loading){
                ProgressView()
            }
        }
        
    }
}

#Preview {
    ListView()
        .environment(MainVM())
}
