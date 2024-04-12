//
//  WelcomeView.swift
//  harmoni
//
//  Created by Sarah Matthews on 4/11/24.
//
//  Defines the welcome message for new users.
//  Users should only ever see this view once.

import SwiftUI

struct WelcomeArtistView: View {
    var body: some View {
        VStack {
            Text("Welcome to Harmoni! We're so excited to support your artistic journey.")
            Text("")
            Text("Here's how it works: you tag and upload your awesome soundtracks, listeners pay Harmoney to listen, and every time a track's streams reach a threshold that you choose, you get paid automatically. No delay, no fuss, and nearly 100% of streaming fees go to you.")
            Text("")
            Text("If you want, you can share a portion of each payout with your listeners, either proportionally or randomized in a jackpot. You can also choose to make some of your soundtracks free to stream. You can reconfigure all of these payout options for any track, at any time")
            Text("")
            Text("To help you get started, you'll be paid double for your first 10,000 streams. We're cheering you on!")
        }
        .padding()
        .multilineTextAlignment(.leading)
    }
}

struct WelcomeListenerView: View {
    var body: some View {
        VStack {
            Text("Welcome to Harmoni!")
            Text("")
            Text("Here's how it works: every time you stream a track, you pay a tiny amount of Harmoney. Nearly 100% of this will go to the artist.")
            Text("")
            Text("Every time an artist's track reaches their chosen threshold, they get paid. Some artists share a fraction of their payouts with their listeners (you) as a thank-you.")
            Text("")
            Text("As a gift, your first 25 streams are free. Totally on us! If you like what you hear, you can purchase additional tokens at any time to stream more.")
            Text("")
            Text("Thanks for joining. We hope you have a blast!")
        }
        .padding()
        .multilineTextAlignment(.leading)
    }
}

struct WelcomeView: View {
    @Environment(\.isArtist) private var isArtist
    @Environment(\.isAdmin) private var isAdmin
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = WelcomeViewModel()
    
    var body: some View {
        if isArtist {
            WelcomeArtistView()
        } else {
            WelcomeListenerView()
        }
        
        Button("Got it!") {
            viewModel.toggleIsNewOff()
            dismiss()
        }.buttonStyle(.borderedProminent)
    }
    
}

#Preview {
    WelcomeView()
}
