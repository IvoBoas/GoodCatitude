//
//  FailureType.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 14/12/2024.
//

import Foundation

enum FailureType: Equatable {

  case error(message: String)
  case warning(message: String)

  var message: String {
    switch self {
    case .error(let message), .warning(let message):
      return message
    }
  }

}
