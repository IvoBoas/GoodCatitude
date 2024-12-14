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

  func testFetchNextPage_Success() async {
    let (store, _) = await makeSUT()

    await store.send(.fetchNextPage) { state in
      state.isLoading = true
      state.failure = nil
    }

    await store.receive(\.handleBreedsResponse) { state in
      state.isLoading = false
      state.currentPage = 1
      state.hasMorePages = true
      state.breeds = BreedSearchFeatureTests.breedSeedsInitial
    }

    await store.receive(.fetchImage(breedId: "1", imageId: "1"))
    await store.receive(.fetchImage(breedId: "2", imageId: "2"))

    await MainActor.run { store.exhaustivity = .off }

    await store.receive(.handleImage(breedId: "1", .success(.remote("1"))))
    await store.receive(.handleImage(breedId: "2", .success(.remote("2"))))

    await store.assert { state in
      state.breeds = BreedSearchFeatureTests.breedSeedsFinal
    }
  }

  func testFetchNextPage_AlreadyLoading() async {
    let (store, _) = await makeSUT(isLoading: true)

    await store.send(.fetchNextPage)
  }

  func testFetchNextPage_NoMorePage() async {
    let (store, _) = await makeSUT(hasMorePages: false)

    await store.send(.fetchNextPage)
  }

  func testFetchNextPageIfLast_WithEmptyBreeds() async {
    let (store, _) = await makeSUT()

    await store.send(.fetchNextPageIfLast(id: "1"))
    await store.receive(\.fetchNextPage) { state in
      state.isLoading = true
      state.failure = nil
    }
    await store.receive(\.handleBreedsResponse) { state in
      state.isLoading = false
      state.currentPage = 1
      state.hasMorePages = true
      state.breeds = BreedSearchFeatureTests.breedSeedsInitial
    }

    await MainActor.run { store.exhaustivity = .off }

    await store.receive(.handleImage(breedId: "1", .success(.remote("1"))))
    await store.receive(.handleImage(breedId: "2", .success(.remote("2"))))
  }

  func testFetchNextPageIfLast_WithMatchingId() async {
    let (store, _) = await makeSUT(breeds: BreedSearchFeatureTests.breedSeedsInitial)

    await store.send(.fetchNextPageIfLast(id: "2"))
    await store.receive(\.fetchNextPage) { state in
      state.isLoading = true
      state.failure = nil
    }

    await MainActor.run { store.exhaustivity = .off }
  }

  func testFetchNextPageIfLast_WithNonMatchingId() async {
    let (store, _) = await makeSUT(breeds: BreedSearchFeatureTests.breedSeedsInitial)

    await store.send(.fetchNextPageIfLast(id: "1"))
  }

  func testHandleBreedsResposne_EmptyResponse() async {
    let (store, _) = await makeSUT(isLoading: true)

    await store.send(.handleBreedsResponse(.success([]))) { state in
      state.isLoading = false
      state.hasMorePages = false
    }
  }

  func testHandleBreedsResponse_Failure() async {
    let (store, _) = await makeSUT(isLoading: true)
    let error = BreedSearchFeature.BreedSearchError.fetchBreedsFailed(.networkUnavailable)

    await store.send(.handleBreedsResponse(.failure(error))) { state in
      state.isLoading = false
      state.currentPage = 0
      state.hasMorePages = true
      state.failure = .error(message: "No internet connection. Please try again later.")
    }
  }

  func testUpdateSearchQuery_SameQuery() async {
    let query = "some query"
    let (store, _) = await makeSUT(searchQuery: query)

    await store.send(.updateSearchQueryDebounced(query))
  }

  func testUpdateSearchQuery_EmptyQuery() async {
    let (store, clock) = await makeSUT(
      breeds: BreedSearchFeatureTests.breedSeedsFinal,
      searchQuery: "some query"
    )

    await store.send(.updateSearchQueryDebounced("")) { state in
      state.searchQuery = ""
    }

    await clock.advance(by: .milliseconds(150))

    await store.receive(\.handleSearchQuery) { state in
      state.currentPage = 0
      state.breeds = []
      state.hasMorePages = true
    }

    await store.receive(\.fetchNextPage) { state in
      state.isLoading = true
      state.failure = nil
    }

    await MainActor.run { store.exhaustivity = .off }
  }

  func testSearchBreed_Success() async {
    let query = "bengal"
    let (store, clock) = await makeSUT()

    await store.send(.updateSearchQueryDebounced(query)) { state in
      state.searchQuery = query
    }

    await clock.advance(by: .milliseconds(150))

    await store.receive(\.handleSearchQuery) { state in
      state.currentPage = 0
      state.breeds = []
      state.hasMorePages = false
    }

    await store.receive(\.searchBreed) { state in
      state.isLoading = true
      state.failure = nil
    }

    let response = CatBreedResponse(id: "1", name: "Bengal")
    let breedInitial = CatBreed(id: "1", name: "Bengal", image: .loading)
    let breedFinal = CatBreed(id: "1", name: "Bengal", image: .remote("1"))

    await store.receive(.handleBreedsSearchResponse(.success([response]))) { state in
      state.isLoading = false
      state.breeds = [breedInitial]
    }

    await store.receive(.fetchImage(breedId: "1", imageId: "1"))

    await store.receive(.handleImage(breedId: "1", .success(.remote("1")))) { state in
      state.breeds = [breedFinal]
    }
  }

}

