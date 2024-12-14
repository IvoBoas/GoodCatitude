//
//  CrudError.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 14/12/2024.
//

import Foundation

enum CrudError: Error, Equatable {

  case saveChangesFailed
  case entityCreationFailed

}
