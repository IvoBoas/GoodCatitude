//
//  Persistence.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import CoreData

struct PersistenceController {

  static let shared = PersistenceController()
  static var preview = PersistenceController(inMemory: true)

  let container: NSPersistentContainer
  
  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "GoodCatitude")

    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }

    container.loadPersistentStores { description, error in
      if let error = error {
        fatalError("Error: \(error.localizedDescription)")
      }
    }

    container.viewContext.automaticallyMergesChangesFromParent = true
  }

}

extension NSManagedObjectContext {

  func saveIfNeeded() -> EmptyResult<CrudError> {
    do {
      if hasChanges {
        try save()
      }
      
      return .success
    } catch {
      return .error(.saveChangesFailed)
    }
  }

}
