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

        LocalCatBreedsList()
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

struct LocalCatBreedsList: View {

  @FetchRequest(
    entity: CatBreedMO.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \CatBreedMO.name, ascending: true)]
  ) var items: FetchedResults<CatBreedMO>

  let gridColumns: [GridItem] = Array(
    repeating: GridItem(.flexible(), spacing: 16),
    count: 3
  )

  var body: some View {
    ScrollView {
      LazyVGrid(columns: gridColumns, spacing: 16) {
        ForEach(items, id: \.id) { breed in
          Text(breed.name)
        }
      }
      .padding(
        leading: 24,
        bottom: 24,
        trailing: 24
      )
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
