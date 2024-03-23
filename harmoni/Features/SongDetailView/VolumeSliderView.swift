//
//  VolumeSliderView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//  Referenced: https://medium.com/@manikantasirumalla5/how-to-implement-native-volume-controls-and-airplay-button-in-swiftui-eaa04000b76f
//

import MediaPlayer
import SwiftUI

struct VolumeSliderView: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        MPVolumeView()
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {}
}
