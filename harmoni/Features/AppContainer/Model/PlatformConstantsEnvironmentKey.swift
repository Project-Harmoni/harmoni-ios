//
//  PlatformConstantsEnvironmentKey.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/15/24.
//

import SwiftUI

private struct PlatformConstantsEnvironmentKey: EnvironmentKey {
    static let defaultValue = PlatformConstants()
}

extension EnvironmentValues {
    var platformConstants: PlatformConstants {
        get { self[PlatformConstantsEnvironmentKey.self] }
        set { self[PlatformConstantsEnvironmentKey.self] = newValue }
    }
}
