//
//  ColorScheme+Extensions.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import SwiftUI

extension ColorScheme {

  var backgroundColor: Color {
    switch self {
    case .light:
      return .white

    case .dark:
      return .black

    @unknown default:
      return .white
    }
  }

  var foregroundColor: Color {
    switch self {
    case .light:
      return .black

    case .dark:
      return .white

    @unknown default:
      return .black
    }
  }

}
