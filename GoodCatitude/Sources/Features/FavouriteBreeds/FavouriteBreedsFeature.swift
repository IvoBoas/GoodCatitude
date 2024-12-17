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
    case toggleFavourite(_ id: String, _ value: Bool)
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

      case .toggleFavourite(let id, let value):
        return .run { [breeds = state.breeds] send in
          _ = await environment.updateBreedIsFavorite(id, value)

          if value {
            await send(.reloadFavourites)
          } else {
            let favourites = breeds.filter { $0.id != id }

            await send(.handleFavourites(favourites))
          }
        }.cancellable(id: "breedDetails.updateEntity", cancelInFlight: true)

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
      return .send(
        .fetchImageDomain(
          .fetchImage($0.id, $0.referenceImageId)
        )
      )
    }

    return .merge(fetchImageEffects)
  }

}
