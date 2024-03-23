//
//  Date+Extension.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/13/24.
//

import Foundation

extension Date {
    var yyyyMMdd: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
