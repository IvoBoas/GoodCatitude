//
//  FetchBreedsDomain.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FetchBreedsDomain {

  struct State: Equatable {
    let pageLimit: Int = 12
    var currentPage: Int = 0
    var hasMorePages = true
    var isLoading = false

    var canLoadNextPage: Bool {
      return hasMorePages && !isLoading
    }
  }

  enum Action: Equatable {
    case resetPagination
    case fetchNextPage
    case handleBreedsResponse(Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError>)

    case fetchedBreeds([CatBreed])
    case hadFailure(FailureType)
  }

  @Dependency(\.breedSearchEnvironment) var environment

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .resetPagination:
        return resetPagination(&state)

      case .fetchNextPage:
        return fetchNextPage(&state)

      case .handleBreedsResponse(let breeds):
        return handleBreedsResponse(&state, result: breeds)

      case .fetchedBreeds, .hadFailure:
        return .none
      }
    }
  }

}

extension FetchBreedsDomain {

  private func resetPagination(
    _ state: inout State
  ) -> Effect<Action> {
    state.currentPage = 0
    state.hasMorePages = true
    state.isLoading = false

    return .none
  }

  private func fetchNextPage(
    _ state: inout State
  ) -> Effect<Action> {
    guard state.canLoadNextPage else {
      return .none
    }

    state.isLoading = true

    return .run { [page = state.currentPage, limit = state.pageLimit] send in
      let result = await environment.fetchBreeds(page, limit)

      await send(.handleBreedsResponse(result))
    }
  }

  private func handleBreedsResponse(
    _ state: inout State,
    result: Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError>
  ) -> Effect<Action> {
    state.isLoading = false

    switch result {
    case .success(let breeds):
      guard !breeds.isEmpty else {
        state.hasMorePages = false

        return .none
      }

      state.currentPage += 1

      let newBreeds = breeds.map { CatBreed(from: $0) }

      return .send(.fetchedBreeds(newBreeds))

    case .failure(let error):
      print("[FetchBreedsDomain] Failed to fetch breeds: \(error)")

      let failure = BreedSearchFailureMessageHelper.makeFailure(for: error)

      return .send(.hadFailure(failure))
    }
  }

}

