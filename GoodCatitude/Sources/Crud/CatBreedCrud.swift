//
//  CatBreedCrud.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 14/12/2024.
//

import Foundation
import CoreData

final class CatBreedCrud {

  func getCatBreed(
    _ id: String,
    moc: NSManagedObjectContext
  ) -> CatBreedMO? {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CatBreed")

    fetchRequest.predicate = NSPredicate(format: "id == %@", id)
    fetchRequest.fetchLimit = 1

    return try? moc.fetch(fetchRequest).first as? CatBreedMO
  }

  func getFavouriteBreeds(
    moc: NSManagedObjectContext
  ) -> [CatBreedMO] {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CatBreed")

    fetchRequest.predicate = NSPredicate(format: "isFavourite == YES")

    return (try? moc.fetch(fetchRequest) as? [CatBreedMO]) ?? []
  }

  func getCatBreedPage(
    _ page: Int,
    limit: Int,
    moc: NSManagedObjectContext
  ) -> [CatBreedMO] {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CatBreed")

    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CatBreedMO.name, ascending: true)]
    fetchRequest.fetchLimit = limit
    fetchRequest.fetchOffset = page * limit

    return (try? moc.fetch(fetchRequest) as? [CatBreedMO]) ?? []
  }

  func searchCatBreed(
    query: String,
    moc: NSManagedObjectContext
  ) -> [CatBreedMO] {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CatBreed")

    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CatBreedMO.name, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", query)

    return (try? moc.fetch(fetchRequest) as? [CatBreedMO]) ?? []
  }

  func createCatBreed(
    id: String,
    name: String,
    countryCode: String?,
    origin: String?,
    breedDescription: String?,
    lifespan: String,
    temperament: String,
    imageId: String?,
    moc: NSManagedObjectContext
  ) -> CatBreedMO? {
    return CatBreedMO(
      id: id,
      name: name,
      countryCode: countryCode,
      origin: origin,
      breedDescription: breedDescription,
      lifespan: lifespan,
      temperament: temperament,
      imageId: imageId,
      isFavourite: false,
      moc: moc
    )
  }

  func updateCatBreed(
    _ entity: CatBreedMO,
    name: String,
    origin: String?,
    breedDescription: String?,
    lifespan: String,
    temperament: String
  ) {
    entity.name = name
    entity.origin = origin
    entity.breedDescription = breedDescription
    entity.lifespan = lifespan
    entity.temperament = temperament
  }

  func createOrUpdateCatBreed(
    id: String,
    name: String,
    countryCode: String?,
    origin: String?,
    breedDescription: String?,
    lifespan: String,
    temperament: String,
    imageId: String?,
    moc: NSManagedObjectContext
  ) -> CatBreedMO? {
    guard let entity = getCatBreed(id, moc: moc) else {
      return createCatBreed(
        id: id,
        name: name,
        countryCode: countryCode,
        origin: origin,
        breedDescription: breedDescription,
        lifespan: lifespan,
        temperament: temperament,
        imageId: imageId,
        moc: moc
      )
    }

    updateCatBreed(
      entity,
      name: name,
      origin: origin,
      breedDescription: breedDescription,
      lifespan: lifespan,
      temperament: temperament
    )

    return entity
  }

}
