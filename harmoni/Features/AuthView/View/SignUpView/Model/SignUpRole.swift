//
//  SignUpRole.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/10/24.
//

import SwiftUI

enum SignUpRole: String, CaseIterable {
    case listener = "Listener", artist = "Artist"
    
    var description: String {
        switch self {
        case .listener:
            "Listeners stream music."
        case .artist:
            "Artists upload, tag, and stream music."
        }
    }
    
    var image: Image {
        switch self {
        case .listener:
            Image(systemName: "waveform.and.person.filled")
                .resizable()
        case .artist:
            Image(systemName: "music.mic")
                .resizable()
        }
    }
}
