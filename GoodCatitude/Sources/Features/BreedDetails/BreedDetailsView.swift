//
//  BreedDetailsView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct BreedDetailsView: View {

  @Environment(\.colorScheme) var scheme

  let store: StoreOf<BreedDetailsFeature>

  @State var offset: CGPoint = .zero
  @State var subscriptionExpanded: Bool = false

  var body: some View {
    WithViewStore(store, observe: { $0.breed }) { viewStore in
      PositionObservingScrollView(offset: $offset) {
        makeImageView(source: viewStore.image)
          .clipShape(RoundedRectangle(cornerRadius: 24))
          .offset(y: -max(offset.y, 0))

        VStack(spacing: 16) {
          HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
              Text(viewStore.name)
                .font(.title3)
                .foregroundStyle(.black)

              if let origin = countryOriginValue(
                origin: viewStore.origin,
                countryCode: viewStore.countryCode
              ) {
                Text("Origin: \(origin)")
                  .font(.footnote)
                  .foregroundStyle(.black)
              }

              Text("Lifespan: \(viewStore.lifespan) years")
                .font(.footnote)
                .foregroundStyle(.black)
            }

            Spacer()

            Button { viewStore.send(.toggleIsFavorite) } label: {
              Image(systemName: viewStore.isFavourite ? "heart.fill" : "heart")
                .foregroundStyle(.red)
            }
          }
          .frame(maxWidth: .infinity)
          .padding(vertical: 8)
          .padding(horizontal: 16)
          .background(.white)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay {
            RoundedRectangle(cornerRadius: 12)
              .stroke(.gray, lineWidth: 1)
          }
          .shadow(color: scheme.foregroundColor.opacity(0.3), radius: 10)
          .padding(horizontal: 24)

          ScrollView(.horizontal) {
            HStack(spacing: 16) {
              ForEach(viewStore.temperament.split(separator: ", "), id: \.self) { temperament in
                Text(temperament)
                  .padding(vertical: 8, horizontal: 16)
                  .background(Color.brown)
                  .clipShape(RoundedRectangle(cornerRadius: 12))
              }
            }
            .padding(horizontal: 24)
          }

          if let description = viewStore.description {
            VStack(alignment: .leading, spacing: 8) {
              Text("About")
                .font(.headline)

              ExpandableTextView(
                text: description,
                lineLimit: 5,
                font: .callout,
                foregroundColor: scheme.foregroundColor,
                backgroundColor: scheme.backgroundColor,
                isExpanded: $subscriptionExpanded
              )
            }
            .padding(horizontal: 24)
          }
        }
        .padding(bottom: 64)
        .offset(y: -40)
      }
    }
    .scrollIndicators(.hidden)
    .toolbar(.hidden, for: .tabBar)
    .toolbarBackground(.hidden, for: .navigationBar)
    .ignoresSafeArea()
  }

  @MainActor @ViewBuilder
  func makeImageView(source: ImageSource) -> some View {
    switch source {
    case .loading:
      makeProgressView()

    case .assets(let name):
      Image(name)
        .resizable()
        .scaledToFill()
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 8))

    case .local(_, let data):
      Image(uiImage: UIImage(data: data) ?? UIImage())
        .resizable()
        .scaledToFill()
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 8))

    case .remote(_, let url):
      KFImage(URL(string: url))
        .placeholder { makeProgressView() }
        .loadDiskFileSynchronously()
        .cacheOriginalImage()
        .resizable()
        .scaledToFill()
        .clipped()
    }
  }

  @ViewBuilder
  private func makeProgressView() -> some View {
    ProgressView()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .aspectRatio(1, contentMode: .fit)
  }

  private func countryOriginValue(
    origin: String?,
    countryCode: String?
  ) -> String? {
    guard let origin else {
      return nil
    }

    var value = origin

    if let flag = flagEmoji(countryCode) {
      value += " \(flag)"
    }

    return value
  }

  private func flagEmoji(_ countryCode: String?) -> String? {
    guard let countryCode else {
      return nil
    }

    let base: UInt32 = 127397

    var emoji = ""

    for scalar in countryCode.uppercased().unicodeScalars {
      if let flagScalar = UnicodeScalar(base + scalar.value) {
        emoji.append(String(flagScalar))
      }
    }

    if emoji.isEmpty {
      return nil
    } else {
      return emoji
    }
  }

}

#Preview {
  let mockBreed = CatBreed(
    id: "1",
    name: "Siamese",
    countryCode: "TH",
    origin: "Thailand",
    description: "Elegant and graceful, the Siamese cat is one of the oldest and most recognizable Asian breeds.",
    lifespan: "10 - 15",
    temperament: "Affectionate, Social, Intelligent, Playful, Active",
    isFavourite: true,
    referenceImageId: "1",
    image: .assets(.breed)
  )

  return BreedDetailsView(
    store: Store(initialState: BreedDetailsFeature.State(breed: mockBreed)) {
      BreedDetailsFeature()
    }
  )
}
