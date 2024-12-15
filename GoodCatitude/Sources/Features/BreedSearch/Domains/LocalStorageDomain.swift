//
//  LocalStorageDomain.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LocalStorageDomain {

  struct State: Equatable {
    
  }

  enum Action: Equatable {
    case storeBreedsLocally([CatBreed])
    case handleStoreResult(EmptyResult<CrudError>)
    
    case hadFailure(FailureType?)
  }

  @Dependency(\.breedSearchEnvironment) var environment

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .storeBreedsLocally(let breeds):
        return storeBreedsLocally(&state, breeds: breeds)

      case .handleStoreResult(let result):
        return handleStoreResult(&state, result: result)

      case .hadFailure(let failure):
        return .none
      }
    }
  }

}

extension LocalStorageDomain {

  private func storeBreedsLocally(
    _ state: inout State,
    breeds: [CatBreed]
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
      return .none

    case .error(let error):
      print("[LocalStorageDomain] Failed to store breeds: \(error)")

      let failure = BreedSearchFailureMessageHelper.makeFailure(
        for: .storeBreedsFailed(error)
      )

      return .send(.hadFailure(failure))
    }
  }

}
