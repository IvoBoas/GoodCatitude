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
  var storeBreedsLocally: (_ breeds: [CatBreedResponse]) async -> EmptyResult<CrudError>

}

// MARK: Live Implementation
extension BreedSearchEnvironment {

  static let live = Self(
    fetchBreeds: fetchBreeds,
    searchBreeds: searchBreeds,
    fetchImage: fetchImage,
    storeBreedsLocally: storeBreedsLocally
  )

  private static func fetchBreeds(
    page: Int,
    limit: Int
  ) async -> Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError> {
    return await HttpClient.getRequest(
      endpoint: .breeds(page: page, limit: limit)
    )
    .mapError { .fetchBreedsFailed($0) }
  }

  private static func searchBreeds(
    query: String
  ) async -> Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError> {
    return await HttpClient.getRequest(
      endpoint: .searchBreeds(query: query)
    )
    .mapError { .fetchBreedsFailed($0) }
  }

  private static func fetchImage(
    id: String
  ) async -> Result<ImageSource, BreedSearchFeature.BreedSearchError> {
    return await HttpClient.getRequest(endpoint: .image(id: id))
      .mapError { .fetchImageFailed($0)}
      .map { (image: CatImageResponse) -> ImageSource in
        return .remote(image.url)
      }
  }

  private static func storeBreedsLocally(
    breeds: [CatBreedResponse]
  ) -> EmptyResult<CrudError> {
    @Dependency(\.catBreedCrud) var crud
    @Dependency(\.persistentContainer) var container

    let context = container.newBackgroundContext()

    return context.performAndWait {
      _ = breeds.compactMap { breed in
        crud.createOrUpdateCatBreed(
          id: breed.id,
          name: breed.name,
          origin: breed.origin,
          breedDescription: breed.description,
          lifespan: breed.lifespan,
          temperament: breed.temperament,
          imageId: breed.referenceImageId,
          moc: context
        )
      }

      return context.saveIfNeeded()
    }
  }

}

// MARK: Preview Implementation
extension BreedSearchEnvironment {

  static let preview = Self {
    return .success(generateMockBreeds(page: $0, limit: $1))
  } searchBreeds: { query in
    return .success(
      generateMockBreeds(page: 0, limit: 10)
        .filter { $0.name.lowercased().contains(query.lowercased()) }
    )
  } fetchImage: { _ in
      .success(
        .assets(.breed)
      )
  } storeBreedsLocally: { _ in
    return .success
  }

  private static func generateMockBreeds(page: Int, limit: Int) -> [CatBreedResponse] {
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

    return res
  }

}
