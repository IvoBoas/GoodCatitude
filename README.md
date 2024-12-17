# GoodCatitude

A simple *SwiftUI* application that allows users to search for cat breeds, view their details, and mark their favourite breeds.


## Table of Contents
- [Architecture](#architecture)
- [Screens](#screens)
- [Breed Search Feature](#breed-search-feature)
  - [Pagination](#pagination)
  - [Fetching breeds and avatars](#fetching-breeds-and-avatars)
  - [Searching breeds](#searching-breeds)
- [Breed Details Feature](#breed-details-feature)
- [Favourite Breeds Feature](#favourite-breeds-feature)


## Architecture
- This application was built using *The Composable Architecture*.
- It has one root feature called *AppFeature* responsible mainly for screen navigation.
- This feature has three child features, one for each feature: [*BreedSearch*](#breed-search-feature), [*BreedDetails*](#breed-details-feature), [*FavouriteBreeds*](#favourite-breeds-feature).
- Logic is split into specialized scopes to improve code maintainability and modularity.
  - e.g: *BreedSearchFeature* uses scopes responsible for fetching breeds, searching breeds, fetching images, and storing data locally.

## Screens
- This application has three screens:
  - Two screens are displayed in a tab view. These are the [Breed Search screen](#breed-search-feature) and [Favourite Breeds screen](#favourite-breeds-feature)
  - The application also has a [Breed Details screen](#breed-details-feature) shown whenever the user interacts with a breed entry on either of the previously mentioned screens.

## Breed Search Feature
- This feature is responsible for listing and searching cat breeds.
- Breeds are first displayed as a grid sorted by name. This grid is built using *LazyVGrid* for lazy view initialization.

<p align="center">
  <img src="readme_resources/breeds_screen.PNG?raw=true" width="300" />
  <img src="readme_resources/search.PNG?raw=true" width="300" />
</p>

### Pagination
- Breeds are shown to the user using pagination.
- When one item from the grid is rendered on the screen, if it's the last item, it triggers the fetching of a new page.

### Fetching breeds and avatars
- Breeds and their avatars are stored locally after being fetched.
- Breeds' info is stored on a *CoreData* database.
- Breeds' avatars are stored as files in the application documents directory.
- If the avatar file exists locally, it will be loaded directly from storage. If not, it's data will be fetched and stored on a file for later use.
- If for some reason the app is unable to fetch breeds from the API, previously saved breeds are fetched from the database.
- After breeds are fetched, they will appear on the grid with a progress indicator while the avatar is loaded.
  - If for some reason it's not possible to load an avatar for a breed, a default avatar will be used instead.

### Searching breeds
- The user is able to input a search query to find breeds by name.
- When the query value is changed:
  - If the search query is empty, the app will fetch a new breeds page after resetting the pagination values.
  - If the searhc query is not empty, the app will request all breeds that match the search query from the API.
- If for some reason the app is unable to search breeds using the API, it will try to find previously stored breeds on the database whose name match the search query.
- To reduce unnecessary requests, query changes are handled with a debounce value of 150ms.


## Breed Details Feature
- When the user interacts with any breed, a details screen will be opened.
- This screen contains the breed's:
  - Avatar
  - Name
  - Origin
  - Lifespan
  - Temperament
  - Description
- In this screen the user is also able to mark the breed as favourite.

<p align="center">
<img src="readme_resources/details_screen.PNG?raw=true" width="300">
</p>


## Favourite Breeds Feature
- Breeds marked as favourites are shown to the user on a grid on the Favourite Breeds screen.
- These breeds are stored locally with a flag `isFavourite` set to `true`.
- Whenever the user toggles a breed favourite status in the [Breed Details screen](#breed-details-feature) the *AppFeature* will trigger a reload on this feature. This reload will fetch all favourite breeds from the local database.

<p align="center">
<img src="readme_resources/favourite_breeds.PNG?raw=true" width="300">
</p>