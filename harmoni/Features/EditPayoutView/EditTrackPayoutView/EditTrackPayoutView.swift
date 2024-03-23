//
//  EditTrackPayoutView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/20/24.
//

import SwiftUI

struct EditTrackPayoutView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: EditTrackPayoutViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(viewModel.track.name).bold()
                    Spacer()
                    menu
                }
            }
            editTrackContent
        }
        .frame(height: isFreeToStream ? 64 : 125)
        .padding(.vertical, 8)
        .listRowBackground(Color(.secondarySystemGroupedBackground))
        .alert("Edit Streams", isPresented: $viewModel.isShowingEditStreamAlert) {
            TextField("Number of streams", text: $viewModel.streamThreshold)
                .keyboardType(.numberPad)
            Button("Save", role: .none) {
                viewModel.track.streamThreshold = Int(viewModel.streamThreshold) ?? 1000
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the number of streams it takes for a payout to occur.")
        }
    }
    
    @ViewBuilder
    private var editTrackContent: some View {
        if isFreeToStream {
            VStack {
                Text("Free to Stream")
                    .font(.caption)
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                Spacer()
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                youListenerCopy
                slider
                streamThreshold
            }
        }
    }
    
    private var menu: some View {
        Menu {
            Button {
                viewModel.track.isFreeToStream.toggle()
            } label: {
                Text(
                    isFreeToStream
                    ? "Make Pay to Stream"
                    : "Make Free to Stream"
                )
            }
            Button {
                viewModel.track.payoutType = .proportional
            } label: {
                Text("Proportional Payout")
                if viewModel.track.payoutType == .proportional {
                    Image(systemName: "checkmark")
                }
            }
            Button {
                viewModel.track.payoutType = .jackpot
            } label: {
                Text("Jackpot Payout")
                if viewModel.track.payoutType == .jackpot {
                    Image(systemName: "checkmark")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    private var streamThreshold: some View {
        HStack {
            Spacer()
            Button {
                viewModel.isShowingEditStreamAlert.toggle()
            } label: {
                Text("\(viewModel.track.streamThreshold)")
                    .font(.caption)
                    .bold()
                + Text(" streams / payout")
                    .font(.caption2)
            }
            .buttonStyle(.bordered)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .tint(.primary)
            Spacer()
        }
        .padding(.bottom, 2)
    }
    
    private func capsule(for role: SignUpRole, in proxy: GeometryProxy) -> some View {
        let isArtist = role == .artist
        return Rectangle()
            .frame(
                width: proxy.size.width * (isArtist ? artistBarWidth : listenerBarWidth)
            )
            .frame(maxWidth: proxy.size.width * 0.99)
            .frame(height: 8)
            .foregroundStyle(isArtist ? .green : .blue)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: isArtist ? 8 : 0,
                    bottomLeadingRadius: isArtist ? 8 : 0,
                    bottomTrailingRadius: isArtist ? 0 : 8,
                    topTrailingRadius: isArtist ? 0 : 8
                )
            )
    }
    
    private var youListenerCopy: some View {
        HStack {
            Text("You: \(artistPercentage)%")
                .font(.caption2)
                .bold()
                .foregroundStyle(.green)
                .brightness(colorScheme == .dark ? 0 : -0.2)
            Spacer()
            Text("Listeners: \(listenerPercentage)%")
                .font(.caption2)
                .bold()
                .foregroundStyle(.blue)
        }
    }
    
    private var slider: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    capsule(for: .artist, in: proxy)
                    capsule(for: .listener, in: proxy)
                }
                Slider(value: $viewModel.track.artistPercentage, in: 0.0...100.0, step: 1)
                    .tint(.clear)
                    .padding(0)
                    .frame(height: 20)
            }
        }
    }
    
    private var artistBarWidth: CGFloat {
        viewModel.track.artistPercentage / 100
    }
    
    private var listenerBarWidth: CGFloat {
        1 - artistBarWidth
    }
    
    private var artistPercentage: Int {
        Int(viewModel.track.artistPercentage)
    }
    
    private var listenerPercentage: Int {
        Int((100 - viewModel.track.artistPercentage))
    }
    
    private var isFreeToStream: Bool {
        viewModel.track.isFreeToStream
    }
}

#Preview {
    EditTrackPayoutView(
        viewModel: EditTrackPayoutViewModel(
            track: Track(url: URL(string: "www.apple.com")!, name: "Test", fileExtension: ".mp3")
        )
    )
}
