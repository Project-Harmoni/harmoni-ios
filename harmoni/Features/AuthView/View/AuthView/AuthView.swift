//
//  AuthView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/10/24.
//

import AuthenticationServices
import Combine
import SwiftUI

struct AuthView: View {
    @StateObject var viewModel = AuthViewModel()
    
    private enum AuthType {
        case signIn, signUp, registration
    }
    
    var body: some View {
        VStack {
            Spacer()
            image
            Spacer()
            cta
        }
        .padding()
        .background(.black)
        .sheet(isPresented: $viewModel.showSignUp) {
            authSheet(for: .signUp)
        }
        .sheet(isPresented: $viewModel.showLogIn) {
            authSheet(for: .signIn)
        }
        .sheet(isPresented: $viewModel.isRegistrationIncomplete) {
            authSheet(for: .registration)
        }
        .navigationTitle("Welcome")
        .toolbarBackground(.visible)
        .toolbarBackground(.black)
        .toolbarColorScheme(.dark)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
    
    private var image: some View {
        VStack(spacing: 0) {
            Image(systemName: "waveform")
                .resizable()
                .frame(maxHeight: 200)
                .frame(maxWidth: 200)
                .scaledToFit()
                .foregroundStyle(.linearGradient(colors: [.purple, .blue, .black], startPoint: .top, endPoint: .bottom))
            Group {
                Text("Music streaming\n")
                    .font(.system(.title2, weight: .regular))
                + Text("for ")
                    .font(.system(.title2, weight: .regular))
                + Text("everyone.")
                    .font(.system(.title2, weight: .bold))
                    .italic()
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.top, -16)
        }
    }
    
    private var cta: some View {
        VStack(spacing: 12) {
            signUpButton
            logInButton
        }
    }
    
    private var signUpButton: some View {
        Button {
            viewModel.showSignUp.toggle()
        } label: {
            Text("Sign Up")
                .frame(maxWidth: .infinity)
                .fontWeight(.bold)
                .padding(.vertical, 6)
                .foregroundStyle(.black)
        }
        .buttonStyle(.borderedProminent)
        .tint(.white)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
    
    private var logInButton: some View {
        Button {
            viewModel.showLogIn.toggle()
        } label: {
            Text("Log In")
                .frame(maxWidth: .infinity)
                .fontWeight(.bold)
                .padding(.vertical, 6)
                .foregroundStyle(.white)
        }
        .buttonStyle(.borderedProminent)
        .tint(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
    
    @ViewBuilder
    private func authSheet(for type: AuthType) -> some View {
        Group {
            switch type {
            case .signIn: SignInView()
            case .signUp: SignUpView()
            case .registration: CompleteRegistrationView()
            }
        }
        .presentationDetents([.fraction(0.5)])
        .presentationCornerRadius(24)
        .presentationBackground(.thinMaterial)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AuthView()
}
