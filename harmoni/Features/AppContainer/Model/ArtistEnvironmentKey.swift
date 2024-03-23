//
//  ArtistEnvironmentKey.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import SwiftUI

private struct ArtistEnvironmentKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
    var isArtist: Bool {
        get { self[ArtistEnvironmentKey.self] }
        set { self[ArtistEnvironmentKey.self] = newValue }
    }
}
