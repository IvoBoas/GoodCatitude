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
  let origin: String?
  let description: String?
  let lifespan: String
  let temperament: String
  let referenceImageId: String?
  var image: ImageSource

  init(
    id: String,
    name: String,
    origin: String?,
    description: String?,
    lifespan: String,
    temperament: String,
    referenceImageId: String?,
    image: ImageSource
  ) {
    self.id = id
    self.name = name
    self.origin = origin
    self.description = description
    self.lifespan = lifespan
    self.temperament = temperament
    self.referenceImageId = referenceImageId
    self.image = image
  }

  init(
    from response: CatBreedResponse
  ) {
    self.id = response.id
    self.name = response.name
    self.origin = response.origin
    self.description = response.description
    self.lifespan = response.lifespan
    self.temperament = response.temperament
    self.referenceImageId = response.referenceImageId
    self.image = .loading
  }

}
