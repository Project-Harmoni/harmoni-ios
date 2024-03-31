//
//  GlobalUtilities.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/30/24.
//

import Foundation

// https://stackoverflow.com/a/76951232
func plural(_ count: Int, _ word: String) -> String {
    let localizedValue: String.LocalizationValue = "^[\(count) \(word)](inflect: true)"
    return String(AttributedString(localized: localizedValue).characters)
}
