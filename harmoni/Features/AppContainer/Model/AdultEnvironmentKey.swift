//
//  AdultEnvironmentKey.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/11/24.
//

import SwiftUI

private struct AdultEnvironmentKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
    var isAdult: Bool {
        get { self[AdultEnvironmentKey.self] }
        set { self[AdultEnvironmentKey.self] = newValue }
    }
}
