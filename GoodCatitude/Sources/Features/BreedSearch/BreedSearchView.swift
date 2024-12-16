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
              NavigationLink(state: BreedDetailsFeature.State(breed: breed)) {
                BreedItemView(breed: breed, viewStore: viewStore)
              }
              .buttonStyle(.borderless)
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
    }
  }

}

private struct BreedItemView: View {

  let breed: CatBreed
  let viewStore: ViewStore<BreedSearchFeature.State, BreedSearchFeature.Action>

  var body: some View {
    NavigationLink(state: BreedDetailsFeature.State(breed: breed)) {
      CatBreedEntryView(breed: breed)
        .frame(maxHeight: .infinity, alignment: .top)
        .overlay(favoriteOverlay)
        .onAppear {
          viewStore.send(.fetchNextPageIfLast(id: breed.id))
        }
    }
    .buttonStyle(.borderless)
  }

  @ViewBuilder
  private var favoriteOverlay: some View {
    if breed.isFavourite {
      Image(systemName: "heart.fill")
        .foregroundStyle(.red)
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
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
