//
//  BreedDetailsFeature.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BreedDetailsFeature {

  @ObservableState
  struct State: Equatable {
    let breed: CatBreed
  }

  enum Action: Equatable { 

  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      return .none
    }
  }
}