extension BreedSearchFeatureTests {

  static let breedSeedsInitial = [
    CatBreed(id: "1", name: "Bengal", image: .loading),
    CatBreed(id: "2", name: "Siamese", image: .loading)
  ]

  static let breedSeedsFinal = [
    CatBreed(id: "1", name: "Bengal", image: .remote("1")),
    CatBreed(id: "2", name: "Siamese", image: .remote("2"))
  ]

  static let responseSeeds = [
    CatBreedResponse(id: "1", name: "Bengal"),
    CatBreedResponse(id: "2", name: "Siamese")
  ]

  private func makeSUT(
    breeds: [CatBreed] = [],
    isLoading: Bool = false,
    hasMorePages: Bool = true,
    searchQuery: String = ""
  ) async -> (TestStore<BreedSearchFeature.State, BreedSearchFeature.Action>, TestClock<Duration>) {
    let responseSeeds = BreedSearchFeatureTests.responseSeeds

    let testEnvironment = BreedSearchEnvironment { page, limit in
      return .success(responseSeeds)
    } searchBreeds: { query in
      return .success(
        responseSeeds.filter { $0.name.lowercased().contains(query) }
      )
    } fetchImage: { id in
      return .success(
        .remote(id)
      )
    } storeBreedsLocally: { _ in
      return .success
    }

    let clock = TestClock()

    return await (TestStore(
      initialState: BreedSearchFeature.State(
        breeds: breeds,
        searchQuery: searchQuery,
        isLoading: isLoading,
        hasMorePages: hasMorePages
      )
    ) { BreedSearchFeature() } withDependencies: { dependencies in
      dependencies.mainQueue = DispatchQueue.test.eraseToAnyScheduler()
      dependencies.breedSearchEnvironment = testEnvironment
      dependencies.persistentContainer = PersistenceController(inMemory: true).container
      dependencies.catBreedCrud = CatBreedCrud()
      dependencies.continuousClock = clock
    }, clock)
  }

}

fileprivate extension CatBreedResponse {

  init(
    id: String,
    name: String
  ) {
    self.init(
      id: id,
      name: name,
      origin: nil,
      description: nil,
      lifespan: "",
      temperament: "",
      referenceImageId: id
    )
  }

}

fileprivate extension CatBreed {

  init(
    id: String,
    name: String,
    image: ImageSource
  ) {
    self.init(
      id: id,
      name: name,
      origin: nil,
      description: nil,
      lifespan: "",
      temperament: "",
      referenceImageId: id,
      image: image
    )
  }

}
