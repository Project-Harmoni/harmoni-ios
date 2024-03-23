//
//  EnvManager.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import Foundation

/// Get environment variables from configuration
enum EnvManager: String {
    case supabaseKey = "SUPABASE_KEY"
    case supabaseURL = "SUPABASE_URL"
    
    var value: String? {
        Bundle.main.infoDictionary?[self.rawValue] as? String
    }
}
