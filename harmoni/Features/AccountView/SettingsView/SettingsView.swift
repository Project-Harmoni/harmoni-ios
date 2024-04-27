//
//  SettingsView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/23/24.
//

import AlertToast
import MessageUI
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.isAdmin) private var isAdmin
    @Environment(\.container) private var container
    @Environment(\.currentUser) private var currentUser
    @StateObject var viewModel: SettingsViewModel
    
    var body: some View {
        List {
            Section {
                if isAdmin {
                    HStack {
                        Text("Role:")
                        Spacer()
                        Text("Admin").bold()
                    }
                } else if viewModel.isAdminRequested {
                    HStack {
                        Text("Admin Request Status:")
                        Spacer()
                        Text("Sent").bold()
                    }
                } else if !isAdmin {
                    Button {
                        if MFMailComposeViewController.canSendMail() {
                            viewModel.isDisplayingAdminRequest.toggle()
                        }
                    } label: {
                        Text("Request to be Admin")
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    viewModel.isDisplayingDeleteAccountAlert.toggle()
                } label: {
                    Text("Delete Account")
                }
            }
        }
        .sheet(isPresented: $viewModel.isDisplayingAdminRequest) {
            if let email = currentUser?.email {
                SendMailView.adminRequest(for: email) {
                    viewModel.isAdminRequested = true
                    viewModel.isDisplayingRequestSent.toggle()
                }
            }
        }
        .toast(
            isPresenting: $viewModel.isDisplayingRequestSent,
            duration: 2,
            tapToDismiss: true,
            alert: {
                AlertToast(type: .complete(.green), title: "Request Sent")
            }
        )
        .alert(
            "Delete Account",
            isPresented: $viewModel.isDisplayingDeleteAccountAlert,
            actions: {
                Button("Delete", role: .destructive, action: { deleteAccount() })
                Button("Cancel", role: .cancel, action: {})
            },
            message: {
                Text("Are you sure you want to delete your account? This will be irreversible.")
            }
        )
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteAccount() {
        Task.detached { @MainActor in
            do {
                dismiss()
                container.isPresentingLoadingToast(title: "Deleting Account")
                try await viewModel.deleteAccount()
                await viewModel.logoutAction?()
                container.isPresentingLoadingToast.toggle()
                container.isPresentingAlert(title: "Account Deleted", message: "Thank you for listening with us!")
            } catch {
                dump(error)
                container.isPresentingLoadingToast.toggle()
                container.isPresentingAlert(title: "Unable to Delete Account", message: "Please try again.")
            }
        }
    }
}
