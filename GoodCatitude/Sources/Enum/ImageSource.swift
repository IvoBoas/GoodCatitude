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
  case local(_ imageId: String, Data)
  case remote(_ imageId: String, _ url: String)

}
