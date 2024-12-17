//
//  FavouriteBreedsEnvironment.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct FavouriteBreedsEnvironment {

  var fetchFavouriteBreeds: () async -> [CatBreed]
  var updateBreedIsFavorite: (_ id: String, _ value: Bool) async -> EmptyResult<CrudError>

}

// MARK: Live Implementation
extension FavouriteBreedsEnvironment {

  static let live = Self(
    fetchFavouriteBreeds: fetchFavouriteBreedsImplementation,
    updateBreedIsFavorite: updateBreedIsFavoriteImplementation
  )

  private static func fetchFavouriteBreedsImplementation() async -> [CatBreed] {
    @Dependency(\.catBreedCrud) var crud
    @Dependency(\.persistentContainer) var container

    let context = container.viewContext

    return context.performAndWait {
      return crud.getFavouriteBreeds(moc: context)
        .map {
          CatBreed(
            id: $0.id,
            name: $0.name,
            countryCode: $0.countryCode,
            origin: $0.origin,
            description: $0.breedDescription,
            lifespan: $0.lifespan,
            temperament: $0.temperament,
            isFavourite: $0.isFavourite,
            referenceImageId: $0.imageId,
            image: .loading
          )
        }
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

}

// MARK: Preview Implementation
extension FavouriteBreedsEnvironment {

  static let preview = Self {
    return [
      CatBreed(
        id: "1",
        name: "Siamese",
        countryCode: "TH",
        origin: "Thailand",
        description: "Elegant and graceful, the Siamese cat is one of the oldest and most recognizable Asian breeds.",
        lifespan: "15",
        temperament: "Affectionate, Social, Intelligent, Playful, Active",
        isFavourite: true,
        referenceImageId: "1",
        image: .assets(.breed)
      ),
      CatBreed(
        id: "2",
        name: "Siamese",
        countryCode: "TH",
        origin: "Thailand",
        description: "Elegant and graceful, the Siamese cat is one of the oldest and most recognizable Asian breeds.",
        lifespan: "15",
        temperament: "Affectionate, Social, Intelligent, Playful, Active",
        isFavourite: true,
        referenceImageId: "1",
        image: .assets(.breed)
      ),
      CatBreed(
        id: "3",
        name: "Siamese",
        countryCode: "TH",
        origin: "Thailand",
        description: "Elegant and graceful, the Siamese cat is one of the oldest and most recognizable Asian breeds.",
        lifespan: "15",
        temperament: "Affectionate, Social, Intelligent, Playful, Active",
        isFavourite: true,
        referenceImageId: "1",
        image: .assets(.breed)
      )
    ]
  }  updateBreedIsFavorite: { _, _ in
    return .success
  }

}

