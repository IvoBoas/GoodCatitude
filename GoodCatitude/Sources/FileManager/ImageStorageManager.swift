//
//  ImageStorageManager.swift
//  GoodCatitude
//
//  Created by Ivo Vilas Boas  on 15/12/2024.
//

import Foundation
import ComposableArchitecture

// TODO: Error control
struct ImageStorageManager {

  private static let directory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0].appendingPathComponent("Breeds")
  }()

  static func saveImage(
    _ data: Data,
    withName fileName: String
  ) {
    ensureDirectoryExists()

    let fileURL = fileURL(for: fileName)

    try? data.write(to: fileURL, options: [.atomic, .completeFileProtection])
  }

  static func loadImage(
    withName fileName: String
  ) -> Data? {
    let fileURL = fileURL(for: fileName)

    return try? Data(contentsOf: fileURL)
  }

  static func imageExists(
    withName fileName: String
  ) -> Bool {
    let fileURL = fileURL(for: fileName)

    return FileManager.default.fileExists(atPath: fileURL.path)
  }

  static func removeImage(
    withName fileName: String
  ) {
    let fileURL = fileURL(for: fileName)

    try? FileManager.default.removeItem(at: fileURL)
  }

}

extension ImageStorageManager {

  private static func fileURL(for fileName: String) -> URL {
    return directory.appendingPathComponent(fileName)
  }

  private static func ensureDirectoryExists() {
    if !FileManager.default.fileExists(atPath: directory.path) {
      try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
  }

}
