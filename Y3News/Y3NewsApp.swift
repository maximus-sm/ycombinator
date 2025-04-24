//
//  Y3NewsApp.swift
//  Y3News
//
//  Created by Sundet Mukhtar on 24.02.2025.
//

import SwiftUI

@main
struct Y3NewsApp: App {
    //let persistenceController = PersistenceController.shared
    @State private var model = MainVM()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
                //.environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
