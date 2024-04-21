//
//  SignUpViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/10/24.
//

import Foundation
import Supabase

class SignUpViewModel: ObservableObject {
    @Published var path: [SignUpPath] = []
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var birthday: Date = .now
    @Published var role: SignUpRole = .listener
    @Published var errorMessage: AuthFlowError?
    @Published var isError: Bool = false
    @Published var isSigningUp: Bool = false
    private let database: DBServiceProviding = DBService()
    
    func signUp(with role: SignUpRole, on completion: @escaping (() -> Void)) {
        self.role = role
        if email.isValidEmail {
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    self.isSigningUp = true
                    let authResponse = try await Supabase.shared.client.auth.signUp(
                        email: self.email,
                        password: self.password
                    )
                    try await self.updateDatabase(with: authResponse)
                    errorMessage = nil
                    self.isSigningUp = false
                    completion()
                } catch {
                    dump(error)
                    errorMessage = AuthFlowError.custom(error: error.localizedDescription)
                    self.isSigningUp = false
                    self.isError = true
                }
            }
        } else {
            errorMessage = AuthFlowError.custom(error: "Email is invalid")
            isError = true
        }
    }
    
    var isSafeToContinue: Bool {
        if !email.isValidEmail {
            errorMessage = AuthFlowError.custom(error: "Email is invalid")
            isError = true
            return false
        } else if password.count < 8 {
            errorMessage = AuthFlowError.custom(error: "Passoword must be at least 8 characters")
            isError = true
            return false
        } else {
            return true
        }
    }
}

// MARK: - Helpers

private extension SignUpViewModel {
    func getUser(from response: AuthResponse) -> UserDB {
        var user = response.toUserDB()
        user.birthday = birthday.yyyyMMdd
        user.type = role.rawValue
        return user
    }
    
    func updateDatabase(with response: AuthResponse) async throws {
        let userDB = getUser(from: response)
        try await database.upsert(user: userDB)
        
        switch role {
        case .listener:
            let listener = ListenerDB(from: userDB)
            try await database.upsert(listener: listener)
        case .artist:
            let artist = ArtistDB(from: userDB)
            try await database.upsert(artist: artist)
        }
    }
}
