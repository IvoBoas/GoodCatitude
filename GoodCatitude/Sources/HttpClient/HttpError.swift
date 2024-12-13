//
//  HttpError.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation
import Alamofire

enum HttpError: Error, Equatable {
  case networkUnavailable
  case invalidResponse
  case unknown

  static func from(_ error: AFError) -> HttpError {
    if let underlyingError = error.underlyingError as? URLError {
      switch underlyingError.code {
      case .notConnectedToInternet, .networkConnectionLost, .timedOut:
        return .networkUnavailable
      default:
        return .unknown
      }
    }

    if error.isResponseSerializationError {
      return .invalidResponse
    }

    return .unknown
  }
}
