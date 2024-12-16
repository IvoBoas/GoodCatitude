//
//  SearchBreedsDomainTests.swift
//  GoodCatitudeTests
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import XCTest
import ComposableArchitecture
@testable import GoodCatitude

final class SearchBreedsDomainTests: XCTestCase {

  func testHandleBreedsSearchResponse_Success() async {
    let store = await makeSUT()

    await store.send(.searchBreed("bengal")) { state in
      state.isLoading = true
    }

    let breeds = [CatBreed(id: "1", name: "Bengal", image: .loading)]

    await store.receive(.handleBreedsSearchResponse(.success(breeds))) { state in
      state.isLoading = false
    }

    await store.receive(.updateBreeds(breeds))
  }

  func testHandleBreedsSearchResponse_Failure() async {
    let error = BreedSearchFeature.BreedSearchError.fetchBreedsFailed(.networkUnavailable)
    let failureType = BreedSearchFailureMessageHelper.makeFailure(for: error)

    let store = await makeSUT { return .failure(error) }

    await store.send(.searchBreed("Siamese")) { state in
      state.isLoading = true
    }

    await store.receive(.handleBreedsSearchResponse(.failure(error))) { state in
      state.isLoading = false
    }

    await store.receive(.hadFailure(failureType))
  }
  
}


extension SearchBreedsDomainTests {

  private func makeSUT(
    isLoading: Bool = false,
    searchBreeds: (() -> Result<[CatBreed], BreedSearchFeature.BreedSearchError>)? = nil
  ) async -> TestStore<SearchBreedsDomain.State, SearchBreedsDomain.Action> {
    let breedSearchEnvironment = BreedSearchEnvironment(
      fetchBreeds: { _, _ in return .success(TestsSeeds.breedSeedsLoading) },
      searchBreeds: { query in
        return searchBreeds?() ?? .success(
          TestsSeeds.breedSeedsLoading.filter { $0.name.lowercased().contains(query) }
        )
      },
      storeBreedsLocally: { _ in return .success },
      updateBreedIsFavorite: { _, _ in return .success }
    )

    return await TestStore(
      initialState: SearchBreedsDomain.State(
        isLoading: isLoading
      )
    ) { SearchBreedsDomain() } withDependencies: { dependencies in
      dependencies.breedSearchEnvironment = breedSearchEnvironment
      dependencies.persistentContainer = PersistenceController(inMemory: true).container
      dependencies.catBreedCrud = CatBreedCrud()
      dependencies.favouriteBreedsEnvironment = .preview
      dependencies.fetchImageEnvironment = .preview
    }
  }

}

