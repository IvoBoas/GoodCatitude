//
//  CatBreedResponse.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation

struct CatBreedResponse: Decodable, Equatable {

  let id: String
  let name: String
  let countryCode: String?
  let origin: String?
  let description: String?
  let lifespan: String
  let temperament: String
  let referenceImageId: String?

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case countryCode = "country_code"
    case origin
    case description
    case temperament
    case referenceImageId = "reference_image_id"
    case lifespan = "life_span"
  }

}
