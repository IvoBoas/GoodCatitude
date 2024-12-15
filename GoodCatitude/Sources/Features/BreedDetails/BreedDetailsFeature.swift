//
//  BreedDetailsFeature.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BreedDetailsFeature {

  @ObservableState
  struct State: Equatable {
    var breed: CatBreed
  }

  enum Action: Equatable { 
    case toggleIsFavorite
    case updateEntity
    case handleStorageResult(EmptyResult<CrudError>)
    case hadFailure(FailureType)
  }

  @Dependency(\.breedSearchEnvironment) var environment

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .toggleIsFavorite:
        state.breed.isFavourite.toggle()

        return .send(.updateEntity)

      case .updateEntity:
        return .run { [id = state.breed.id, value = state.breed.isFavourite]send in
          let result = await environment.updateBreedIsFavorite(id, value)

          await send(.handleStorageResult(result))
        }

      case .handleStorageResult(let result):
        return handleStorageResult(&state, result: result)

      case .hadFailure:
        return .none
      }
    }
  }

}

extension BreedDetailsFeature {

  private func handleStorageResult(
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
