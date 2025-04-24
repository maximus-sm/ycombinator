//
//  DetailView.swift
//  Y3News
//  Created by Maximus on 06.03.2025.
//  Copyright © . All rights reserved.
//  


import Foundation
import SwiftUI
import WebKit
import CoreData


struct DetailView: View {
    let url:String
    let id:Int
    var story:Story?
    //@Binding var action: Bool
    @Environment(MainVM.self) var model
//    @FetchRequest(sortDescriptors: []) var favs: FetchedResults<FeaturedStory>
    
    @State var like: Bool =  false
    var body: some View {
        VStack {
            WebView(URL(string: url)!)
            FavButton(like: $like)
        }.onDisappear {
            if(model.favsIDs.contains(id) && !like){
                model.removeFromFavs(by: id)
            }else if(like){
                if let s = story{
                    model.addToFavs(story: s)
                }
                //model.addToFavs(id: id)
            }
        }.onAppear {
           like =  model.favsIDs.contains(id)
        }
    }
}


struct FavButton: View {
    @Binding var like: Bool
    var body: some View {
        Button {
            like.toggle()
        } label: {
            Label("Like", systemImage: like ? "heart.fill" : "heart")
                .labelStyle(.iconOnly)
                .foregroundStyle( like ? .red : .gray)
                .padding(.vertical)
                .imageScale(.large)
        }

    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func makeUIView(context: Context) -> some UIView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

//#Preview{
//    DetailView(url: "https://www.udemy.com/",story: MainVM())
//        .environment(MainVM())
//}
