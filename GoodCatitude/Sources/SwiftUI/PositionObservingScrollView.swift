//
//  PositionObservingScrollView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import SwiftUI

struct PositionObservingScrollView<Content: View>: View {

  @Binding var offset: CGPoint
  @ViewBuilder var content: () -> Content

  private let coordinateSpaceName = UUID()

  var body: some View {
    ScrollView {
      PositionObservingView(
        coordinateSpace: .named(coordinateSpaceName),
        position: $offset
      ) {
        content()
      }
    }
    .coordinateSpace(name: coordinateSpaceName)
  }

}

struct PositionObservingView<Content: View>: View {

  struct PreferenceKey: SwiftUI.PreferenceKey {
    static var defaultValue: CGPoint { .zero }

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
  }

  var coordinateSpace: CoordinateSpace
  @Binding var position: CGPoint
  @ViewBuilder var content: () -> Content

  var body: some View {
    content()
      .background(
        GeometryReader { geometry in
          SwiftUI.Color.clear.preference(
            key: PreferenceKey.self,
            value: geometry.frame(in: coordinateSpace).origin
          )
        }
      )
      .onPreferenceChange(PreferenceKey.self) { position in
        self.position = position
      }
  }
  
}

private struct Preview_Content: View {

  @State private var offset = CGPoint.zero

  var body: some View {
    VStack {
      Text("Offset: \(offset.y)")

      PositionObservingScrollView(offset: $offset) {
        Text("Hello World")
      }
    }
  }
}


#Preview {
  Preview_Content()
}
