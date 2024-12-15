//
//  BreedSearchView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct BreedSearchView: View {

  @Bindable var store: StoreOf<BreedSearchFeature>

  let gridColumns: [GridItem] = Array(
    repeating: GridItem(.flexible(), spacing: 16),
    count: 3
  )

  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      VStack(spacing: 16) {
        TextField(
          "Search breeds",
          text: Binding( // TODO: Remake this using composable native methods
            get: { store.searchQuery },
            set: { store.send(.updateSearchQueryDebounced($0)) }
          )
        )
        .textFieldStyle(.roundedBorder)
        .padding(leading: 24, trailing: 24)

        ScrollView {
          LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(store.breeds, id: \.id) { breed in
              NavigationLink(state: BreedDetailsFeature.State(breed: breed)) {
                CatBreedEntryView(breed: breed)
                  .frame(maxHeight: .infinity, alignment: .top)
                  .onAppear {
                    store.send(.fetchNextPageIfLast(id: breed.id))
                  }
              }
              .buttonStyle(.borderless)
            }
          }
          .padding(
            leading: 24,
            bottom: 24,
            trailing: 24
          )

          if store.isLoading {
            ProgressView()
          }
        }
        .scrollIndicators(.hidden)
      }
      .onAppear {
        store.send(
          .fetchBreedsDomain(.fetchNextPage)
        )
      }
      .navigationTitle("Breeds")
    } destination: { store in
      BreedDetailsView(store: store)
    }
  }

}

struct CatBreedEntryView: View {

  let breed: CatBreed

  var body: some View {
    VStack(alignment: .center, spacing: 4) {
      makeImage()
        .frame(maxHeight: .infinity, alignment: .top)

      Text(breed.name)
        .font(.footnote)
        .lineLimit(2)
        .multilineTextAlignment(.leading)
    }
  }

  @MainActor @ViewBuilder
  private func makeImage() -> some View {
    switch breed.image {
    case .loading:
      makeProgressView()

    case .assets(let name):
      Image(name)
        .resizable()
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerRadius: 8))

    case .data(let data):
      Image(uiImage: UIImage(data: data) ?? UIImage())
        .resizable()
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerRadius: 8))

    case .remote(let url):
      KFImage(URL(string: url))
        .placeholder {
          makeProgressView()
        }
        .loadDiskFileSynchronously()
        .cacheOriginalImage()
        .resizable()
        .scaledToFill()
        .frame(width: 100, height: 100)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }

  @ViewBuilder
  private func makeProgressView() -> some View {
    ProgressView()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .aspectRatio(1, contentMode: .fit)
  }

}

#Preview {
  BreedSearchView(
    store: Store(initialState: BreedSearchFeature.State()) {
      BreedSearchFeature()
    } withDependencies: {
      $0.breedSearchEnvironment = BreedSearchEnvironment.preview
    }
  )
}

#Preview {
  CatBreedEntryView(
    breed: CatBreed(
      id: "1",
      name: "Abyssinian",
      origin: nil,
      description: nil,
      lifespan: "",
      temperament: "",
      referenceImageId: "1",
      image: .assets(.breed)
    )
  )
}
