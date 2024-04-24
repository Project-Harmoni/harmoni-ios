//
//  CompleteRegistrationView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/13/24.
//

import SwiftUI

struct CompleteRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CompleteRegistrationViewModel()
    var registrationCompleted: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            birthdayView
                .navigationDestination(for: SignUpPath.self) { currentPath in
                    Group {
                        switch currentPath {
                        case .start, .birthday: birthdayView
                        case .role: chooseRoleView
                        }
                    }
                }
        }
    }
    
    private var birthdayView: some View {
        SelectBirthdayView(
            birthday: $viewModel.birthday,
            path: $viewModel.path
        )
    }
    
    private var chooseRoleView: some View {
        ChooseRoleView(
            viewModel: ChooseRoleViewModel(
                birthday: $viewModel.birthday
            ) {
                registrationCompleted?()
                dismiss()
            } 
        )
    }
}

#Preview {
    CompleteRegistrationView()
}
