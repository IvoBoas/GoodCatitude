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
  case error(AFError)
}

extension HttpRequestResult {

  func mapResult<NewT>(
    _ mapFunction: (T) -> NewT
  ) -> Result<NewT, AFError> {
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
    _ mapFunction: (AFError) -> NewError
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
