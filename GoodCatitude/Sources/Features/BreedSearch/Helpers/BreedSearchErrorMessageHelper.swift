//
//  BreedSearchErrorMessageHelper.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 14/12/2024.
//

import Foundation

struct BreedSearchErrorMessageHelper {

  static func makeErrorMessage(for error: BreedSearchFeature.BreedSearchError) -> String? {
    switch error {
    case .fetchBreedsFailed(let error):
      return makeErrorMessage(for: error)

    case .fetchImageFailed:
      return "Failed to fetch breed image. Please try again later"
    }
  }

}

extension BreedSearchErrorMessageHelper {

  private static func makeErrorMessage(for error: HttpError) -> String {
    switch error {
    case .networkUnavailable:
      return "No internet connection. Please try again later."

    case .invalidResponse:
      return "Received invalid data from the server."

    case .unknown:
      return "Failed to fetch cat breeds. Please try again later."
    }

  }

}
