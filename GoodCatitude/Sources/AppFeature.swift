//
//  AppFeature.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {

  enum Tab: String {
    case breeds = "breeds"
    case other = "other"
  }

  struct State: Equatable {
    var selectedTab: Tab = .breeds
    var breedSearchState = BreedSearchFeature.State()
  }

  enum Action: Equatable {
    case tabSelected(Tab)
    case breedSearchFeature(BreedSearchFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.breedSearchState, action: \.breedSearchFeature) {
      BreedSearchFeature()
    }

    Reduce { state, action in
      switch action {
      case .tabSelected(let tab):
        state.selectedTab = tab

        return .none

      case .breedSearchFeature:
        return .none
      }
    }
  }

}
