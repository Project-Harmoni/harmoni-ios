//
//  ContainerEnvironmentKey.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/15/24.
//

import SwiftUI

private struct ContainerEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppContainerViewModel()
}

extension EnvironmentValues {
    var container: AppContainerViewModel {
        get { self[ContainerEnvironmentKey.self] }
        set { self[ContainerEnvironmentKey.self] = newValue }
    }
}
