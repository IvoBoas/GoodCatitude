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

    var currentPage: Int = 0
    var hasMorePages = true
  }

  enum Action: Equatable {
    case fetchNextPage
    case fetchNextPageIfLast(id: String)
    case handleBreedsResponse(Result<[CatBreedResponse], BreedSearchError>)
  }

  enum BreedSearchError: Error, Equatable {
    case fetchFailed
  }

  static private let pageLimit = 10

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

    state.isLoading = true
    state.errorMessage = nil

    return .run { send in
      let result = await environment.fetchBreeds(page, BreedSearchFeature.pageLimit)

      await send(.handleBreedsResponse(result))
    }
  }

  private func fetchNextPageIfLast(
    _ state: inout State,
    id: String
  ) -> Effect<Action> {
    guard state.breeds.last?.id == id || state.breeds.isEmpty else {
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
        state.breeds += newBreeds.map {
          CatBreed(from: $0)
        }
      }

    case .failure(let error):
      print("BreadSearchFeature -> Error fetching breeds: \(error)")

      state.errorMessage = "Failed to fetch cat breeds. Please try again"
    }

    return .none
  }

}
