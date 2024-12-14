//
//  CatBreedMO.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 14/12/2024.
//

import Foundation
import CoreData

class CatBreedMO: NSManagedObject {

  @NSManaged var id: String
  @NSManaged var name: String
  @NSManaged var origin: String?
  @NSManaged var breedDescription: String?
  @NSManaged var lifespan: String
  @NSManaged var temperament: String
  @NSManaged var imageId: String?

  // Relationships
  @NSManaged var image: CatBreedImageMO?

  convenience init?(
    id: String,
    name: String,
    origin: String?,
    breedDescription: String?,
    lifespan: String,
    temperament: String,
    imageId: String?,
    moc: NSManagedObjectContext
  ) {
    guard let entity = NSEntityDescription.entity(forEntityName: "CatBreed", in: moc) else {
      return nil
    }

    self.init(entity: entity, insertInto: moc)

    self.id = id
    self.name = name
    self.origin = origin
    self.breedDescription = breedDescription
    self.lifespan = lifespan
    self.temperament = temperament
    self.imageId = imageId
    self.image = nil
  }

}
