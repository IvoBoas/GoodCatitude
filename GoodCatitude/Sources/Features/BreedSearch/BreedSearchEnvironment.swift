//
//  BreedSearchEnvironment.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation
import ComposableArchitecture

struct BreedSearchEnvironment {

  var fetchBreeds: (_ page: Int, _ limit: Int) async -> Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError>
  var searchBreeds: (_ query: String) async -> Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError>
  var fetchImage: (_ id: String) async -> Result<ImageSource, BreedSearchFeature.BreedSearchError>

}

// MARK: Service Implementation
extension BreedSearchEnvironment {

  static let live = Self { page, limit in
    return await HttpClient.getRequest(
      url: "https://api.thecatapi.com/v1/breeds",
      params: [ "page": page, "limit": limit ]
    )
    .mapError { .fetchBreedsFailed($0) }
  } searchBreeds: { query in
    return await HttpClient.getRequest(
      url: "https://api.thecatapi.com/v1/breeds/search",
      params: [ "q": query, "attach_image": 1 ]
    )
    .mapError { .fetchBreedsFailed($0) }
  } fetchImage: { id in
    let response: HttpRequestResult<CatImageResponse> = await HttpClient.getRequest(url: "https://api.thecatapi.com/v1/images/\(id)")

    return response
      .mapError { .fetchImageFailed($0)}
      .map { .remote($0.url) }
  }

  static let preview = Self { page, limit in
    let breeds = [
      "Abyssinian",
      "Bengal",
      "Siamese"
    ]

    var res = [CatBreedResponse]()

    for i in 0..<limit {
      let id = page * limit + i
      let j = i % 3
      let name = breeds[j]

      res.append(
        CatBreedResponse(
          id: "\(id)",
          name: name,
          origin: nil,
          description: nil,
          lifespan: "lifespan",
          temperament: "temperament",
          referenceImageId: "0XYvRd7oD"
        )
      )
    }

    return .success(res)
  } searchBreeds: { _ in
    return .success([])
  } fetchImage: { _ in .success(.assets(.breed)) }

}

// MARK: Dependency
extension DependencyValues {

  var breedSearchEnvironment: BreedSearchEnvironment {
    get { self[BreedSearchEnvironmentKey.self] }
    set { self[BreedSearchEnvironmentKey.self] = newValue }
  }

}

private enum BreedSearchEnvironmentKey: DependencyKey {

  static let liveValue = BreedSearchEnvironment.live

}
