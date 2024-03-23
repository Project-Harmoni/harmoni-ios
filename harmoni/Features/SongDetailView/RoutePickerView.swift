//
//  RoutePickerView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//  Referenced: https://medium.com/@manikantasirumalla5/how-to-implement-native-volume-controls-and-airplay-button-in-swiftui-eaa04000b76f
//

import AVKit
import SwiftUI

struct RoutePickerView: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        AVRoutePickerView()
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
