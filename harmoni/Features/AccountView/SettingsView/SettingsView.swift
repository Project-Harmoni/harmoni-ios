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
    @Environment(\.isAdmin) private var isAdmin
    @Environment(\.currentUser) private var currentUser
    @AppStorage("isAdminRequested") var isAdminRequested: Bool = false
    @State private var isDisplayingAdminRequest: Bool = false
    @State private var isDisplayingRequestSent: Bool = false
    
    var body: some View {
        List {
            Section {
                if isAdmin {
                    HStack {
                        Text("Role:")
                        Spacer()
                        Text("Admin").bold()
                    }
                } else if isAdminRequested {
                    HStack {
                        Text("Admin Request Status:")
                        Spacer()
                        Text("Sent").bold()
                    }
                } else if !isAdmin {
                    Button {
                        if MFMailComposeViewController.canSendMail() {
                            isDisplayingAdminRequest.toggle()
                        }
                    } label: {
                        Text("Request to be Admin")
                    }
                }
            }
        }
        .sheet(isPresented: $isDisplayingAdminRequest) {
            if let email = currentUser?.email {
                SendMailView.adminRequest(for: email) {
                    isAdminRequested = true
                    isDisplayingRequestSent.toggle()
                }
            }
        }
        .toast(
            isPresenting: $isDisplayingRequestSent,
            duration: 2,
            tapToDismiss: true,
            alert: {
                AlertToast(type: .complete(.green), title: "Request Sent")
            }
        )
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
