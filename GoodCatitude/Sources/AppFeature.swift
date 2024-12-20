//
//  AppFeature.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {

  enum Tab: String {
    case breeds = "Breeds"
    case favourites = "Favourites"
  }

  @ObservableState
  struct State: Equatable {
    var selectedTab: Tab = .breeds
    var searchState = BreedSearchFeature.State()
    var favouritesState = FavouriteBreedsFeature.State()
    var path = StackState<BreedDetailsFeature.State>()
  }

  enum Action: Equatable {
    case tabSelected(Tab)
    case path(StackActionOf<BreedDetailsFeature>)

    case searchAction(BreedSearchFeature.Action)
    case favouritesAction(FavouriteBreedsFeature.Action)
    case detailsAction(BreedDetailsFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.searchState, action: \.searchAction) {
      BreedSearchFeature()
    }

    Scope(state: \.favouritesState, action: \.favouritesAction) {
      FavouriteBreedsFeature()
    }

    Reduce { state, action in
      switch action {
      case .tabSelected(let tab):
        state.selectedTab = tab

        return .none

      case .path(.element(let id, .propagateChanges)):
        return propagateFavouriteBreedAction(&state, pathId: id)

      case .searchAction(.toggleFavourite(let id, let value)):
        return .send(.favouritesAction(.toggleFavourite(id, value)))

      case .favouritesAction(.handleFavourites(let favourites)):
        state.searchState.breeds = state.searchState.breeds.map { breed in
          var updated = breed

          updated.isFavourite = favourites.contains { $0.id == breed.id }

          return updated
        }

        return .none

      case .searchAction, .detailsAction, .favouritesAction, .path:
        return .none
      }
    }
    .forEach(\.path, action: \.path) {
      BreedDetailsFeature()
    }
  }

}

extension AppFeature {

  private func propagateFavouriteBreedAction(
    _ state: inout State,
    pathId: StackElementID
  ) -> Effect<Action> {
    guard let detailsState = state.path[id: pathId] else {
      return .none
    }

    if let index = state.searchState.breeds.firstIndex(where: { $0.id == detailsState.breed.id }) {
      let value = detailsState.breed.isFavourite

      state.searchState.breeds[index].isFavourite = value
    }

    return .send(.favouritesAction(.reloadFavourites))
  }

}
