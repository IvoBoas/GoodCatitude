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

}

// MARK: Service Implementation
extension BreedSearchEnvironment {

  static let live = Self { page, limit in
    return await HttpClient.getRequest(
      url: "https://api.thecatapi.com/v1/breeds",
      params: [ "page": page, "limit": limit ]
    )
    .mapError { _ in .fetchFailed }
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
          image: .init(
            id: "1",
            width: 1024,
            height: 1024,
            url: "url"
          )
        )
      )
    }

    return .success(res)
  }

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
