//
//  ContentView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {

  enum Tab: String {
    case breeds = "Breeds"
    case other = "Other"
  }

  @State private var selectedTab: Tab = .breeds

  var breedSearchStore: StoreOf<BreedSearchFeature>

  var body: some View {
    NavigationView {
      TabView(selection: $selectedTab) {
        BreedSearchView(store: breedSearchStore)
          .tabItem {
            Label(
              title: { Text("Breeds") },
              icon: {
                Image(systemName: "cat")
              }
            )
          }
          .toolbarBackground(.visible, for: .tabBar)
          .tag(Tab.breeds)

        Text("Hello world")
          .padding(leading: 24, trailing: 24)
          .tabItem {
            Label(
              title: { Text("Other") },
              icon: {
                Image(systemName: "heart")
              }
            )
          }
          .toolbarBackground(.visible, for: .tabBar)
          .tag(Tab.other)
      }
      .navigationTitle(Text(selectedTab.rawValue))
    }
  }
}

#Preview {
  ContentView(
    breedSearchStore: Store(initialState: BreedSearchFeature.State()) {
      BreedSearchFeature()
    } withDependencies: {
      $0.breedSearchEnvironment = BreedSearchEnvironment.preview
    }
  )
  .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
