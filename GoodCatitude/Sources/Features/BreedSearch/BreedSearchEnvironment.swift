//
//  BreedSearchEnvironment.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct BreedSearchEnvironment {

  var fetchBreeds: (_ page: Int, _ limit: Int) async -> Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError>
  var searchBreeds: (_ query: String) async -> Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError>
  var fetchImage: (_ id: String) async -> Result<ImageSource, BreedSearchFeature.BreedSearchError>
  var storeBreedsLocally: (_ breeds: [CatBreed]) async -> EmptyResult<CrudError>
  var storeImageLocally: (_ data: Data, _ filename: String) -> Void
  var loadLocalImage: (_ filename: String) -> Data?
  var fetchRemoteImageData: (_ url: String) async -> Result<Data, BreedSearchFeature.BreedSearchError>

}

// MARK: Live Implementation
extension BreedSearchEnvironment {

  static let live = Self(
    fetchBreeds: fetchBreedsImplementation,
    searchBreeds: searchBreedsImplementation,
    fetchImage: fetchImageImplementation,
    storeBreedsLocally: storeBreedsLocallyImplementation,
    storeImageLocally: ImageStorageManager.saveImage,
    loadLocalImage: ImageStorageManager.loadImage,
    fetchRemoteImageData: fetchRemoteImageDataImplementation
  )

  private static func fetchBreedsImplementation(
    page: Int,
    limit: Int
  ) async -> Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError> {
    return await HttpClient.getRequest(
      endpoint: .breeds(page: page, limit: limit)
    )
    .mapError { .fetchBreedsFailed($0) }
  }

  private static func searchBreedsImplementation(
    query: String
  ) async -> Result<[CatBreedResponse], BreedSearchFeature.BreedSearchError> {
    return await HttpClient.getRequest(
      endpoint: .searchBreeds(query: query)
    )
    .mapError { .fetchBreedsFailed($0) }
  }

  private static func fetchImageImplementation(
    id: String
  ) async -> Result<ImageSource, BreedSearchFeature.BreedSearchError> {
    return await HttpClient.getRequest(endpoint: .image(id: id))
      .mapError { .fetchImageFailed($0)}
      .map { (image: CatImageResponse) -> ImageSource in
        return .remote(id, image.url)
      }
  }

  private static func storeBreedsLocallyImplementation(
    breeds: [CatBreed]
  ) -> EmptyResult<CrudError> {
    @Dependency(\.catBreedCrud) var crud
    @Dependency(\.persistentContainer) var container

    let context = container.newBackgroundContext()

    return context.performAndWait {
      _ = breeds.compactMap { breed in
        crud.createOrUpdateCatBreed(
          id: breed.id,
          name: breed.name,
          countryCode: breed.countryCode,
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

  private static func fetchRemoteImageDataImplementation(
    from url: String
  ) async -> Result<Data, BreedSearchFeature.BreedSearchError> {
    return await HttpClient.getDataRequest(from: url)
      .mapError { .fetchBreedsFailed($0) }
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
  } storeImageLocally: { _, _ in
    return
  } loadLocalImage: { _ in
    return UIImage(resource: .breed).pngData()
  } fetchRemoteImageData: { _ in
    return .success(UIImage(resource: .breed).pngData()!)
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
          countryCode: nil,
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
