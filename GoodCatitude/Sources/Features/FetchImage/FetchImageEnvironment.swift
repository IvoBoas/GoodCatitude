//
//  FetchImageEnvironment.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct FetchImageEnvironment {

  var fetchImageInfo: (_ id: String) async -> Result<ImageSource, BreedSearchFeature.BreedSearchError>
  var storeImageLocally: (_ data: Data, _ filename: String) -> Void
  var loadLocalImage: (_ filename: String) -> Data?
  var fetchRemoteImageData: (_ url: String) async -> Result<Data, BreedSearchFeature.BreedSearchError>

}

// MARK: Live Implementation
extension FetchImageEnvironment {

  static let live = Self(
    fetchImageInfo: fetchImageInfoImplementation,
    storeImageLocally: ImageStorageManager.saveImage,
    loadLocalImage: ImageStorageManager.loadImage,
    fetchRemoteImageData: fetchRemoteImageDataImplementation
  )

  private static func fetchImageInfoImplementation(
    id: String
  ) async -> Result<ImageSource, BreedSearchFeature.BreedSearchError> {
    return await HttpClient.getRequest(endpoint: .image(id: id))
      .mapError { .fetchImageFailed($0)}
      .map { (image: CatImageResponse) -> ImageSource in
        return .remote(id, image.url)
      }
  }

  private static func fetchImageImplementation(
    id: String
  ) async -> Result<ImageSource, BreedSearchFeature.BreedSearchError> {
    return await HttpClient.getRequest(endpoint: .image(id: id))
      .mapError { .fetchImageFailed($0)}
      .map { (image: CatImageResponse) -> ImageSource in
        return .remote(id, image.url)
      }
  }

  private static func fetchRemoteImageDataImplementation(
    from url: String
  ) async -> Result<Data, BreedSearchFeature.BreedSearchError> {
    return await HttpClient.getDataRequest(from: url)
      .mapError { .fetchBreedsFailed($0) }
      .map { tryToCompressData($0) }
  }

  private static func tryToCompressData(
    _ data: Data,
    compression: CGFloat = 0.5
  ) -> Data {
    if let compressData = UIImage(data: data)?.jpegData(compressionQuality: compression) {
      return compressData
    }

    return data
  }

}

fileprivate extension UIImage {
  func resized(to targetSize: CGSize) -> UIImage {
    let format = UIGraphicsImageRendererFormat()

    format.scale = 1

    let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

    return renderer.image { _ in
      self.draw(in: CGRect(origin: .zero, size: targetSize))
    }
  }
}

// MARK: Preview Implementation
extension FetchImageEnvironment {

  static let preview = Self(
    fetchImageInfo: { _ in return .success(.assets(.breed)) },
    storeImageLocally: { _, _ in },
    loadLocalImage: { _ in return UIImage(resource: .breed).pngData() },
    fetchRemoteImageData: { _ in return .success(UIImage(resource: .breed).pngData()!) }
  )

}


