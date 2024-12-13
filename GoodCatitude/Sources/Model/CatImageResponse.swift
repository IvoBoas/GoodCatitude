//
//  CatImageResponse.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 13/12/2024.
//

import Foundation

struct CatImageResponse: Decodable, Equatable {

  let id: String
  let url: String
  let width: Int
  let height: Int

}
