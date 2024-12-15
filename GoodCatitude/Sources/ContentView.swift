//
//  ContentView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {

  let store: StoreOf<AppFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      TabView(
        selection: viewStore.binding(
          get: { $0.selectedTab },
          send: AppFeature.Action.tabSelected
        )
      ) {
        BreedSearchView(
          store: store.scope(
            state: \.breedSearchState,
            action: \.breedSearchFeature
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
        .toolbar(
          viewStore.state.breedSearchState.path.isEmpty ? .visible : .hidden, for: .tabBar
        )
        .animation(.default, value: viewStore.state.breedSearchState.path.isEmpty)
        .tag(AppFeature.Tab.breeds)
        
        Text("Hello World")
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
          .tag(AppFeature.Tab.other)
      }
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
