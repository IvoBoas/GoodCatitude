//
//  BreedSearchFeature.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BreedSearchFeature {

  struct State: Equatable {
    var breeds: [CatBreed] = []
    var isLoading = false
    var errorMessage: String?

    let pageLimit: Int = 10
    var currentPage: Int = 0
    var hasMorePages = true
  }

  enum Action: Equatable {
    case fetchNextPage
    case fetchNextPageIfLast(id: String)
    case handleBreedsResponse(Result<[CatBreedResponse], BreedSearchError>)
    case fetchImage(breedId: String, imageId: String)
    case handleImage(breedId: String, Result<ImageSource, BreedSearchError>)
  }

  enum BreedSearchError: Error, Equatable {
    case fetchBreedsFailed(HttpError)
    case fetchImageFailed(HttpError)
  }

  @Dependency(\.breedSearchEnvironment) var environment

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchNextPage:
        return fetchNextPage(&state)

      case .fetchNextPageIfLast(let id):
        return fetchNextPageIfLast(&state, id: id)

      case .handleBreedsResponse(let result):
        return handleBreedsResponse(&state, result: result)

      case .fetchImage(let breedId, let imageId):
        return fetchImage(&state, breedId: breedId, imageId: imageId)

      case .handleImage(let breedId, let result):
        return handleImage(&state, breedId: breedId, result: result)
      }
    }
  }

}

// MARK: Action Handlers
extension BreedSearchFeature {

  private func fetchNextPage(
    _ state: inout State
  ) -> Effect<Action> {
    guard !state.isLoading, state.hasMorePages else {
      return .none
    }

    let page = state.currentPage
    let pageLimit = state.pageLimit

    state.isLoading = true
    state.errorMessage = nil

    return .run { send in
      let result = await environment.fetchBreeds(page, pageLimit)

      await send(.handleBreedsResponse(result))
    }
  }

  private func fetchNextPageIfLast(
    _ state: inout State,
    id: String
  ) -> Effect<Action> {
    guard isLastBreed(state, id: id) else {
      return .none
    }

    return .send(.fetchNextPage)
  }

  private func handleBreedsResponse(
    _ state: inout State,
    result: Result<[CatBreedResponse], BreedSearchError>
  ) -> Effect<Action> {
    state.isLoading = false

    switch result {
    case .success(let newBreeds):
      if newBreeds.isEmpty {
        state.hasMorePages = false
      } else {
        state.currentPage += 1

        let breedsToAdd = newBreeds.map {
          CatBreed(from: $0)
        }

        state.breeds += breedsToAdd

        let fetchImageEffects: [Effect<Action>] = breedsToAdd.map {
          if let referenceImageId = $0.referenceImageId {
            return .send(
              .fetchImage(breedId: $0.id, imageId: referenceImageId)
            )
          }

          // TODO: Add fallback image
          return .send(
            .handleImage(breedId: $0.id, .success(.assets(.breed)))
          )
        }

        return .merge(fetchImageEffects)
      }

    case .failure(let error):
      print("[BreedSearchFeature] Failed to fetch breeds: \(error)")

      state.errorMessage = makeErrorMessage(for: error)
    }

    return .none
  }

  private func fetchImage(
    _ state: inout State,
    breedId: String,
    imageId: String
  ) -> Effect<Action> {
    return .run { send in
      let result = await environment.fetchImage(imageId)

      await send(.handleImage(breedId: breedId, result))
    }
  }

  private func handleImage(
    _ state: inout State,
    breedId: String,
    result: Result<ImageSource, BreedSearchError>
  ) -> Effect<Action> {
    switch result {
    case .success(let source):
      if let index = state.breeds.firstIndex(where: { $0.id == breedId }) {
        state.breeds[index].image = source
      }

      return .none

    case .failure(let error):
      // TODO: Handle
      return .none
    }
  }

}

// MARK: Helpers
extension BreedSearchFeature {

  private func isLastBreed(_ state: State, id: String) -> Bool {
    return state.breeds.last?.id == id || state.breeds.isEmpty
  }

  private func makeErrorMessage(for error: BreedSearchError) -> String? {
    switch error {
    case .fetchBreedsFailed(.invalidResponse):
      return "Received invalid data from the server."

    case .fetchBreedsFailed(.networkUnavailable):
      return "No internet connection. Please try again later."

    case .fetchBreedsFailed(.unknown):
      return "Failed to fetch cat breeds. Please try again later."

    case .fetchImageFailed:
      return nil
    }
  }

}
