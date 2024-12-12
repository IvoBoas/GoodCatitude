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
  let origin: String?
  let description: String?
  let lifespan: String
  let temperament: String
  let image: CatBreedResponse.Image

}

extension CatBreedResponse {

  struct Image: Decodable, Equatable {
    let id: String
    let width: Int
    let height: Int
    let url: String
  }

}
