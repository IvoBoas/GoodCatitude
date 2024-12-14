//
//  ApiEndpoint.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 14/12/2024.
//

import Foundation
import Alamofire

enum ApiEndpoint {
  private static let baseURL = "https://api.thecatapi.com/v1"

  case breeds(page: Int, limit: Int)
  case searchBreeds(query: String)
  case image(id: String)

  var url: String {
    switch self {
    case .breeds:
      return "\(ApiEndpoint.baseURL)/breeds"

    case .searchBreeds:
      return "\(ApiEndpoint.baseURL)/breeds/search"

    case .image(let id):
      return "\(ApiEndpoint.baseURL)/images/\(id)"
    }
  }

  var params: Parameters? {
    switch self {
    case .breeds(let page, let limit):
      return [
        "page": page,
        "limit": limit
      ]

    case .searchBreeds(let query):
      return [
        "q": query,
        "attach_image": 1
      ]

    case .image:
      return nil
    }
  }

}
