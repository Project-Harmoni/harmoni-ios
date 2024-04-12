//
//  SettingsView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/23/24.
//

import MessageUI
import SwiftUI

struct SettingsView: View {
    @Environment(\.isAdmin) private var isAdmin
    @Environment(\.currentUser) private var currentUser
    @AppStorage("isAdminRequested") var isAdminRequested: Bool = false
    @State private var isDisplayingAdminRequest: Bool = false
    
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
                } else if !isAdmin, MFMailComposeViewController.canSendMail() {
                    Button {
                        isDisplayingAdminRequest.toggle()
                    } label: {
                        Text("Request to be Admin")
                    }
                }
            }
        }
        .sheet(isPresented: $isDisplayingAdminRequest) {
            SendMailView(
                content: "Harmoni,\n\n\(currentUser?.email ?? "email") is requesting to be an admin.",
                to: "teamharmonirequests@gmail.com",
                subject: "Admin Request") {
                    isAdminRequested = true
                }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
