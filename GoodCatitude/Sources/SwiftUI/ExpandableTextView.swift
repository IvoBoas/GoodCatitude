//
//  ExpandableTextView.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import SwiftUI

struct ExpandableTextView: View {

  @State var text: String
  @State private var shouldShowExpandButton = false
  @State private var textWidth = CGFloat.zero
  @State private var iconRotation = Double.zero

  let lineLimit: Int
  let font: Font
  let foregroundColor: Color
  let backgroundColor: Color

  @Binding var isExpanded: Bool

  var body: some View {
    ZStack(alignment: .bottom) {
      ScrollView {
        Text(text)
          .font(font)
          .foregroundStyle(foregroundColor)
          .opacity(text.isEmpty ? 0 : 1)
          .background(
            GeometryReader { geometry in
              Color.clear.onAppear {
                let width = geometry.size.width

                let textSize = textSizeWithoutLimit(availableWidth: width)
                let limitedTextSize = textSizeWithLimit(availableWidth: width)

                shouldShowExpandButton = textSize.height > limitedTextSize.height
                textWidth = width
              }
            }
          )
      }
      .disabled(true)
      .frame(height: viewHeight())

      ZStack(alignment: .bottom) {
        LinearGradient(
          gradient: Gradient(
            colors: [.clear, backgroundColor]
          ),
          startPoint: .top,
          endPoint: .bottom
        )
        .opacity(!isExpanded && shouldShowExpandButton ? 1 : 0)

        Image(systemName: "chevron.down")
          .foregroundColor(foregroundColor)
          .rotationEffect(.degrees(iconRotation))
          .opacity(shouldShowExpandButton ? 1 : 0)
      }
    }
    .frame(height: viewHeight())
    .contentShape(Rectangle())
    .onTapGesture {
      if shouldShowExpandButton {
        withAnimation {
          isExpanded.toggle()

          iconRotation += 180
        }
      }
    }
  }

  private func viewHeight() -> CGFloat {
    if isExpanded {
      return textSizeWithoutLimit(
        availableWidth: textWidth
      ).height + 32
    }

    return textSizeWithLimit(
      availableWidth: textWidth
    ).height
  }

  private func textSizeWithoutLimit(
    availableWidth: CGFloat
  ) -> CGSize {
    let textSize = text.boundingRect(
      with: CGSize(
        width: availableWidth,
        height: .infinity
      ),
      options: .usesLineFragmentOrigin,
      attributes: [.font: font.uiFont],
      context: nil
    ).size

    return textSize
  }

  private func textSizeWithLimit(
    availableWidth: CGFloat
  ) -> CGSize {
    let textSize = text.boundingRect(
      with: CGSize(
        width: availableWidth,
        height: CGFloat(lineLimit + 1) * font.uiFont.lineHeight
      ),
      options: .usesLineFragmentOrigin,
      attributes: [.font: font.uiFont],
      context: nil
    ).size

    return textSize
  }

}

extension Font {

  var uiFont: UIFont {
    let style: UIFont.TextStyle

    switch self {
    case .largeTitle:
      style = .largeTitle

    case .title:
      style = .title1

    case .title2:
      style = .title2

    case .title3:
      style = .title3

    case .headline:
      style = .headline

    case .subheadline:
      style = .subheadline

    case .callout:
      style = .callout

    case .caption:
      style = .caption1

    case .caption2:
      style = .caption2

    case .footnote:
      style = .footnote

    case .body:
      fallthrough

    default:
      style = .body
    }
    return  UIFont.preferredFont(forTextStyle: style)
  }

}

struct ExpandableTextView_Preview: View {

  @State private var isExpanded = false

  var body: some View {
    ExpandableTextView(
      text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam vitae dictum sem. Morbi augue mauris, ultricies euismod pretium eu, ultricies non dolor. Curabitur ut lacus eleifend augue consequat vulputate et sed lectus. Curabitur vehicula dignissim iaculis. Sed in convallis augue, eu suscipit lorem. Duis mollis malesuada nulla, id facilisis tellus placerat at. Morbi commodo lacinia bibendum. Nunc eget sagittis augue. Fusce porta eleifend leo, vel convallis velit ornare at. Fusce placerat, ante quis cursus iaculis, mi massa feugiat velit, ac pellentesque mi ex dignissim odio.",
      lineLimit: 3,
      font: .footnote,
      foregroundColor: .black,
      backgroundColor: .white,
      isExpanded: $isExpanded
    )
  }

}

#Preview {
  ExpandableTextView_Preview()
}
