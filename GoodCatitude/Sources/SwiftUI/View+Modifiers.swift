//
//  View+Modifiers.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation
import SwiftUI

extension View {

  @inlinable func padding(
    top: CGFloat = 0,
    leading: CGFloat = 0,
    bottom: CGFloat = 0,
    trailing: CGFloat = 0
  ) -> some View {
    return self.padding(
      EdgeInsets(
        top: top,
        leading: leading,
        bottom: bottom,
        trailing: trailing
      )
    )
  }

  @inlinable func padding(
    vertical: CGFloat = 0,
    horizontal: CGFloat = 0
  ) -> some View {
    return self.padding(
      EdgeInsets(
        top: vertical,
        leading: horizontal,
        bottom: vertical,
        trailing: horizontal
      )
    )
  }

}
