//
//  CompleteRegistrationViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/13/24.
//

import Foundation

class CompleteRegistrationViewModel: ObservableObject {
    @Published var path: [SignUpPath] = []
    @Published var birthday: Date = .now
}
