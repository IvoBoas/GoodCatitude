//
//  FavouriteBreedsFeature.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FavouriteBreedsFeature {

  @ObservableState
  struct State: Equatable {
    var breeds: [CatBreed] = []
    var isLoading = false

    var fetchImageState = FetchImageFeature.State()
  }

  enum Action: Equatable {
    case onAppear
    case reloadFavourites
    case handleFavourites([CatBreed])

    case fetchImageDomain(FetchImageFeature.Action)
  }

  @Dependency(\.favouriteBreedsEnvironment) var environment

  var body: some ReducerOf<Self> {
    Scope(state: \.fetchImageState, action: \.fetchImageDomain) {
      FetchImageFeature()
    }

    Reduce { state, action in
      switch action {
      case .onAppear:
        if !state.isLoading && state.breeds.isEmpty {
          return .send(.reloadFavourites)
        }

        return .none

      case .reloadFavourites:
        state.isLoading = true

        return .run { send in
          let favourites = await environment.fetchFavouriteBreeds()

          await send(.handleFavourites(favourites))
        }.cancellable(id: "feature.favourites.reload", cancelInFlight: true)

      case .handleFavourites(let favourites):
        state.isLoading = false
        state.breeds = favourites.sorted {
          $0.name < $1.name
        }

        return fetchImagesForBreeds(state.breeds)

      case .fetchImageDomain(let action):
        return handleFetchImageDomainAction(&state, action: action)
      }
    }
  }

}

extension FavouriteBreedsFeature {

  private func handleFetchImageDomainAction(
    _ state: inout State,
    action: FetchImageFeature.Action
  ) -> Effect<Action> {
    switch action {
    case .fetchImage, .handleImage, .fetchRemoteImage,
        .handleImageData, .storeImageLocally, .fetchRemoteImageData:
      return .none

    case .updateImage(let breedId, let source):
      if let index = state.breeds.firstIndex(where: { $0.id == breedId }) {
        state.breeds[index].image = source
      }

      return .none

    case .hadFailure:
      return .none
    }
  }

  private func fetchImagesForBreeds(
    _ breeds: [CatBreed]
  ) -> Effect<Action> {
    let fetchImageEffects: [Effect<Action>] = breeds.map {
      if let referenceImageId = $0.referenceImageId {
        return .send(
          .fetchImageDomain(
            .fetchImage($0.id, referenceImageId)
          )
        )
      }

      // TODO: Add fallback image
      return .send(
        .fetchImageDomain(
          .handleImage($0.id, .success(.assets(.breed)))
        )
      )
    }

    return .merge(fetchImageEffects)
  }

}
