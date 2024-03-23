//
//  Binding+Extension.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/22/24.
//

import SwiftUI

// https://www.hackingwithswift.com/forums/swiftui/limit-characters-in-a-textfield/15017
extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }
        return self
    }
}
