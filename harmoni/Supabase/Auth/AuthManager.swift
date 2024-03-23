//
//  AuthManager.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import Foundation
import Supabase

/// Provide singleton for auth-related services
class AuthManager: ObservableObject {
    static var shared = AuthManager()
    @Published var isSignedIn: Bool = false
    /// Registered users must supply birthday and role
    @Published var isRegistrationComplete: Bool?
    private let database: DBServiceProviding = DBService()
    
    private init() {
        Task {
            isSignedIn = await currentUser != nil
            await observeSignIn()
        }
    }
    
    var currentUser: User? {
        get async {
            do {
                return try await Supabase.shared.client.auth.session.user
            } catch {
                dump(AuthError.unableToGetSession(error: error))
                return nil
            }
        }
    }
    
    func logout() async {
        do {
            try await Supabase.shared.client.auth.signOut()
            isSignedIn = false
        } catch {
            dump(AuthError.unableToLogout(error: error))
        }
    }
    
    /// Check if registered user has birthday and role chosen
    func checkRegistration() async {
        do {
            guard let currentUser = await currentUser else { return }
            let isRegistrationFinished = try await database.checkRegistrationFinished(
                for: currentUser.id
            )
            isRegistrationComplete = isRegistrationFinished
        } catch {
            dump(error)
        }
    }
    
    private func observeSignIn() async {
        for await (_, _) in await Supabase.shared.client.auth.authStateChanges.filter({ $0.event == .initialSession || $0.event == .signedIn }) {
            isSignedIn = true
            /// Check if registration completed after sign in
            await checkRegistration()
        }
    }
}
