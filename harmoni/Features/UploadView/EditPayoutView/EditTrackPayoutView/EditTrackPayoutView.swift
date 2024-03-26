//
//  EditTrackPayoutView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/20/24.
//

import SwiftUI

struct EditTrackPayoutView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var track: Track
    @State var isReadOnly: Bool = false
    @State private var isShowingEditStreamAlert: Bool = false
    
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
            TextField("Number of streams", text: $track.streamThreshold.toString)
                .keyboardType(.numberPad)
            Button("Save", role: .none) {}
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
                footer
            }
        }
    }
    
    @ViewBuilder
    private var footer: some View {
        if isReadOnly {
            streamPerPayoutReadonly
        } else {
            streamThreshold
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
    
    private var streamThreshold: some View {
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
