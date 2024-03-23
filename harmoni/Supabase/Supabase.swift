//
//  Supabase.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import Foundation
import Supabase

/// Provide singleton for easy supabase client access
struct Supabase {
    static var shared = Supabase()
    private(set) var client: SupabaseClient
    
    private init() {
        // force unwrapping here since app should crash if url and key are unavailable
        let url = EnvManager.supabaseURL.value!
        let key = EnvManager.supabaseKey.value!
        client = SupabaseClient(
            supabaseURL: URL(string: url)!,
            supabaseKey: key
        )
    }
}
