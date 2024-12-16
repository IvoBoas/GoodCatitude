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
    case searchBreedLocal(String)
    case handleBreedsSearchResponse(_ query: String, Result<[CatBreed], BreedSearchFeature.BreedSearchError>)
    case handleLocalBreedsSearch([CatBreed])

    case updateBreeds([CatBreed])
    case hadFailure(FailureType)
  }

  @Dependency(\.breedSearchEnvironment) var environment

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .searchBreed(let query):
        return searchBreed(&state, query: query)

      case .searchBreedLocal(let query):
        return searchBreedLocal(&state, query: query)

      case .handleBreedsSearchResponse(let query, let result):
        return handleBreedsSearchResponse(&state, query: query, result: result)

      case .handleLocalBreedsSearch(let breeds):
        return handleLocalBreedsSearchResponse(&state, breeds: breeds)

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

      await send(.handleBreedsSearchResponse(query, result))
    }
  }

  private func searchBreedLocal(
    _ state: inout State,
    query: String
  ) -> Effect<Action> {
    state.isLoading = true

    return .run { send in
      let breeds = await environment.searchBreedsLocally(query)

      await send(.handleLocalBreedsSearch(breeds))
    }
  }

  private func handleBreedsSearchResponse(
    _ state: inout State,
    query: String,
    result: Result<[CatBreed], BreedSearchFeature.BreedSearchError>
  ) -> Effect<Action> {
    state.isLoading = false

    switch result {
    case .success(let breeds):
      return .send(.updateBreeds(breeds))

    case .failure(let error):
      print("[SearchBreedsDomain] Failed to search breeds: \(error)")

      let failure = BreedSearchFailureMessageHelper.makeFailure(for: error)

      return .merge(
        .send(.hadFailure(failure)),
        .send(.searchBreedLocal(query))
      )
    }
  }

  private func handleLocalBreedsSearchResponse(
    _ state: inout State,
    breeds: [CatBreed]
  ) -> Effect<Action> {
    state.isLoading = false

    return .send(.updateBreeds(breeds))
  }

}



