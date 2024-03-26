//
//  Int+Extension.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/25/24.
//

import Foundation

extension Int {
    var toString: String {
        get {
            "\(self)"
        }
        set {
            self = Int(newValue) ?? 0
        }
    }
}
