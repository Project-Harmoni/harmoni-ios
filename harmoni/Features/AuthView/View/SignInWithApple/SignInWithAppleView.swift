//
//  SignInWithAppleView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/10/24.
//

import AuthenticationServices
import SwiftUI

struct SignInWithAppleView: View {
    @Environment(\.colorScheme) var colorScheme
    var label: SignInWithAppleButton.Label
    
    var body: some View {
        signInWithAppleDynamic
    }
    
    @ViewBuilder
    private var signInWithAppleDynamic: some View {
        if colorScheme == .light {
            signInWithAppleButton
                .signInWithAppleButtonStyle(.black)
        } else {
            signInWithAppleButton
                .signInWithAppleButtonStyle(.white)
        }
    }
    
    private var signInWithAppleButton: some View {
        SignInWithAppleButton(label) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            Task { @MainActor in
                do {
                    try await signIn(with: result)
                } catch {
                    dump(error)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20), style: .init())
        .frame(height: 40)
    }
    
    private func signIn(with result: Result<ASAuthorization, any Error>) async throws {
        guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential
        else {
            return
        }
        
        guard let idToken = credential.identityToken
            .flatMap({ String(data: $0, encoding: .utf8) })
        else {
            return
        }
        
        try await Supabase.shared.client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken
            )
        )
    }
}

#Preview {
    SignInWithAppleView(label: .signIn)
}
