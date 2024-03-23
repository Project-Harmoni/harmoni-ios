//
//  SignInViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/10/24.
//

import Foundation

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: AuthFlowError?
    @Published var isError: Bool = false
    @Published var isSigningIn: Bool = false
    
    func signIn() {
        if email.isValidEmail {
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    self.isSigningIn = true
                    try await Supabase.shared.client.auth.signIn(
                        email: self.email,
                        password: self.password
                    )
                    errorMessage = nil
                    self.isSigningIn = false
                } catch {
                    dump(error)
                    errorMessage = AuthFlowError.custom(error: error.localizedDescription)
                    self.isSigningIn = false
                    self.isError = true
                }
            }
        } else {
            errorMessage = AuthFlowError.custom(error: "Email is invalid")
            isError = true
        }
    }
}
