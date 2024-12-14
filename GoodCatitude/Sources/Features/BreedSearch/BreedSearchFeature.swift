//
//  BreedSearchFeature.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation
import ComposableArchitecture

// TODO: Split reducer by scopes
@Reducer
struct BreedSearchFeature {

  struct State: Equatable {
    var breeds: [CatBreed] = []
    var searchQuery: String = ""
    var isLoading = false
    var failure: FailureType?

    let pageLimit: Int = 12
    var currentPage: Int = 0
    var hasMorePages = true
  }

  enum Action: Equatable {
    case fetchNextPage
    case fetchNextPageIfLast(id: String)
    case handleBreedsResponse(Result<[CatBreedResponse], BreedSearchError>)

    case fetchImage(breedId: String, imageId: String)
    case handleImage(breedId: String, Result<ImageSource, BreedSearchError>)

    case updateSearchQuery(String)
    case updateSearchQueryDebounced(String)
    case searchBreed
    case handleBreedsSearchResponse(Result<[CatBreedResponse], BreedSearchError>)

    case storeBreedsLocally([CatBreedResponse])
    case handleStoreResult(EmptyResult<CrudError>)
  }

  enum BreedSearchError: Error, Equatable {
    case fetchBreedsFailed(HttpError)
    case fetchImageFailed(HttpError)
    case storeBreedsFailed(CrudError)
  }

  @Dependency(\.breedSearchEnvironment) var environment
  @Dependency(\.mainQueue) var mainQueue


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

      case .updateSearchQueryDebounced(let query):
        return updateSearchQueryDebounced(&state, query: query)

      case .updateSearchQuery(let query):
        return updateSearchQuery(&state, query: query)

      case .searchBreed:
        return searchBreed(&state)

      case .handleBreedsSearchResponse(let result):
        return handleBreedsSearchResponse(&state, result: result)

      case .storeBreedsLocally(let breeds):
        return storeBreedsLocally(&state, breeds: breeds)

      case .handleStoreResult(let result):
        return handleStoreResult(&state, result: result)
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

    state.isLoading = true
    state.failure = nil

    return .run { [page = state.currentPage, limit = state.pageLimit] send in
      let result = await environment.fetchBreeds(page, limit)

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

        return .merge(
          fetchImagesForBreeds(breedsToAdd),
          .send(.storeBreedsLocally(newBreeds))
        )
      }

    case .failure(let error):
      print("[BreedSearchFeature] Failed to fetch breeds: \(error)")

      state.failure = BreedSearchFailureMessageHelper.makeFailure(for: error)
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

  private func updateSearchQuery(
    _ state: inout State,
    query: String
  ) -> Effect<Action> {
    guard query != state.searchQuery else {
      return .none
    }

    state.searchQuery = query
    state.currentPage = 0
    state.breeds = []

    if query.isEmpty {
      state.hasMorePages = true

      return .send(.fetchNextPage)
    } else {
      state.hasMorePages = false

      return .send(.searchBreed)
    }
  }

  private func updateSearchQueryDebounced(
    _ state: inout State,
    query: String
  ) -> Effect<Action> {
    return .run { send in
      try await mainQueue.sleep(for: .milliseconds(150))

      await send(.updateSearchQuery(query))
    }
    .cancellable(id: "searchQuery", cancelInFlight: true)
  }

  private func searchBreed(
    _ state: inout State
  ) -> Effect<Action> {
    guard !state.searchQuery.isEmpty else {
      return .none
    }

    state.isLoading = true
    state.failure = nil

    return .run { [query = state.searchQuery] send in
      let result = await environment.searchBreeds(query)

      await send(.handleBreedsSearchResponse(result))
    }
  }

  // TODO: Cache and reuse breeds fetched before
  private func handleBreedsSearchResponse(
    _ state: inout State,
    result: Result<[CatBreedResponse], BreedSearchError>
  ) -> Effect<Action> {
    state.isLoading = false

    switch result {
    case .success(let newBreeds):
      let breeds = newBreeds.map {
        CatBreed(from: $0)
      }

      state.breeds = breeds

      return fetchImagesForBreeds(breeds)

    case .failure(let error):
      print("[BreedSearchFeature] Failed to search breeds: \(error)")

      state.failure = BreedSearchFailureMessageHelper.makeFailure(for: error)
    }

    return .none
  }

  private func storeBreedsLocally(
    _ state: inout State,
    breeds: [CatBreedResponse]
  ) -> Effect<Action> {
    return .run { send in
      let result = await environment.storeBreedsLocally(breeds)

      await send(.handleStoreResult(result))
    }
  }

  private func handleStoreResult(
    _ state: inout State,
    result: EmptyResult<CrudError>
  ) -> Effect<Action> {
    switch result {
    case .success:
      break

    case .error(let error):
      state.failure = BreedSearchFailureMessageHelper.makeFailure(for: .storeBreedsFailed(error))
    }

    return .none
  }

}

extension BreedSearchFeature {

  private func fetchImagesForBreeds(
    _ breeds: [CatBreed]
  ) -> Effect<Action> {
    let fetchImageEffects: [Effect<Action>] = breeds.map {
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

}

// MARK: Helpers
extension BreedSearchFeature {

  private func isLastBreed(_ state: State, id: String) -> Bool {
    return state.breeds.last?.id == id || state.breeds.isEmpty
  }

}
