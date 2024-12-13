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
    url: String,
    method: HTTPMethod,
    headers: [String: String],
    params: Parameters?
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
        url,
        method: method,
        parameters: params,
        encoding: encoding,
        headers: HTTPHeaders(newHeaders)
      ).responseDecodable(of: T.self) { response in
        switch response.result {
        case let .success(data):
          continuation.resume(returning: .success(data))

        case let .failure(error):
          print(error)

          continuation.resume(returning: .error(.from(error)))
        }
      }
    }
  }

  static func dataRequest(from url: String) async -> HttpRequestResult<Data> {
    return await withCheckedContinuation { continuation in
      AF.request(url)
        .validate()
        .responseData { response in
          switch response.result {
          case .success(let data):
            continuation.resume(returning: .success(data))
          case .failure(let error):
            print(error)

            continuation.resume(returning: .error(.from(error)))
          }
        }
    }
  }

  static func getRequest<T: Decodable>(
    url: String,
    headers: [String: String] = [:],
    params: Parameters? = nil
  ) async -> HttpRequestResult<T> {
    return await request(
      url: url,
      method: .get,
      headers: headers,
      params: params
    )
  }

}
