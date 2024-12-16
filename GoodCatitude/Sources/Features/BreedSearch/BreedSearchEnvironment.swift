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

  var fetchBreeds: (_ page: Int, _ limit: Int) async -> Result<[CatBreed], BreedSearchFeature.BreedSearchError>
  var fetchLocalBreeds: (_ page: Int, _ limit: Int) async -> [CatBreed]
  var searchBreeds: (_ query: String) async -> Result<[CatBreed], BreedSearchFeature.BreedSearchError>
  var searchBreedsLocally: (_ query: String) async -> [CatBreed]
  var storeBreedsLocally: (_ breeds: [CatBreed]) async -> EmptyResult<CrudError>
  var updateBreedIsFavorite: (_ id: String, _ value: Bool) async -> EmptyResult<CrudError>

}

// MARK: Live Implementation
extension BreedSearchEnvironment {

  static let live = Self(
    fetchBreeds: fetchBreedsImplementation,
    fetchLocalBreeds: fetchLocalBreedsImplementation,
    searchBreeds: searchBreedsImplementation,
    searchBreedsLocally: searchBreedsLocallyImplementation,
    storeBreedsLocally: storeBreedsLocallyImplementation,
    updateBreedIsFavorite: updateBreedIsFavoriteImplementation
  )

  private static func fetchBreedsImplementation(
    page: Int,
    limit: Int
  ) async -> Result<[CatBreed], BreedSearchFeature.BreedSearchError> {
    let response: HttpRequestResult<[CatBreedResponse]> = await HttpClient.getRequest(
      endpoint: .breeds(page: page, limit: limit)
    )

    switch response {
    case .success(let responses):
      return await .success(injectIsFavourite(responses))

    case .error(let error):
      return .failure(.fetchBreedsFailed(error))
    }
  }

  private static func fetchLocalBreedsImplementation(
    page: Int,
    limit: Int
  ) -> [CatBreed] {
    @Dependency(\.catBreedCrud) var crud
    @Dependency(\.persistentContainer) var container

    let context = container.viewContext

    return context.performAndWait {
      return crud.getCatBreedPage(page, limit: limit, moc: context)
        .compactMap { entity in
          CatBreed(
            id: entity.id,
            name: entity.name,
            countryCode: entity.countryCode,
            origin: entity.origin,
            description: entity.breedDescription,
            lifespan: entity.lifespan,
            temperament: entity.temperament,
            isFavourite: entity.isFavourite,
            referenceImageId: entity.imageId,
            image: .loading
          )
        }
    }
  }

  private static func searchBreedsImplementation(
    query: String
  ) async -> Result<[CatBreed], BreedSearchFeature.BreedSearchError> {
    let response: HttpRequestResult<[CatBreedResponse]> = await HttpClient.getRequest(
      endpoint: .searchBreeds(query: query)
    )

    switch response {
    case .success(let responses):
      return await .success(injectIsFavourite(responses))

    case .error(let error):
      return .failure(.fetchBreedsFailed(error))
    }
  }

  private static func searchBreedsLocallyImplementation(
    query: String
  ) async -> [CatBreed] {
    @Dependency(\.catBreedCrud) var crud
    @Dependency(\.persistentContainer) var container

    let context = container.viewContext

    return context.performAndWait {
      return crud.searchCatBreed(query: query, moc: context)
        .compactMap { entity in
          CatBreed(
            id: entity.id,
            name: entity.name,
            countryCode: entity.countryCode,
            origin: entity.origin,
            description: entity.breedDescription,
            lifespan: entity.lifespan,
            temperament: entity.temperament,
            isFavourite: entity.isFavourite,
            referenceImageId: entity.imageId,
            image: .loading
          )
        }
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

  private static func updateBreedIsFavoriteImplementation(
    id: String,
    value: Bool
  ) async -> EmptyResult<CrudError>{
    @Dependency(\.catBreedCrud) var crud
    @Dependency(\.persistentContainer) var container

    let context = container.newBackgroundContext()

    return await context.perform {
      let entity = crud.getCatBreed(id, moc: context)

      entity?.isFavourite = value

      return context.saveIfNeeded()
    }
  }

  private static func injectIsFavourite(
    _ responses: [CatBreedResponse]
  ) async -> [CatBreed] {
    @Dependency(\.catBreedCrud) var crud
    @Dependency(\.persistentContainer) var container

    let context = container.viewContext

    return await context.perform {
      return responses.map {
        let isFavourite = crud.getCatBreed($0.id, moc: context)?.isFavourite

        return CatBreed(
          from: $0,
          isFavourite: isFavourite ?? false
        )
      }
    }
  }


}

// MARK: Preview Implementation
extension BreedSearchEnvironment {

  static let preview = Self {
    return .success(generateMockBreeds(page: $0, limit: $1))
  } fetchLocalBreeds: {
    return generateMockBreeds(page: $0, limit: $1)
  } searchBreeds: { query in
    return .success(
      generateMockBreeds(page: 0, limit: 10)
        .filter { $0.name.lowercased().contains(query.lowercased()) }
    )
  } searchBreedsLocally: { query in
    return generateMockBreeds(page: 0, limit: 10)
      .filter { $0.name.lowercased().contains(query.lowercased()) }
  } storeBreedsLocally: { _ in
    return .success
  } updateBreedIsFavorite: { _, _ in
    return .success
  }

  private static func generateMockBreeds(page: Int, limit: Int) -> [CatBreed] {
    let breeds = [
      "Abyssinian",
      "Bengal",
      "Siamese"
    ]

    var res = [CatBreed]()

    for i in 0..<limit {
      let id = page * limit + i
      let j = i % 3
      let name = breeds[j]

      res.append(
        CatBreed(
          id: "\(id)",
          name: name,
          countryCode: nil,
          origin: nil,
          description: nil,
          lifespan: "lifespan",
          temperament: "temperament",
          isFavourite: Bool.random(),
          referenceImageId: "0XYvRd7oD",
          image: .loading
        )
      )
    }

    return res
  }

}
