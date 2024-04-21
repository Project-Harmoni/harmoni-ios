//
//  EditTrackPayoutView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/20/24.
//

import SwiftUI

// TODO: - Clean-up with view model

struct EditTrackPayoutView: View {
    @Environment(\.platformConstants) private var platformConstants
    @Environment(\.colorScheme) var colorScheme
    @Binding var track: Track
    @State var isReadOnly: Bool = false
    @State private var isShowingEditStreamAlert: Bool = false
    @State private var numberOfStreams: Int = 1000
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(track.name).bold()
                    Spacer()
                    menu
                }
            }
            editTrackContent
        }
        .frame(height: height)
        .padding(.vertical, 8)
        .listRowBackground(Color(.secondarySystemGroupedBackground))
        .alert("Edit Streams", isPresented: $isShowingEditStreamAlert) {
            TextField("Number of streams", text: $numberOfStreams.toString)
                .keyboardType(.numberPad)
            Button("Save", role: .none) {
                saveNumberOfStreams()
            }
            Button("Cancel", role: .cancel) {
                track.numberOfStreamsAlert = track.streamThreshold
            }
        } message: {
            Text("Enter the number of streams it takes for a payout to occur. \(minimum) is the minimum.")
        }
        .onAppear() {
            track.numberOfStreamsAlert = track.streamThreshold
            numberOfStreams = track.streamThreshold
        }
        .onChange(of: track.numberOfStreamsAlert) {
            numberOfStreams = track.numberOfStreamsAlert
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
                footer
            }
        }
    }
    
    @ViewBuilder
    private var footer: some View {
        if isReadOnly {
            streamPerPayoutReadonly
        } else {
            streamThresholdView
        }
    }
    
    @ViewBuilder
    private var menu: some View {
        if !isReadOnly {
            Menu {
                Button {
                    track.isFreeToStream.toggle()
                } label: {
                    Text(
                        isFreeToStream
                        ? "Make Pay to Stream"
                        : "Make Free to Stream"
                    )
                }
                Button {
                    track.payoutType = .proportional
                } label: {
                    Text("Proportional Payout")
                    if track.payoutType == .proportional {
                        Image(systemName: "checkmark")
                    }
                }
                Button {
                    track.payoutType = .jackpot
                } label: {
                    Text("Jackpot Payout")
                    if track.payoutType == .jackpot {
                        Image(systemName: "checkmark")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    private var streamThresholdView: some View {
        HStack {
            Spacer()
            Button {
                isShowingEditStreamAlert.toggle()
            } label: {
                streamsPerPayoutLabel
            }
            .buttonStyle(.bordered)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .tint(.primary)
            Spacer()
        }
        .padding(.bottom, 2)
    }
    
    private var streamsPerPayoutLabel: some View {
        Text("\(track.streamThreshold)")
            .font(.caption)
            .bold()
        + Text(" streams / payout")
            .font(.caption2)
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
                if !isReadOnly {
                    Slider(value: $track.artistPercentage, in: 0.0...100.0, step: 1)
                        .tint(.clear)
                        .padding(0)
                        .frame(height: 20)
                }
            }
        }
    }
    
    private var minimum: Int {
        platformConstants.minimumPaymentThreshold
    }
    
    private var artistBarWidth: CGFloat {
        track.artistPercentage / 100
    }
    
    private var listenerBarWidth: CGFloat {
        1 - artistBarWidth
    }
    
    private var artistPercentage: Int {
        Int(track.artistPercentage)
    }
    
    private var listenerPercentage: Int {
        Int((100 - track.artistPercentage))
    }
    
    private var isFreeToStream: Bool {
        track.isFreeToStream
    }
    
    private var height: CGFloat {
        if isFreeToStream {
            64
        } else if isReadOnly {
            100
        } else {
            125
        }
    }
    
    private func saveNumberOfStreams() {
        if numberOfStreams < minimum {
            numberOfStreams = minimum
        }
        let currentStreamThreshold = track.streamThreshold
        track.streamThreshold = numberOfStreams
        track.numberOfStreamsAlert = numberOfStreams
        track.isPayoutRequired = numberOfStreams < currentStreamThreshold
    }
}

// MARK: - Extension Read-Only

private extension EditTrackPayoutView {
    var streamPerPayoutReadonly: some View {
        Text("**\(track.streamThreshold)**")
            .font(.footnote)
        + Text(" streams / **\(track.payoutType.rawValue)** payout")
            .font(.footnote)
    }
}

#Preview {
    EditTrackPayoutView(
        track: .constant(Track(url: URL(string: "www.apple.com")!, name: "Test", fileExtension: ".mp3"))
    )
}
