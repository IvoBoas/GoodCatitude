//
//  BreedSearchView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import SwiftUI
import ComposableArchitecture

struct BreedSearchView: View {

  @Bindable var store: StoreOf<BreedSearchFeature>

  private let gridColumns: [GridItem] = Array(
    repeating: GridItem(.flexible(), spacing: 16),
    count: 3
  )

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 16) {
        TextField(
          "Search breeds",
          text: viewStore.binding(
            get: \.searchQuery,
            send: { .updateSearchQueryDebounced($0) }
          )
        )
        .textFieldStyle(.roundedBorder)
        .padding(horizontal: 24)

        ScrollView {
          LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(viewStore.breeds, id: \.id) { breed in
              BreedItemView(breed: breed, viewStore: viewStore)
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
        .refreshable { viewStore.send(.reload) }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
      .alert($store.scope(state: \.alert, action: \.alert))
    }
  }

}

private struct BreedItemView: View {

  let breed: CatBreed
  let viewStore: ViewStoreOf<BreedSearchFeature>

  var body: some View {
    NavigationLink(state: BreedDetailsFeature.State(breed: breed)) {
      CatBreedEntryView(breed: breed, showLifespan: false)
        .frame(maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .topTrailing) {
          Button { viewStore.send(.toggleFavourite(breed.id, to: !breed.isFavourite)) } label: {
            Image(systemName: breed.isFavourite ? "heart.fill" : "heart")
              .foregroundStyle(.red)
              .padding(4)
              .shadow(color: .black, radius: 10)
          }
        }
        .onAppear {
          viewStore.send(.fetchNextPageIfLast(id: breed.id))
        }
    }
    .buttonStyle(.borderless)
  }

}

#Preview {
  BreedSearchView(
    store: Store(initialState: BreedSearchFeature.State()) {
      BreedSearchFeature()
    } withDependencies: {
      $0.breedSearchEnvironment = BreedSearchEnvironment.preview
    }
  )
}
