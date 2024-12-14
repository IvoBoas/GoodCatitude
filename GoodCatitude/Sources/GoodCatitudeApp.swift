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
        breedSearchStore: Store(initialState: BreedSearchFeature.State()) {
          BreedSearchFeature()
        }
      )
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
