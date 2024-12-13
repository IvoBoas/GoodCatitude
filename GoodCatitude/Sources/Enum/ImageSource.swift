//
//  ImageSource.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation
import SwiftUI

enum ImageSource: Equatable {

  case loading
  case assets(ImageResource)
  case data(Data)
  case remote(String)

}
