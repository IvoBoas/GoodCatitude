//
//  FavouriteBreedsFeatureTest.swift
//  GoodCatitudeTests
//
//  Created by Ivo Vilas Boas  on 16/12/2024.
//

import XCTest
import ComposableArchitecture
@testable import GoodCatitude

final class FavouriteBreedsFeatureTest: XCTestCase {

  func testOnAppear_WhenHasBreeds() async {
    let store = await makeSUT(favouriteBreeds: TestsSeeds.breedSeedsRemote)

    await store.send(.onAppear)
  }

  func testOnAppear_WhenIsLoading() async {
    let store = await makeSUT(isLoading: true)

    await store.send(.onAppear)
  }

  func testOnAppear_WhenBreedsEmpty() async {
    let breeds = TestsSeeds.breedSeedsRemote
    let store = await makeSUT(fetchedFavouriteBreeds: breeds)

    await store.send(.onAppear)
    await store.receive(.reloadFavourites) { state in
      state.isLoading = true
    }

    await store.receive(.handleFavourites(breeds)) { state in
      state.isLoading = false
      state.breeds = breeds.sorted { $0.name < $1.name }
    }

    await MainActor.run { store.exhaustivity = .off }
  }

  func testReloadFavourites_Success() async {
    let breeds = TestsSeeds.breedSeedsRemote
    let store = await makeSUT(fetchedFavouriteBreeds: breeds)

    await store.send(.reloadFavourites) {
      $0.isLoading = true
    }

    await store.receive(.handleFavourites(breeds)) {
      $0.isLoading = false
      $0.breeds = breeds.sorted { $0.name < $1.name }
    }

    await MainActor.run { store.exhaustivity = .off }

    await store.receive(.fetchImageDomain(.fetchImage("1", "1")))
    await store.receive(.fetchImageDomain(.fetchImage("2", "2")))
  }

  func testToggleFavourite_AddedFavourite() async {
    let favourite = CatBreed(id: "1", name: "Bengal", isFavourite: true, image: .loading)
    let new = CatBreed(id: "2", name: "Siamese", isFavourite: true, image: .loading)
    let store = await makeSUT(favouriteBreeds: [favourite], fetchedFavouriteBreeds: [favourite, new])

    await store.send(.toggleFavourite("2", true))

    await store.receive(.reloadFavourites) { state in
      state.isLoading = true
    }

    await store.receive(.handleFavourites([favourite, new])) { state in
      state.isLoading = false
      state.breeds = [favourite, new]
    }

    // Fetch images
    await MainActor.run { store.exhaustivity = .off }
  }

  func testToggleFavourite_RemovedFavourite() async {
    let favourite = CatBreed(id: "1", name: "Bengal", isFavourite: true, image: .loading)
    let removed = CatBreed(id: "2", name: "Siamese", isFavourite: true, image: .loading)
    let store = await makeSUT(favouriteBreeds: [favourite, removed], fetchedFavouriteBreeds: [favourite])

    await store.send(.toggleFavourite("2", false))


    await store.receive(.handleFavourites([favourite])) { state in
      state.isLoading = false
      state.breeds = [favourite]
    }

    // Fetch images
    await MainActor.run { store.exhaustivity = .off }
  }

}


extension FavouriteBreedsFeatureTest {

  private func makeSUT(
    favouriteBreeds: [CatBreed] = [],
    isLoading: Bool = false,
    fetchedFavouriteBreeds: [CatBreed] = TestsSeeds.breedSeedsRemote
  ) async -> TestStoreOf<FavouriteBreedsFeature> {
    let environment = FavouriteBreedsEnvironment(
      fetchFavouriteBreeds: { return fetchedFavouriteBreeds },
      updateBreedIsFavorite: { _, _ in return .success }
    )

    return await TestStore(
      initialState: FavouriteBreedsFeature.State(
        breeds: favouriteBreeds,
        isLoading: isLoading
      )
    ) { FavouriteBreedsFeature() } withDependencies: { dependencies in
      dependencies.favouriteBreedsEnvironment = environment
      dependencies.breedSearchEnvironment = .preview
      dependencies.persistentContainer = PersistenceController(inMemory: true).container
      dependencies.catBreedCrud = CatBreedCrud()
      dependencies.fetchImageEnvironment = .preview
    }
  }

}


