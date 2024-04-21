//
//  SignUpView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/10/24.
//

import AuthenticationServices
import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = SignUpViewModel()
    /// Toggle alert for email verification
    @State private var isShowingVerifyAlert: Bool = false
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            signUpView
                .alert(
                    isPresented: $viewModel.isError,
                    error: viewModel.errorMessage
                ) {
                    Button("OK", action: {})
                }
                .navigationDestination(for: SignUpPath.self) { currentPath in
                    Group {
                        switch currentPath {
                        case .start: signUpView
                        case .birthday: selectBirthdayView
                        case .role: chooseRoleView
                        }
                    }
                }
        }
        .alert("Almost there!", isPresented: $isShowingVerifyAlert) {
            Button("OK", role: .cancel, action: { dismiss() })
        } message: {
            Text("We've sent a verification link to your email. Please check your inbox to verify your account. Once you've clicked the link, come back and sign in to continue.")
        }
    }
    
    private func header(_ title: String) -> some View {
        ZStack(alignment: .trailing) {
            HStack {
                Spacer()
                Text(title)
                    .fontWeight(.bold)
                Spacer()
            }
            dismissButton
        }
        .foregroundStyle(.white)
    }
    
    private var continueButton: some View {
        NavigationLink(value: SignUpPath.start) {
            Button {
                if viewModel.isSafeToContinue {
                    viewModel.path.append(.birthday)
                }
            } label: {
                Text("Continue")
                    .fontWeight(.bold)
                    .padding(.vertical, 6)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var continueBirthdayButton: some View {
        NavigationLink(value: SignUpPath.birthday) {
            Button {
                viewModel.path.append(.role)
            } label: {
                Text("Continue")
                    .fontWeight(.bold)
                    .padding(.vertical, 6)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
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
            continueButton
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
    
    private var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "x.circle.fill")
        }
        .foregroundStyle(.white)
    }
}

// MARK: - Paths

private extension SignUpView {
    var signUpView: some View {
        VStack(spacing: 32) {
            emailPasswordEntry
            divider
            SignInWithAppleView(label: .continue)
        }
        .padding()
        .navigationTitle("Create an Account")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                dismissButton
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var selectBirthdayView: some View {
        SelectBirthdayView(
            birthday: $viewModel.birthday,
            path: $viewModel.path
        )
    }
    
    var chooseRoleView: some View {
        ChooseRoleView(
            viewModel: ChooseRoleViewModel(
                birthday: $viewModel.birthday,
                onSignUp: {
                    viewModel.signUp(with: $0) {
                        isShowingVerifyAlert.toggle()
                    }
                },
                onCompletion: {
                    dismiss()
                }
            )
        )
    }
}

#Preview {
    SignUpView()
}
