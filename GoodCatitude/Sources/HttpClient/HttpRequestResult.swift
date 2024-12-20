//
//  HttpRequestResult.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation
import Alamofire

enum HttpRequestResult<T> {
  case success(T)
  case error(HttpError)
}

extension HttpRequestResult {

  func mapResult<NewT>(
    _ mapFunction: (T) -> NewT
  ) -> Result<NewT, HttpError> {
    switch self {
    case .success(let value):
      return .success(
        mapFunction(value)
      )

    case .error(let error):
      return .failure(error)
    }
  }

  func mapError<NewError>(
    _ mapFunction: (HttpError) -> NewError
  ) -> Result<T, NewError> {
    switch self {
    case .success(let value):
      return .success(value)

    case .error(let error):
      return .failure(
        mapFunction(error)
      )
    }
  }

}
