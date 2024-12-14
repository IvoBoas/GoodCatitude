//
//  CatBreedImageMO.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 14/12/2024.
//

import Foundation
import CoreData

class CatBreedImageMO: NSManagedObject {

  @NSManaged var id: String
  @NSManaged var filename: String

  // Relationships
  @NSManaged var breed: CatBreedMO

  convenience init?(
    id: String,
    filename: String,
    breed: CatBreedMO,
    moc: NSManagedObjectContext
  ) {
    guard let entity = NSEntityDescription.entity(forEntityName: "CatBreedImage", in: moc) else {
      return nil
    }

    self.init(entity: entity, insertInto: moc)

    self.id = id
    self.filename = filename
    self.breed = breed
  }

}
