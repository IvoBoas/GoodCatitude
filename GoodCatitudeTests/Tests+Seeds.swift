//
//  Tests+Seeds.swift
//  GoodCatitudeTests
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import Foundation
@testable import GoodCatitude

struct TestsSeeds {

  static let breedSeedsLoading = [
    CatBreed(id: "1", name: "Bengal", image: .loading),
    CatBreed(id: "2", name: "Siamese", image: .loading)
  ]

  static let breedSeedsRemote = [
    CatBreed(id: "1", name: "Bengal", image: .remote("1", "1")),
    CatBreed(id: "2", name: "Siamese", image: .remote("1", "1"))
  ]

}
