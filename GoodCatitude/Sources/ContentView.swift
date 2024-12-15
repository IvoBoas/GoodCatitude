//
//  ContentView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {

  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      WithViewStore(store, observe: { $0 }) { viewStore in
        TabView(
          selection: viewStore.binding(
            get: { $0.selectedTab },
            send: AppFeature.Action.tabSelected
          )
        ) {
          BreedSearchView(
            store: store.scope(
              state: \.searchState,
              action: \.searchAction
            )
          )
          .tabItem {
            Label(
              title: { Text("Breeds") },
              icon: {
                Image(systemName: "cat")
              }
            )
          }
          .toolbarBackground(.visible, for: .tabBar)
          .tag(AppFeature.Tab.breeds)

          FavouriteBreedsView(
            store: store.scope(
              state: \.favouritesState,
              action: \.favouritesAction
            )
          )
          .tabItem {
            Label(
              title: { Text("Favourites") },
              icon: {
                Image(systemName: "heart")
              }
            )
          }
          .toolbarBackground(.visible, for: .tabBar)
          .tag(AppFeature.Tab.favourites)
        }
        .navigationTitle(viewStore.selectedTab.rawValue)
      }
    } destination: { store in
      BreedDetailsView(store: store)
    }
  }
}

#Preview {
  ContentView(
    store: Store(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      $0.breedSearchEnvironment = BreedSearchEnvironment.preview
    }
  )
  .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
