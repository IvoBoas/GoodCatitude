//
//  LocalStorageDomainTests.swift
//  GoodCatitudeTests
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import XCTest
import ComposableArchitecture
@testable import GoodCatitude

final class LocalStorageDomainTests: XCTestCase {

  func testStoreBreedsLocally_Success() async {
    let store = await makeSUT()

    let breeds = TestsSeeds.breedSeedsLoading

    await store.send(.storeBreedsLocally(breeds))
    await store.receive(.handleStoreResult(.success))
  }

  func testStoreBreedsLocally_Failure() async {
    let breeds = TestsSeeds.breedSeedsLoading
    let error = CrudError.entityCreationFailed
    let failureType = BreedSearchFailureMessageHelper.makeFailure(
      for: .storeBreedsFailed(error)
    )

    let store = await makeSUT { return .error(error) }

    await store.send(.storeBreedsLocally(breeds))
    await store.receive(.handleStoreResult(.error(error)))
    await store.receive(.hadFailure(failureType))
  }

}


extension LocalStorageDomainTests {

  private func makeSUT(
    storeBreeds: (() -> EmptyResult<CrudError>)? = nil
  ) async -> TestStore<LocalStorageDomain.State, LocalStorageDomain.Action> {
    let breedSearchEnvironment = BreedSearchEnvironment(
      fetchBreeds: { _, _ in return .success(TestsSeeds.breedSeedsLoading) },
      fetchLocalBreeds: { _, _ in return TestsSeeds.breedSeedsLoading },
      searchBreeds: { _ in return .success([]) },
      searchBreedsLocally: { _ in return [] },
      storeBreedsLocally: { _ in return storeBreeds?() ?? .success },
      updateBreedIsFavorite: { _, _ in return .success }
    )

    return await TestStore(
      initialState: LocalStorageDomain.State()
    ) { LocalStorageDomain() } withDependencies: { dependencies in
      dependencies.breedSearchEnvironment = breedSearchEnvironment
      dependencies.persistentContainer = PersistenceController(inMemory: true).container
      dependencies.catBreedCrud = CatBreedCrud()
      dependencies.favouriteBreedsEnvironment = .preview
      dependencies.fetchImageEnvironment = .preview
    }
  }

}
