//
//  ChooseRoleView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/13/24.
//

import SwiftUI

struct ChooseRoleView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ChooseRoleViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $viewModel.role) {
                ForEach(SignUpRole.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            Spacer()
            VStack(spacing: 16) {
                viewModel.role.image.aspectRatio(contentMode: .fit)
                Text(viewModel.role.description)
            }
            .padding(.vertical, 44)
            Spacer()
            ctaButton
        }
        .padding()
        .navigationTitle("Choose Account Type")
        .navigationBarTitleDisplayMode(.inline)
        .presentationBackground(.thinMaterial)
        .interactiveDismissDisabled(!isDismissable)
        .toolbar {
            if isDismissable {
                ToolbarItem {
                    dismissButton
                }
            }
        }
    }
    
    private var ctaButton: some View {
        Button {
            isSignUp
            ? viewModel.signUp()
            : viewModel.completeRegistration()
        } label: {
            completeButtonLabel
                .fontWeight(.bold)
                .padding(.vertical, 6)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.isCompleting)
        .opacity(viewModel.isCompleting ? 0.5 : 1)
    }
    
    @ViewBuilder
    private var completeButtonLabel: some View {
        if viewModel.isCompleting {
            HStack(spacing: 8) {
                ProgressView().tint(.white)
                Text("Completing...")
            }
        } else {
            Text("Complete")
        }
    }
    
    private var dismissButton: some View {
        Button {
            viewModel.onDismissTapped?() ?? dismiss()
        } label: {
            Image(systemName: "x.circle.fill")
        }
        .foregroundStyle(.white)
    }
    
    private var isDismissable: Bool {
        viewModel.onDismissTapped != nil
    }
    
    private var isSignUp: Bool {
        viewModel.onSignUp != nil
    }
}
