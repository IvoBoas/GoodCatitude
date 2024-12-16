//
//  Tests+Helpers.swift
//  GoodCatitudeTests
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import Foundation
@testable import GoodCatitude

extension CatBreedResponse {

  init(
    id: String,
    name: String
  ) {
    self.init(
      id: id,
      name: name,
      countryCode: nil,
      origin: nil,
      description: nil,
      lifespan: "",
      temperament: "",
      referenceImageId: id
    )
  }

}

extension CatBreed {

  init(
    id: String,
    name: String,
    isFavourite: Bool = false,
    image: ImageSource
  ) {
    self.init(
      id: id,
      name: name,
      countryCode: nil,
      origin: nil,
      description: nil,
      lifespan: "",
      temperament: "",
      isFavourite: isFavourite,
      referenceImageId: id,
      image: image
    )
  }

}
