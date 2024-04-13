//
//  WelcomeView.swift
//  harmoni
//
//  Created by Sarah Matthews on 4/11/24.
//
//  Defines the welcome message for new users.
//  Users should only ever see this view once.

import SwiftUI

struct WelcomeView: View {
    @Environment(\.isArtist) private var isArtist
    @Environment(\.isAdmin) private var isAdmin
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = WelcomeViewModel()
    
    var body: some View {
        VStack {
            
            if isArtist {
                artistView
            } else {
                listenerView
            }
            
            Spacer()
            
            Button {
                viewModel.toggleIsNewOff {
                    dismiss()
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Got it!")
                        .padding(.vertical, 8)
                        .bold()
                        .font(.title3)
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .presentationDetents([.fraction(0.70)])
        .presentationBackground(.ultraThinMaterial)
        .presentationDragIndicator(.visible)
        .padding()
        .padding(.top, 32)
        .multilineTextAlignment(.leading)
        .onDisappear {
            viewModel.toggleIsNewOff {}
        }
    }
    
    private var artistView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("**Welcome to Harmoni!** We're so excited to support your artistic journey.")
            Text("Here's how it works: you share your music, listeners stream it, and you get paid automatically. No delay, no fuss.")
            Text("If you want, you can share a portion of each payout with your listeners. You can change this for any track, at any time.")
            Text("To help you get started, you'll be paid double for your first 10,000 streams. We're cheering you on!")
        }
        .padding(.horizontal, 24)
    }
    
    private var listenerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("**Welcome to Harmoni!**")
            Text("Here's how it works: every time you stream a track, you pay a tiny amount of Harmoney. Nearly 100% of this will go to the artist.")
            Text("Some artists share a fraction of their payouts with their listeners (you) as a thank-you.")
            Text("As a gift, your first 25 streams are free. Totally on us! If you like what you hear, you can buy more tokens at any time.")
            Text("Thanks for joining. We hope you have a blast!")
        }
        .padding(.horizontal, 24)
    }
    
}

#Preview {
    WelcomeView()
}
