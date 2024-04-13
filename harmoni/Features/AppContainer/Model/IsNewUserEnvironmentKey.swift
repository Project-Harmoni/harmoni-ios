//
//  IsNewUserEnvironmentKey.swift
//  harmoni
//
//  Created by Sarah Matthews on 4/13/24.
//

import SwiftUI

private struct IsNewUserEnvironmentKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
    var isNew: Bool {
        get { self[IsNewUserEnvironmentKey.self] }
        set { self[IsNewUserEnvironmentKey.self] = newValue }
    }
}
