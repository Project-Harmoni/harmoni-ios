//
//  AdminEnvironmentKey.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import SwiftUI

private struct AdminEnvironmentKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
    var isAdmin: Bool {
        get { self[AdminEnvironmentKey.self] }
        set { self[AdminEnvironmentKey.self] = newValue }
    }
}
