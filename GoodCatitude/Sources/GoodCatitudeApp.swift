//
//  GoodCatitudeApp.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct GoodCatitudeApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView(
        store: Store(initialState: AppFeature.State()) {
          AppFeature()
        }
      )
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
