//
//  BreedSearchFailureMessageHelper.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 14/12/2024.
//

import Foundation

struct BreedSearchFailureMessageHelper {

  static func makeFailure(for error: BreedSearchFeature.BreedSearchError) -> FailureType {
    switch error {
    case .fetchBreedsFailed(let error):
      return .error(message: makeErrorMessage(for: error))

    case .fetchImageFailed:
      return .warning(message: "Failed to fetch image. Please try again later")

    case .storeBreedsFailed(let error):
      return .warning(message: makeErrorMessage(for: error))
    }
  }

}

extension BreedSearchFailureMessageHelper {

  private static func makeErrorMessage(for error: HttpError) -> String {
    switch error {
    case .networkUnavailable:
      return "No internet connection. Results shown may be outdated."

    case .invalidResponse:
      return "Received invalid data from the server. Results shown may be outdated."

    case .unknown:
      return "Failed to fetch cat breeds. Results shown may be outdated."
    }
  }

  private static func makeErrorMessage(for error: CrudError) -> String {
    return "Error saving data on device"
  }

}
