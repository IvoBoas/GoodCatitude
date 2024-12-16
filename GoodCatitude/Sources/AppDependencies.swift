//
//  AppDependencies.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 14/12/2024.
//

import Foundation
import ComposableArchitecture
import CoreData

extension DependencyValues {

  var persistentContainer: NSPersistentContainer {
    get { self[PersistentContainerKeys.self] }
    set { self[PersistentContainerKeys.self] = newValue }
  }

  var catBreedCrud: CatBreedCrud {
    get { self[CatBreedCrudKey.self] }
    set { self[CatBreedCrudKey.self] = newValue }
  }

  var breedSearchEnvironment: BreedSearchEnvironment {
    get { self[BreedSearchEnvironmentKey.self] }
    set { self[BreedSearchEnvironmentKey.self] = newValue }
  }

  var favouriteBreedsEnvironment: FavouriteBreedsEnvironment {
    get { self[FavouriteBreedsEnvironmentKey.self] }
    set { self[FavouriteBreedsEnvironmentKey.self] = newValue }
  }

  var fetchImageEnvironment: FetchImageEnvironment {
    get { self[FetchImageEnvironmentKey.self] }
    set { self[FetchImageEnvironmentKey.self] = newValue }
  }

}

private enum PersistentContainerKeys: DependencyKey {
  static let liveValue = PersistenceController.shared.container
  static let previewValue = PersistenceController.preview.container
  static let testValue = PersistenceController(inMemory: true).container
}

private enum CatBreedCrudKey: DependencyKey {
  static let liveValue = CatBreedCrud()
  static let previewValue = CatBreedCrud()
  static let testValue = CatBreedCrud()
}

private enum BreedSearchEnvironmentKey: DependencyKey {
  static let liveValue = BreedSearchEnvironment.live
  static let previewValue = BreedSearchEnvironment.preview
  static let testValue = BreedSearchEnvironment.preview
}

private enum FavouriteBreedsEnvironmentKey: DependencyKey {
  static let liveValue = FavouriteBreedsEnvironment.live
  static let previewValue = FavouriteBreedsEnvironment.preview
  static let testValue = FavouriteBreedsEnvironment.preview
}

private enum FetchImageEnvironmentKey: DependencyKey {
  static let liveValue = FetchImageEnvironment.live
  static let previewValue = FetchImageEnvironment.preview
  static let testValue = FetchImageEnvironment.preview
}
