//
//  FetchImageFeatureTests.swift
//  GoodCatitudeTests
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import XCTest
import ComposableArchitecture
@testable import GoodCatitude
final class FetchImageFeatureTests: XCTestCase {

  func testFetchImage_WhenLocalImageExists() async {
    let localImageData = Data([0x01, 0x02, 0x03])
    let store = await makeSUT(localImage: localImageData)

    await store.send(.fetchImage("breed1", "image1"))
    await store.receive(.handleImage("breed1", .success(.local("image1", localImageData))))
    await store.receive(.updateImage("breed1", .local("image1", localImageData)))
  }

  func testFetchImage_WhenLocalImageDoesNotExist() async {
    let remoteData = Data([0x01, 0x02, 0x03])
    let imageInfo = ImageSource.remote("image1", "https://example.com/image.jpg")
    let store = await makeSUT(
      imageInfo: .success(imageInfo),
      localImage: nil,
      remoteImageData: .success(remoteData)
    )

    await store.send(.fetchImage("breed1", "image1"))
    await store.receive(.fetchRemoteImage("breed1", "image1"))
    await store.receive(.handleImage("breed1", .success(imageInfo)))
    await store.receive(.fetchRemoteImageData("breed1", "image1", "https://example.com/image.jpg"))
    await store.receive(.handleImageData("breed1", "image1", .success(remoteData)))

    // TODO: How to handle concurrency in merge effects?
    await store.receive(.handleImage("breed1", .success(.local("image1", remoteData))))
    await store.receive(.storeImageLocally("image1", remoteData))
    await store.receive(.updateImage("breed1", .local("image1", remoteData)))
  }

  func testHandleRemoteImageData_Failure() async {
    let error = BreedSearchFeature.BreedSearchError.fetchImageFailed(.networkUnavailable)
    let failureType = BreedSearchFailureMessageHelper.makeFailure(for: error)

    let store = await makeSUT(remoteImageData: .failure(error))

    await store.send(.fetchRemoteImageData("breed1", "image1", "https://example.com/image.jpg"))
    await store.receive(.handleImageData("breed1", "image1", .failure(error)))
    await store.receive(.hadFailure(failureType))
  }

}

extension FetchImageFeatureTests {

  private func makeSUT(
    imageInfo: Result<ImageSource, BreedSearchFeature.BreedSearchError> = .success(.remote("1", "1")),
    localImage: Data? = Data([0x01, 0x02, 0x03]),
    remoteImageData: Result<Data, BreedSearchFeature.BreedSearchError> = .success(Data([0x01, 0x02, 0x03]))
  ) async -> TestStore<FetchImageFeature.State, FetchImageFeature.Action> {
    let fetchImageEnvironment = FetchImageEnvironment(
      fetchImageInfo: { _ in return imageInfo },
      storeImageLocally: { _, _ in },
      loadLocalImage: { _ in return localImage },
      fetchRemoteImageData: { _ in return remoteImageData }
    )

    return await TestStore(
      initialState: FetchImageFeature.State()
    ) { FetchImageFeature() } withDependencies: { dependencies in
      dependencies.breedSearchEnvironment = .preview
      dependencies.fetchImageEnvironment = fetchImageEnvironment
      dependencies.favouriteBreedsEnvironment = .preview
      dependencies.persistentContainer = PersistenceController(inMemory: true).container
      dependencies.catBreedCrud = CatBreedCrud()
    }
  }

}
