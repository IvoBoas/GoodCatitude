//
//  BreedSearchFeatureTests.swift
//  GoodCatitudeTests
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import XCTest
import ComposableArchitecture
@testable import GoodCatitude

final class BreedSearchFeatureTests: XCTestCase {

  let testEnvironment = BreedSearchEnvironment(
    fetchBreeds: { _, _ in
      return .success(responseSeeds())
    }
  )

  func testFetchNextPage_Success() async {
    let store = await makeSUT()

    await store.send(.fetchNextPage) { state in
      state.isLoading = true
      state.errorMessage = nil
    }

    await store.receive(\.handleBreedsResponse) { state in
      state.isLoading = false
      state.currentPage = 1
      state.hasMorePages = true
      state.breeds = BreedSearchFeatureTests.breedSeeds
    }
  }

  func testFetchNextPage_AlreadyLoading() async {
    let store = await makeSUT(isLoading: true)

    await store.send(.fetchNextPage)
  }

  func testFetchNextPage_NoMorePage() async {
    let store = await makeSUT(hasMorePages: false)

    await store.send(.fetchNextPage)
  }

  func testFetchNextPageIfLast_WithEmptyBreeds() async {
    let store = await makeSUT()

    await store.send(.fetchNextPageIfLast(id: "1"))
    await store.receive(\.fetchNextPage) { state in
      state.isLoading = true
      state.errorMessage = nil
    }
    await store.receive(\.handleBreedsResponse) { state in
      state.isLoading = false
      state.currentPage = 1
      state.hasMorePages = true
      state.breeds = BreedSearchFeatureTests.breedSeeds
    }
  }

  func testFetchNextPageIfLast_WithMatchingId() async {
    let store = await makeSUT(breeds: BreedSearchFeatureTests.breedSeeds)

    await store.send(.fetchNextPageIfLast(id: "2"))
    await store.receive(\.fetchNextPage) { state in
      state.isLoading = true
      state.errorMessage = nil
    }
    await store.receive(\.handleBreedsResponse) { state in
      state.isLoading = false
      state.currentPage = 1
      state.hasMorePages = true
      state.breeds = BreedSearchFeatureTests.breedSeeds + BreedSearchFeatureTests.breedSeeds
    }
  }

  func testFetchNextPageIfLast_WithNonMatchingId() async {
    let store = await makeSUT(breeds: BreedSearchFeatureTests.breedSeeds)

    await store.send(.fetchNextPageIfLast(id: "1"))
  }

  func testHandleBreedsResposne_EmptyResponse() async {
    let store = await makeSUT(isLoading: true)

    await store.send(.handleBreedsResponse(.success([]))) { state in
      state.isLoading = false
      state.hasMorePages = false
    }
  }

  func testHandleBreedsResponse_Failure() async {
    let store = await makeSUT(isLoading: true)

    await store.send(.handleBreedsResponse(.failure(.fetchFailed))) { state in
      state.isLoading = false
      state.currentPage = 0
      state.hasMorePages = true
      state.errorMessage = "Failed to fetch cat breeds. Please try again"
    }

  }

}

extension BreedSearchFeatureTests {

  static let breedSeeds = [
    CatBreed(id: "1", name: "Bengal", origin: nil, description: nil, lifespan: "", temperament: "", imageUrl: ""),
    CatBreed(id: "2", name: "Siamese", origin: nil, description: nil, lifespan: "", temperament: "", imageUrl: "")
  ]

  static let responseSeeds = {
    let image = CatBreedResponse.Image(id: "1", width: 1024, height: 1024, url: "")

    return [
      CatBreedResponse(id: "1", name: "Bengal", origin: nil, description: nil, lifespan: "", temperament: "", image: image),
      CatBreedResponse(id: "2", name: "Siamese", origin: nil, description: nil, lifespan: "", temperament: "", image: image)
    ]
  }

  private func makeSUT(
    breeds: [CatBreed] = [],
    isLoading: Bool = false,
    hasMorePages: Bool = true
  ) async -> TestStore<BreedSearchFeature.State, BreedSearchFeature.Action> {
    return await TestStore(
      initialState: BreedSearchFeature.State(
        breeds: breeds,
        isLoading: isLoading,
        hasMorePages: hasMorePages
      )
    ) { BreedSearchFeature() } withDependencies: { dependencies in
      dependencies.breedSearchEnvironment = testEnvironment
    }
  }

}
