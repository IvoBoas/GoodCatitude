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

    await store.receive(.handleBreedsSearchResponse("bengal", .success(breeds))) { state in
      state.isLoading = false
    }

    await store.receive(.updateBreeds(breeds))
  }

  func testHandleBreedsSearchResponse_Failure() async {
    let error = BreedSearchFeature.BreedSearchError.fetchBreedsFailed(.networkUnavailable)
    let failure = BreedSearchFailureMessageHelper.makeFailure(for: error)
    let query = "Siamese"

    let store = await makeSUT(searchBreedsFailure: error)

    await store.send(.searchBreed(query)) { state in
      state.isLoading = true
    }

    await store.receive(.handleBreedsSearchResponse(query, .failure(error))) { state in
      state.isLoading = false
    }

    await store.receive(.hadFailure(failure))

    await store.receive(.searchBreedLocal(query)) { state in
      state.isLoading = true
    }

    await store.receive(.handleLocalBreedsSearch([])) { state in
      state.isLoading = false
    }

    await store.receive(.updateBreeds([]))
  }
  
}


extension SearchBreedsDomainTests {

  private func makeSUT(
    isLoading: Bool = false,
    searchBreedsFailure: BreedSearchFeature.BreedSearchError? = nil
  ) async -> TestStore<SearchBreedsDomain.State, SearchBreedsDomain.Action> {
    let breedSearchEnvironment = BreedSearchEnvironment(
      fetchBreeds: { _, _ in return .success(TestsSeeds.breedSeedsLoading) },
      fetchLocalBreeds: { _, _ in return TestsSeeds.breedSeedsLoading },
      searchBreeds: { query in
        if let searchBreedsFailure {
          return .failure(searchBreedsFailure)
        }

        return .success(
          TestsSeeds.breedSeedsLoading.filter { $0.name.lowercased().contains(query) }
        )
      },
      searchBreedsLocally: { query in
        return []
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

