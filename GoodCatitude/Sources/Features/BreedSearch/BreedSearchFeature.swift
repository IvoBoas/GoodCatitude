//
//  BreedSearchFeature.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation
import ComposableArchitecture

// TODO: What happens if search is done before ending page fetching?
// Cancel one task when another starts
@Reducer
struct BreedSearchFeature {
  
  @ObservableState
  struct State: Equatable {
    
    var breeds: [CatBreed] = []
    var searchQuery: String = ""
    var failure: FailureType?
    
    var fetchBreedsState = FetchBreedsDomain.State()
    var fetchImageState = FetchImageFeature.State()
    var searchBreedsState = SearchBreedsDomain.State()
    var localStorageState = LocalStorageDomain.State()
    
    var isLoading: Bool {
      fetchBreedsState.isLoading || searchBreedsState.isLoading
    }
    
  }
  
  enum Action: Equatable {
    case onAppear
    case fetchNextPageIfLast(id: String)
    case updateSearchQueryDebounced(String)
    case handleSearchQuery
    
    case fetchBreedsDomain(FetchBreedsDomain.Action)
    case fetchImageDomain(FetchImageFeature.Action)
    case searchBreedsDomain(SearchBreedsDomain.Action)
    case localStorageDomain(LocalStorageDomain.Action)
  }
  
  enum BreedSearchError: Error, Equatable {
    case fetchBreedsFailed(HttpError)
    case fetchImageFailed(HttpError)
    case storeBreedsFailed(CrudError)
  }
  
  @Dependency(\.breedSearchEnvironment) var environment
  @Dependency(\.continuousClock) var clock
  
  var body: some ReducerOf<Self> {
    Scope(state: \.fetchBreedsState, action: \.fetchBreedsDomain) {
      FetchBreedsDomain()
    }
    
    Scope(state: \.fetchImageState, action: \.fetchImageDomain) {
      FetchImageFeature()
    }
    
    Scope(state: \.searchBreedsState, action: \.searchBreedsDomain) {
      SearchBreedsDomain()
    }
    
    Scope(state: \.localStorageState, action: \.localStorageDomain) {
      LocalStorageDomain()
    }
    
    Reduce { state, action in
      switch action {
      case .onAppear:
        if state.breeds.isEmpty && !state.isLoading && state.searchQuery.isEmpty {
          return .send(.fetchBreedsDomain(.fetchNextPage))
        }

        return .none

      case .fetchNextPageIfLast(let id):
        return fetchNextPageIfLast(&state, id: id)
        
      case .updateSearchQueryDebounced(let query):
        return updateSearchQueryDebounced(&state, query: query)
        
      case .handleSearchQuery:
        return handleSearchQuery(&state)
        
      case .fetchBreedsDomain(let action):
        return handleFetchBreedsDomainAction(&state, action: action)
        
      case .fetchImageDomain(let action):
        return handleFetchImageDomainAction(&state, action: action)
        
      case .searchBreedsDomain(let action):
        return handleSearchBreedsDomainAction(&state, action: action)
        
      case .localStorageDomain(let action):
        return handleLocalStorageDomainAction(&state, action: action)      
      }
    }
  }
  
}

// MARK: Action Handlers
extension BreedSearchFeature {
  
  private func fetchNextPageIfLast(
    _ state: inout State,
    id: String
  ) -> Effect<Action> {
    guard isLastBreed(state, id: id), state.searchQuery.isEmpty else {
      return .none
    }

    return .send(.fetchBreedsDomain(.fetchNextPage))
  }
  
  private func handleSearchQuery(
    _ state: inout State
  ) -> Effect<Action> {
    let query = state.searchQuery
    
    state.breeds = []
    
    return .merge(
      .send(.fetchBreedsDomain(.resetPagination)),
      .send(query.isEmpty ? .fetchBreedsDomain(.fetchNextPage) : .searchBreedsDomain(.searchBreed(query)))
    )
  }
  
