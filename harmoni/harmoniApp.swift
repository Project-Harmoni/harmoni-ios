//
//  harmoniApp.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import SwiftUI

@main
struct harmoniApp: App {
    var body: some Scene {
        WindowGroup {
            AppContainerView()
                .environmentObject(NowPlayingManager())
        }
    }
}
