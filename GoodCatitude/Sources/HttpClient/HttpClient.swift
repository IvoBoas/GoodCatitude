//
//  HttpClient.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 12/12/2024.
//

import Foundation
import Alamofire

final class HttpClient {

  static let apiKey = ProcessInfo.processInfo.environment["API_KEY"]

  static func request<T: Decodable>(
    endpoint: ApiEndpoint,
    method: HTTPMethod,
    headers: [String: String]
  ) async -> HttpRequestResult<T> {
    var encoding: ParameterEncoding

    switch method {
    case .post:
      encoding = JSONEncoding.default
    case .get:
      encoding = URLEncoding.default
    default:
      encoding = JSONEncoding.default
    }

    var newHeaders = headers

    if let apiKey {
      newHeaders["x-api-key"] = apiKey
    }

    return await withCheckedContinuation { continuation in
      AF.request(
        endpoint.url,
        method: method,
        parameters: endpoint.params,
        encoding: encoding,
        headers: HTTPHeaders(newHeaders)
      ).responseDecodable(of: T.self) { response in
        switch response.result {
        case let .success(data):
          continuation.resume(returning: .success(data))

        case let .failure(error):
          print("[HttpClient] Failed to complete request: \(error)")

          continuation.resume(returning: .error(.from(error)))
        }
      }
    }
  }

  static func getRequest<T: Decodable>(
    endpoint: ApiEndpoint,
    headers: [String: String] = [:]
  ) async -> HttpRequestResult<T> {
    return await request(
      endpoint: endpoint,
      method: .get,
      headers: headers
    )
  }

}
