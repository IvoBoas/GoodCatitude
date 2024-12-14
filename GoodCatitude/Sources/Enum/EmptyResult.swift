//
//  EmptyResult.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 14/12/2024.
//

import Foundation

enum EmptyResult<T: Error & Equatable>: Equatable {
  case success
  case error(T)
}
