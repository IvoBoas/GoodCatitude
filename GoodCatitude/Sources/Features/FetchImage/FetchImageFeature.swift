//
//  FetchImageFeature.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FetchImageFeature {

  private let imageWriteQueue = DispatchQueue(label: "com.app.imageWriteQueue", qos: .background)

  struct State: Equatable {

  }

  enum Action: Equatable {
    case fetchImage(_ breedId: String, _ imageId: String?)
    case fetchRemoteImage(_ breedId: String, _ imageId: String)
    case handleImage(_ breedId: String, Result<ImageSource, BreedSearchFeature.BreedSearchError>)
    case handleImageData(_ breedId: String, _ imageId: String, Result<Data, BreedSearchFeature.BreedSearchError>)
    case storeImageLocally(_ imageId: String, Data)
    case fetchRemoteImageData(_ breedId: String, _ imageId: String, _ url: String)

    case updateImage(_ breedId: String, ImageSource)
    case hadFailure(FailureType)
  }

  @Dependency(\.fetchImageEnvironment) var environment

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchImage(let breedId, let imageId):
        return fetchImage(&state, breedId: breedId, imageId: imageId)

      case .fetchRemoteImage(let breedId, let imageId):
        return fetchRemoteImage(&state, breedId: breedId, imageId: imageId)

      case .handleImage(let breedId, let result):
        return handleImage(&state, breedId: breedId, result: result)

      case .handleImageData(let breedId, let imageId, let result):
        return handleImageData(&state, breedId: breedId, imageId: imageId, result: result)

      case .storeImageLocally(let imageId, let data):
        return storeImageLocally(&state, imageId: imageId, data: data)

      case .fetchRemoteImageData(let breedId, let imageId, let url):
        return fetchRemoteImageData(&state, url: url, breedId: breedId, imageId: imageId)

      case .updateImage, .hadFailure:
        return .none
      }
    }
  }

}

extension FetchImageFeature {

  private func fetchImage(
    _ state: inout State,
    breedId: String,
    imageId: String?
  ) -> Effect<Action> {
    guard let imageId else {
      return .send(.handleImage(breedId, .success(.assets(.defaultBreedAvatar))))
    }

    return .run(priority: .background) { send in
      let localImage = environment.loadLocalImage(imageId)

      if let localImage {
        await send(.handleImage(breedId, .success(.local(imageId, localImage))))
      } else {
        await send(.fetchRemoteImage(breedId, imageId))
      }
    }
  }

  private func fetchRemoteImage(
    _ state: inout State,
    breedId: String,
    imageId: String
  ) -> Effect<Action> {
    return .run { send in
      let result = await environment.fetchImageInfo(imageId)

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
      switch source {
      case .loading, .assets, .local:
        return .send(.updateImage(breedId, source))

      case .remote(let imageId, let url):
        return .send(.fetchRemoteImageData(breedId, imageId, url))
      }

    case .failure(let error):
      print("[FetchImageDomain] Failed to fetch image info: \(error)")

      let failure = BreedSearchFailureMessageHelper.makeFailure(for: error)

      return .send(.hadFailure(failure))
    }
  }

  private func handleImageData(
    _ state: inout State,
    breedId: String,
    imageId: String,
    result: Result<Data, BreedSearchFeature.BreedSearchError>
  ) -> Effect<Action> {
    switch result {
    case .success(let data):
      return .merge(
        .send(.handleImage(breedId, .success(.local(imageId, data)))),
        .send(.storeImageLocally(imageId, data))
      )

    case .failure(let error):
      print("[FetchImageDomain] Failed to fetch image data: \(error)")

      let failure = BreedSearchFailureMessageHelper.makeFailure(for: error)

      return .send(.hadFailure(failure))
    }
  }

  private func storeImageLocally(
    _ state: inout State,
    imageId: String,
    data: Data
  ) -> Effect<Action> {
    imageWriteQueue.async {
      environment.storeImageLocally(data, imageId)
    }

    return .none
  }

  private func fetchRemoteImageData(
    _ state: inout State,
    url: String,
    breedId: String,
    imageId: String
  ) -> Effect<Action> {
    return .run { send in
      let result = await environment.fetchRemoteImageData(url)

      await send(.handleImageData(breedId, imageId, result))
    }
  }

}



