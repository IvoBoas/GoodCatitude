//
//  FavouriteBreedsView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct FavouriteBreedsView: View {

  let store: StoreOf<FavouriteBreedsFeature>

  let gridColumns: [GridItem] = Array(
    repeating: GridItem(.flexible(), spacing: 16),
    count: 3
  )

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView {
        LazyVGrid(columns: gridColumns, spacing: 16) {
          ForEach(viewStore.breeds, id: \.id) { breed in
            NavigationLink(state: BreedDetailsFeature.State(breed: breed)) {
              CatBreedEntryView(breed: breed, showLifespan: true)
                .frame(maxHeight: .infinity, alignment: .top)
                .overlay(alignment: .topTrailing) {
                  Button { viewStore.send(.toggleFavourite(breed.id, !breed.isFavourite)) } label: {
                    Image(systemName: breed.isFavourite ? "heart.fill" : "heart")
                      .foregroundStyle(.red)
                      .padding(4)
                  }
                }
            }
          }
        }
        .padding(
          leading: 24,
          bottom: 24,
          trailing: 24
        )

        if viewStore.isLoading {
          ProgressView()
        }
      }
      .scrollIndicators(.hidden)
      .onAppear { viewStore.send(.onAppear) }
      .refreshable { viewStore.send(.reloadFavourites) }
    }
  }

}

#Preview {
  FavouriteBreedsView(
    store: Store(initialState: FavouriteBreedsFeature.State()) {
      FavouriteBreedsFeature()
    } withDependencies: {
      $0.breedSearchEnvironment = BreedSearchEnvironment.preview
      $0.favouriteBreedsEnvironment = FavouriteBreedsEnvironment.preview
    }
  )
}
