//
//  FetchImageDomain.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FetchImageDomain {

  struct State: Equatable {

  }

  enum Action: Equatable {
    case fetchImage(_ breedId: String, _ imageId: String)
    case handleImage(_ breedId: String, Result<ImageSource, BreedSearchFeature.BreedSearchError>)

    case updateImage(_ breedId: String, ImageSource)
    case hadFailure(FailureType)
  }

  @Dependency(\.breedSearchEnvironment) var environment

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchImage(let breedId, let imageId):
        return fetchImage(&state, breedId: breedId, imageId: imageId)

      case .handleImage(let breedId, let result):
        return handleImage(&state, breedId: breedId, result: result)

      case .updateImage, .hadFailure:
        return .none
      }
    }
  }

}

extension FetchImageDomain {

  private func fetchImage(
    _ state: inout State,
    breedId: String,
    imageId: String
  ) -> Effect<Action> {
    return .run { send in
      let result = await environment.fetchImage(imageId)

      await send(.handleImage(breedId, result))
    }
  }

  private func handleImage(
    _ state: inout State,
    breedId: String,
    result: Result<ImageSource, BreedSearchFeature.BreedSearchError>
  ) -> Effect<Action> {
    switch result {
    case .success(let source):
      return .send(.updateImage(breedId, source))

    case .failure(let error):
      print("[FetchImageDomain] Failed to fetch image: \(error)")

      let failure = BreedSearchFailureMessageHelper.makeFailure(for: error)

      return .send(.hadFailure(failure))
    }
  }

}


