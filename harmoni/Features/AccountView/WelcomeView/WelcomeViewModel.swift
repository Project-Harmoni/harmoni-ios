//
//  WelcomeViewModel.swift
//  harmoni
//
//  Created by Sarah Matthews on 4/11/24.
//

import Foundation
import Supabase

class WelcomeViewModel: ObservableObject {
    @Published var currentUser: User?
    private let database: DBServiceProviding = DBService()
    private let storage: StorageProviding = StorageService()
    
    init() {
        
    }
    
    func toggleIsNewOff() {
        // TODO: add functionality to toggle flag in db
        // TODO: add functionality to dismiss?
    }
    
}
