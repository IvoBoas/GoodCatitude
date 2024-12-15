//
//  SearchBreedsDomain.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SearchBreedsDomain {

  struct State: Equatable {
    var isLoading = false
  }

  enum Action: Equatable {
    case searchBreed(String)
    case handleBreedsSearchResponse(Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError>)

    case updateBreeds([CatBreed])
    case hadFailure(FailureType)
  }

  @Dependency(\.breedSearchEnvironment) var environment

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .searchBreed(let query):
        return searchBreed(&state, query: query)

      case .handleBreedsSearchResponse(let response):
        return handleBreedsSearchResponse(&state, result: response)

      case .updateBreeds, .hadFailure:
        return .none
      }
    }
  }

}

extension SearchBreedsDomain {

  private func searchBreed(
    _ state: inout State,
    query: String
  ) -> Effect<Action> {
    state.isLoading = true

    return .run { send in
      let result = await environment.searchBreeds(query)

      await send(.handleBreedsSearchResponse(result))
    }
  }

  // TODO: Cache and reuse breeds fetched before
  private func handleBreedsSearchResponse(
    _ state: inout State,
    result: Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError>
  ) -> Effect<Action> {
    state.isLoading = false

    switch result {
    case .success(let breeds):
      let newBreeds = breeds.map { CatBreed(from: $0) }

      return .send(.updateBreeds(newBreeds))

    case .failure(let error):
      print("[SearchBreedsDomain] Failed to search breeds: \(error)")

      let failure = BreedSearchFailureMessageHelper.makeFailure(for: error)

      return .send(.hadFailure(failure))
    }
  }

}



