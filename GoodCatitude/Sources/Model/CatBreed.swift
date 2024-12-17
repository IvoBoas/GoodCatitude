//
//  CatBreed.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation

struct CatBreed: Equatable, Identifiable {

  let id: String
  let name: String
  let countryCode: String?
  let origin: String?
  let description: String?
  let lifespan: String
  let temperament: String
  var isFavourite: Bool
  let referenceImageId: String?
  var image: ImageSource

  init(
    id: String,
    name: String,
    countryCode: String?,
    origin: String?,
    description: String?,
    lifespan: String,
    temperament: String,
    isFavourite: Bool,
    referenceImageId: String?,
    image: ImageSource
  ) {
    self.id = id
    self.name = name
    self.countryCode = countryCode
    self.origin = origin
    self.description = description
    self.lifespan = lifespan
    self.temperament = temperament
    self.isFavourite = isFavourite
    self.referenceImageId = referenceImageId
    self.image = image
  }

  init(
    from response: CatBreedResponse,
    isFavourite: Bool
  ) {
    self.id = response.id
    self.name = response.name
    self.countryCode = response.countryCode
    self.origin = response.origin
    self.description = response.description
    self.temperament = response.temperament
    self.referenceImageId = response.referenceImageId
    self.isFavourite = isFavourite
    self.image = .loading
    self.lifespan = response.lifespan
      .replacingOccurrences(of: " ", with: "")
      .split(separator: "-")
      .last?
      .toString() ?? response.lifespan
  }

}

extension String.SubSequence {

  func toString() -> String {
    return String(self)
  }

}
