//
//  SignInView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = SignInViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                emailPasswordEntry
                divider
                SignInWithAppleView(label: .signIn)
            }
            .padding()
            .alert(
                isPresented: $viewModel.isError,
                error: viewModel.errorMessage
            ) {
                Button("OK", action: {})
            }
            .navigationTitle("Sign In")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    dismissButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "x.circle.fill")
        }
        .foregroundStyle(.white)
    }
    
    private var signInButton: some View {
        Button {
            viewModel.signIn()
        } label: {
            signInButtonLabel
                .fontWeight(.bold)
                .padding(.vertical, 6)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.isSigningIn)
        .opacity(viewModel.isSigningIn ? 0.5 : 1)
    }
    
    @ViewBuilder
    private var signInButtonLabel: some View {
        if viewModel.isSigningIn {
            HStack(spacing: 8) {
                ProgressView().tint(.white)
                Text("Signing In...")
            }
        } else {
            Text("Sign In")
        }
    }
    
    var line: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(.gray.opacity(0.4))
    }
    
    var divider: some View {
        HStack {
            line
            Text("or")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal)
                .foregroundStyle(.gray)
            line
        }
    }
    
    var emailPasswordEntry: some View {
        VStack(spacing: 12) {
            emailTextField
            passwordTextField
            signInButton
        }
    }
    
    private var emailTextField: some View {
        TextField("Email", text: $viewModel.email)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
    }
    
    private var passwordTextField: some View {
        SecureField("Password", text: $viewModel.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
    }
}


#Preview {
    SignInView()
}
