//
//  CatBreedEntryView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import SwiftUI
import Kingfisher


struct CatBreedEntryView: View {

  let breed: CatBreed

  var body: some View {
    VStack(alignment: .center, spacing: 4) {
      CatBreedEntryImage(source: breed.image)
        .equatable()
        .frame(maxHeight: .infinity, alignment: .top)

      Text(breed.name)
        .font(.footnote)
        .lineLimit(2)
        .multilineTextAlignment(.leading)
    }
  }

}

struct CatBreedEntryImage: View, Equatable {

  let source: ImageSource

  var body: some View {
    switch source {
    case .loading:
      makeProgressView()

    case .assets(let name):
      Image(name)
        .resizable()
        .scaledToFill()
        .frame(width: 100, height: 100)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 8))

    case .local(_, let data):
      if let image = UIImage(data: data) {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
          .frame(width: 100, height: 100)
          .clipped()
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }

    case .remote(_, let url):
      KFImage(URL(string: url))
        .placeholder { makeProgressView() }
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
  CatBreedEntryView(
    breed: CatBreed(
      id: "1",
      name: "Abyssinian",
      countryCode: nil,
      origin: nil,
      description: nil,
      lifespan: "",
      temperament: "",
      isFavourite: true,
      referenceImageId: "1",
      image: .assets(.breed)
    )
  )
}
