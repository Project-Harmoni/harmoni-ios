//
//  CurrentUserEnvironmentKey.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/23/24.
//

import SwiftUI
import Supabase

private struct CurrentUserEnvironmentKey: EnvironmentKey {
    static let defaultValue: User? = nil
}

extension EnvironmentValues {
    var currentUser: User? {
        get { self[CurrentUserEnvironmentKey.self] }
        set { self[CurrentUserEnvironmentKey.self] = newValue }
    }
}
