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
    var fetchingLocal = false

    var canLoadNextPage: Bool {
      return hasMorePages && !isLoading
    }
  }

  enum Action: Equatable {
    case resetPagination
    case fetchNextPage
    case handleBreedsResponse(Result<[CatBreed], BreedSearchFeature.BreedSearchError>)
    case handleLocalBreeds([CatBreed])

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

      case .handleLocalBreeds(let breeds):
        return handleLocalBreeds(&state, breeds: breeds)

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
    state.fetchingLocal = false

    return .none
  }

  private func fetchNextPage(
    _ state: inout State
  ) -> Effect<Action> {
    guard state.canLoadNextPage else {
      return .none
    }

    state.isLoading = true

    if state.fetchingLocal {
      return .run { [page = state.currentPage, limit = state.pageLimit] send in
        let breeds = await environment.fetchLocalBreeds(page, limit)

        await send(.handleLocalBreeds(breeds))
      }
    } else {
      return .run { [page = state.currentPage, limit = state.pageLimit] send in
        let result = await environment.fetchBreeds(page, limit)

        await send(.handleBreedsResponse(result))
      }
    }
  }

  private func handleBreedsResponse(
    _ state: inout State,
    result: Result<[CatBreed], BreedSearchFeature.BreedSearchError>
  ) -> Effect<Action> {
    state.isLoading = false

    switch result {
    case .success(let breeds):
      guard !breeds.isEmpty else {
        state.hasMorePages = false

        return .none
      }

      state.currentPage += 1

      return .send(.fetchedBreeds(breeds))

    case .failure(let error):
      state.fetchingLocal = true

      print("[FetchBreedsDomain] Failed to fetch breeds: \(error)")

      let failure = BreedSearchFailureMessageHelper.makeFailure(for: error)

      return .merge(
        .send(.hadFailure(failure)),
        .send(.fetchNextPage)
      )
    }
  }

  private func handleLocalBreeds(
    _ state: inout State,
    breeds: [CatBreed]
  ) -> Effect<Action> {
    state.isLoading = false

    guard !breeds.isEmpty else {
      state.hasMorePages = false

      return .none
    }

    state.currentPage += 1

    return .send(.fetchedBreeds(breeds))
  }

}

