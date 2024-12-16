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

  func testOnAppear_AlreadyHasData() async {
    let (store, _) = await makeSUT(breeds: TestsSeeds.breedSeedsRemote)

    await store.send(.onAppear)
  }

  func testOnAppear_WasSearching() async {
    let (store, _) = await makeSUT(searchQuery: "some query")

    await store.send(.onAppear)
  }
  
  func testOnAppear_IsStarting() async {
    let (store, _) = await makeSUT()

    await store.send(.onAppear)
    await store.receive(.fetchBreedsDomain(.fetchNextPage)) { state in
      state.fetchBreedsState.isLoading = true
    }

    await MainActor.run { store.exhaustivity = .off }
  }

  func testFetchNextPageIfLast_WithEmptyBreeds() async {
    let (store, _) = await makeSUT()

    await store.send(.fetchNextPageIfLast(id: "1"))
    await store.receive(\.fetchBreedsDomain.fetchNextPage) { state in
      state.fetchBreedsState.isLoading = true
    }

    await MainActor.run { store.exhaustivity = .off }

    let breeds = TestsSeeds.breedSeedsLoading

    await store.receive(.fetchBreedsDomain(.fetchedBreeds(breeds)))

    for breed in breeds {
      await store.receive(.fetchImageDomain(.fetchImage(breed.id, breed.id)))
    }

    await store.receive(.localStorageDomain(.storeBreedsLocally(breeds)))
  }

  func testFetchNextPageIfLast_WithMatchingId() async {
    let breed = CatBreed(id: "0", name: "Persian", image: .remote("0", "0"))
    let (store, _) = await makeSUT(breeds: [breed])

    await store.send(.fetchNextPageIfLast(id: "0"))
    await store.receive(.fetchBreedsDomain(.fetchNextPage)) { state in
      state.fetchBreedsState.isLoading = true
    }

    await MainActor.run { store.exhaustivity = .off }

    let breeds = TestsSeeds.breedSeedsLoading
    await store.receive(.fetchBreedsDomain(.fetchedBreeds(breeds))) { state in
      state.breeds = [breed] + TestsSeeds.breedSeedsLoading
    }
  }

  func testFetchNextPageIfLast_WithNonMatchingId() async {
    let (store, _) = await makeSUT(breeds: TestsSeeds.breedSeedsLoading)

    await store.send(.fetchNextPageIfLast(id: "1"))
  }

  func testUpdateSearchQuery_SameQuery() async {
    let query = "some query"
    let (store, _) = await makeSUT(searchQuery: query)

    await store.send(.updateSearchQueryDebounced(query))
  }

  func testUpdateSearchQuery_EmptyQuery() async {
    let (store, clock) = await makeSUT(
      breeds: TestsSeeds.breedSeedsRemote,
      searchQuery: "some query"
    )

    await store.send(.updateSearchQueryDebounced("")) { state in
      state.searchQuery = ""
    }

    await MainActor.run { store.exhaustivity = .off }
    await clock.advance(by: .milliseconds(150))

    await store.receive(\.handleSearchQuery) { state in
      state.fetchBreedsState.hasMorePages = true
      state.fetchBreedsState.currentPage = 0
      state.breeds = []
    }

    await store.receive(.fetchBreedsDomain(.fetchNextPage)) { state in
      state.fetchBreedsState.isLoading = true
      state.failure = nil
    }

    await MainActor.run { store.exhaustivity = .off }
  }

}

extension BreedSearchFeatureTests {

  private func makeSUT(
    breeds: [CatBreed] = [],
    searchQuery: String = ""
  ) async -> (TestStore<BreedSearchFeature.State, BreedSearchFeature.Action>, TestClock<Duration>) {
    let breedSearchEnvironment = BreedSearchEnvironment(
      fetchBreeds: { _, _ in return .success(TestsSeeds.breedSeedsLoading) },
      searchBreeds: { query in
        return .success(TestsSeeds.breedSeedsLoading.filter { $0.name.lowercased().contains(query) })
      },
      storeBreedsLocally: { _ in return .success },
      updateBreedIsFavorite: { _, _ in return .success }
    )

    let fetchImageEnvironment = FetchImageEnvironment(
      fetchImageInfo: { id in return .success(.remote(id, id)) },
      storeImageLocally: { _, _ in return },
      loadLocalImage: { _ in return Data([0x01, 0x02, 0x03]) },
      fetchRemoteImageData: { _ in return .success(Data([0x01, 0x02, 0x03])) }
    )

    let clock = TestClock()

    return await (TestStore(
      initialState: BreedSearchFeature.State(
        breeds: breeds,
        searchQuery: searchQuery
      )
    ) { BreedSearchFeature() } withDependencies: { dependencies in
      dependencies.breedSearchEnvironment = breedSearchEnvironment
      dependencies.fetchImageEnvironment = fetchImageEnvironment
      dependencies.favouriteBreedsEnvironment = .preview
      dependencies.continuousClock = clock
      dependencies.persistentContainer = PersistenceController(inMemory: true).container
      dependencies.catBreedCrud = CatBreedCrud()
    }, clock)
  }

}