  private func updateSearchQueryDebounced(
    _ state: inout State,
    query: String
  ) -> Effect<Action> {
    guard query != state.searchQuery else {
      return .none
    }
    
    state.searchQuery = query
    
    return .run { send in
      try await clock.sleep(for: .milliseconds(150))
      
      await send(.handleSearchQuery)
    }
    .cancellable(id: "searchQuery", cancelInFlight: true)
  }
  
  // MARK: FetchBreedsDomain Action Handlers
  private func handleFetchBreedsDomainAction(
    _ state: inout State,
    action: FetchBreedsDomain.Action
  ) -> Effect<Action> {
    switch action {
    case .resetPagination, .handleBreedsResponse:
      return .none
      
    case .fetchNextPage:
      if state.fetchBreedsState.canLoadNextPage {
        state.failure = nil
      }
      
      return .none
      
    case .fetchedBreeds(let breeds):
      // Remove any possible duplicates
      state.breeds += breeds.filter { newBreed in
        !state.breeds.contains { $0.id == newBreed.id }
      }
      
      return .merge(
        fetchImagesForBreeds(breeds),
        .send(.localStorageDomain(.storeBreedsLocally(breeds)))
      )
      
    case .hadFailure(let failure):
      state.failure = failure
      
      return .none
    }
  }
  
  // MARK: FetchImageDomain Action Handlers
  private func handleFetchImageDomainAction(
    _ state: inout State,
    action: FetchImageFeature.Action
  ) -> Effect<Action> {
    switch action {
    case .fetchImage, .handleImage, .fetchRemoteImage,
        .handleImageData, .storeImageLocally, .fetchRemoteImageData:
      return .none
      
    case .updateImage(let breedId, let source):
      if let index = state.breeds.firstIndex(where: { $0.id == breedId }) {
        state.breeds[index].image = source
      }
      
      return .none
      
    case .hadFailure(let failure):
      state.failure = failure
      
      return .none
    }
  }
  
  // MARK: SearchBreedsDomain Action Handlers
  private func handleSearchBreedsDomainAction(
    _ state: inout State,
    action: SearchBreedsDomain.Action
  ) -> Effect<Action> {
    switch action {
    case .searchBreed:
      state.failure = nil
      
      return .none
      
    case .handleBreedsSearchResponse:
      return .none
      
    case .updateBreeds(let breeds):
      state.breeds = breeds
      
      return .merge(
        fetchImagesForBreeds(breeds),
        .send(.localStorageDomain(.storeBreedsLocally(breeds)))
      )
      
    case .hadFailure(let failure):
      state.failure = failure
      
      return .none
    }
  }
  
  // MARK: LocalStorageDomain Action Handlers
  private func handleLocalStorageDomainAction(
    _ state: inout State,
    action: LocalStorageDomain.Action
  ) -> Effect<Action> {
    switch action {
    case .storeBreedsLocally:
      return .none
      
    case .handleStoreResult:
      return .none
      
    case .hadFailure(let failure):
      state.failure = failure
      
      return .none
    }
  }
  
}

// MARK: Helpers
extension BreedSearchFeature {
  
  private func isLastBreed(_ state: State, id: String) -> Bool {
    return state.breeds.last?.id == id || state.breeds.isEmpty
  }
  
  private func fetchImagesForBreeds(
    _ breeds: [CatBreed]
  ) -> Effect<Action> {
    let fetchImageEffects: [Effect<Action>] = breeds.map {
      if let referenceImageId = $0.referenceImageId {
        return .send(
          .fetchImageDomain(
            .fetchImage($0.id, referenceImageId)
          )
        )
      }
      
      // TODO: Add fallback image
      return .send(
        .fetchImageDomain(
          .handleImage($0.id, .success(.assets(.breed)))
        )
      )
    }
    
    return .merge(fetchImageEffects)
  }
  
}
