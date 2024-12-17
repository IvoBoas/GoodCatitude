//
//  FetchBreedsDomainTests.swift
//  GoodCatitudeTests
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import XCTest
import ComposableArchitecture
@testable import GoodCatitude

final class FetchBreedsDomainTests: XCTestCase {

  func testResetPagination() async {
    let store = await makeSUT(
      currentPage: 1,
      hasMorePages: false,
      isLoading: false
    )

    await store.send(.resetPagination) {
      $0.currentPage = 0
      $0.hasMorePages = true
      $0.isLoading = false
    }
  }

  func testFetchNextPage_Success() async {
    let store = await makeSUT()
    let breeds = TestsSeeds.breedSeedsLoading

    await store.send(.fetchNextPage) {
      $0.isLoading = true
    }

    await store.receive(.handleBreedsResponse(.success(breeds))) { state in
      state.isLoading = false
      state.currentPage = 1
    }

    await store.receive(.fetchedBreeds(breeds))
  }

  func testHandleBreedsResponse_EmptyResult() async {
    let store = await makeSUT { return .success([]) }

    await store.send(.fetchNextPage) { state in
      state.isLoading = true
    }

    await store.receive(.handleBreedsResponse(.success([]))) { state in
      state.isLoading = false
      state.hasMorePages = false
    }
  }

  func testHandleBreedsResponse_Failure() async {
    let error = BreedSearchFeature.BreedSearchError.fetchBreedsFailed(.networkUnavailable)
    let failure = BreedSearchFailureMessageHelper.makeFailure(for: error)

    let store = await makeSUT { return .failure(error) }

    await store.send(.fetchNextPage) { state in
      state.isLoading = true
    }

    await store.receive(.handleBreedsResponse(.failure(error))) { state in
      state.isLoading = false
      state.fetchingLocal = true
    }

    await store.receive(.hadFailure(failure))

    await store.receive(.fetchNextPage) { state in
      state.isLoading = true
    }

    let breeds = TestsSeeds.breedSeedsLoading
    await store.receive(.handleLocalBreeds(breeds)) { state in
      state.isLoading = false
      state.currentPage = 1
    }

    await store.receive(.fetchedBreeds(breeds))

  }

  func testFetchNextPage_IsAlreadyLoading() async {
    let store = await makeSUT(isLoading: true)

    await store.send(.fetchNextPage)
  }

  func testFetchNextPage_NoMorePages() async {
    let store = await makeSUT(hasMorePages: false)

    await store.send(.fetchNextPage)
  }

}

extension FetchBreedsDomainTests {

  private func makeSUT(
    currentPage: Int = 0,
    hasMorePages: Bool = true,
    isLoading: Bool = false,
    fetchingLocal: Bool = false,
    fetchBreeds: (() -> Result<[CatBreed], BreedSearchFeature.BreedSearchError>)? = nil
  ) async -> TestStoreOf<FetchBreedsDomain> {
    let breedSearchEnvironment = BreedSearchEnvironment(
      fetchBreeds: { _, _ in
        if let fetchBreeds {
          return fetchBreeds()
        }

        return .success(TestsSeeds.breedSeedsLoading)
      },
      fetchLocalBreeds: { _, _ in
        return TestsSeeds.breedSeedsLoading
      },
      searchBreeds: { query in
        return .success(TestsSeeds.breedSeedsLoading.filter { $0.name.lowercased().contains(query) })
      },
      searchBreedsLocally: { query in
        return TestsSeeds.breedSeedsLoading.filter { $0.name.lowercased().contains(query) }
      },
      storeBreedsLocally: { _ in return .success }
    )

    return await TestStore(
      initialState: FetchBreedsDomain.State(
        currentPage: currentPage,
        hasMorePages: hasMorePages,
        isLoading: isLoading,
        fetchingLocal: fetchingLocal
      )
    ) { FetchBreedsDomain() } withDependencies: { dependencies in
      dependencies.breedSearchEnvironment = breedSearchEnvironment
      dependencies.persistentContainer = PersistenceController(inMemory: true).container
      dependencies.catBreedCrud = CatBreedCrud()
      dependencies.favouriteBreedsEnvironment = .preview
      dependencies.fetchImageEnvironment = .preview
    }
  }

}
