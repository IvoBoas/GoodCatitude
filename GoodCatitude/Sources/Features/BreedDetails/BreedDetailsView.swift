//
//  BreedDetailsView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import SwiftUI
import ComposableArchitecture

struct BreedDetailsView: View {
  let store: StoreOf<BreedDetailsFeature>

  var body: some View {
    WithViewStore(store, observe: { $0.breed }) { viewStore in
      VStack(spacing: 16) {
        Text(viewStore.name)
          .font(.largeTitle)

        if let description = viewStore.description {
          Text(description)
            .font(.body)
        }
      }
      .padding()
      .navigationTitle("Breed Details")
    }
  }
}

#Preview {
  let mockBreed = CatBreed(
    id: "1",
    name: "Siamese",
    origin: nil,
    description: "Elegant and graceful, the Siamese cat is one of the oldest and most recognizable Asian breeds.",
    lifespan: "",
    temperament: "",
    referenceImageId: "1",
    image: .assets(.breed)
  )

  return BreedDetailsView(
    store: Store(initialState: BreedDetailsFeature.State(breed: mockBreed)) {
      BreedDetailsFeature()
    }
  )
}
