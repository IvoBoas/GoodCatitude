//
//  CatBreedEntryView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import SwiftUI
import Kingfisher


struct CatBreedEntryView: View {

  @Environment(\.colorScheme) var scheme

  let breed: CatBreed

  var body: some View {
    CatBreedEntryImage(source: breed.image)
      .scaledToFill()
      .frame(width: 100)
      .clipped()
      .overlay {
        ZStack(alignment: .bottomLeading) {
          LinearGradient(
            gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
            startPoint: .center,
            endPoint: .bottom
          )

          Text(breed.name)
            .font(.caption2.bold())
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .foregroundStyle(.white)
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: 8))
  }

}

struct CatBreedEntryImage: View {

  let source: ImageSource

  var body: some View {
    switch source {
    case .loading:
      makeProgressView()

    case .assets(let name):
      Image(name)
        .resizable()

    case .local(_, let data):
      if let image = UIImage(data: data) {
        Image(uiImage: image)
          .resizable()
      }

    case .remote(_, let url):
      KFImage(URL(string: url))
        .placeholder { makeProgressView() }
        .cacheOriginalImage()
        .resizable()
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
