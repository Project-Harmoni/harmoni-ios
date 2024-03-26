//
//  EditPayoutView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/18/24.
//

import SwiftUI

struct EditPayoutView: View {
    @EnvironmentObject private var uploadStore: UploadStore
    @Environment(\.editMode) private var editMode
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: EditPayoutViewModel
    
    var body: some View {
        editPayoutContainer
            .navigationTitle("Payout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    configureMenu
                    selectionToggle
                }
            }
            .alert("Edit Streams", isPresented: $viewModel.isShowingEditStreamAlert) {
                TextField("Number of streams", text: $viewModel.streamThreshold)
                    .keyboardType(.numberPad)
                Button("Save", role: .none) {
                    viewModel.editStreamsUntilPayout()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter the number of streams it takes for a payout to occur.")
            }
            .alert("Edit Artist Percentage", isPresented: $viewModel.isShowingEditPercentageAlert) {
                TextField("Artist percentage of payout", text: $viewModel.artistPercentage)
                    .keyboardType(.numberPad)
                Button("Save", role: .none) {
                    viewModel.editArtistPercentage()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter the percentage of payout that goes to you, the artist.")
            }
            .onChange(of: viewModel.tracks) { _, tracks in
                uploadStore.tracks = tracks
            }
    }
    
    @ViewBuilder
    private var editPayoutContainer: some View {
        if viewModel.tracks.isEmpty {
            Text("**No tracks!** Come back when you've added some.")
                .padding(.horizontal)
                .multilineTextAlignment(.center)
        } else {
            List(selection: $viewModel.selectedTracks) {
                ForEach($viewModel.tracks) { track in
                    EditTrackPayoutView(
                        track: track
                    )
                }
                cta
            }
        }
    }
    
    @ViewBuilder
    private var configureMenu: some View {
        if isSelected {
            Menu {
                Button {
                    viewModel.isShowingEditStreamAlert.toggle()
                } label: {
                    Text("Streams until Payout")
                    Image(systemName: "music.quarternote.3")
                }
                
                Button {
                    viewModel.isShowingEditPercentageAlert.toggle()
                } label: {
                    Text("Artist Percentage")
                    Image(systemName: "percent")
                }
                Button {
                    viewModel.editFreeToStream()
                } label: {
                    Text("Make Free to Stream")
                }
                
                Button {
                    viewModel.editPaidToStream()
                } label: {
                    Text("Make Paid to Stream")
                }
                
                Button {
                    viewModel.editProportionalPayout()
                } label: {
                    Text("Set Proportional Payout")
                }
                Button {
                    viewModel.editJackpotPayout()
                } label: {
                    Text("Set Jackpot Payout")
                }
            } label: {
                Text("Configure Selected")
                    .padding()
                    .frame(height: 32)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .bold()
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .menuOrder(.fixed)
        }
    }
    
    @ViewBuilder
    private var selectionToggle: some View {
        if isEditing {
            Spacer()
            Button(viewModel.isSelectingAll ? "Select All" : "Deselect All") {
                if viewModel.isSelectingAll {
                    viewModel.tracks.forEach { track in
                        viewModel.selectedTracks.insert(track.id)
                    }
                } else {
                    viewModel.tracks.forEach { track in
                        viewModel.selectedTracks.remove(track.id)
                    }
                }
                
                viewModel.isSelectingAll.toggle()
            }
            .bold()
            .onAppear() {
                viewModel.isSelectingAll = true
            }
        }
    }
    
    @ViewBuilder
    private var cta: some View {
        if viewModel.isEditing {
            Button {
                //
            } label: {
                Text("Save")
            }
            .buttonStyle(.borderedProminent)
        } else {
            Section {
                NavigationLink("Continue") {
                    ConfirmUploadView()
                        .environmentObject(uploadStore)
                }
                .foregroundStyle(.white)
            }
            .listRowBackground(
                Rectangle()
                    .foregroundStyle(.blue)
            )
        }
    }
    
    private var isEditing: Bool {
        guard let editMode = editMode?.wrappedValue else { return false }
        return editMode.isEditing
    }
    
    private var isSelected: Bool {
        isEditing && !viewModel.selectedTracks.isEmpty
    }
}

#Preview {
    EditPayoutView(
        viewModel: EditPayoutViewModel(
            tracks: [
                Track(
                    url: URL(string: "www.apple.com")!,
                    name: "Test",
                    fileExtension: ".mp3"
                ),
                Track(
                    url: URL(string: "www.apple.com")!,
                    name: "Test2",
                    fileExtension: ".mp3"
                ),
                Track(
                    url: URL(string: "www.apple.com")!,
                    name: "Test3",
                    fileExtension: ".mp3"
                ),
                Track(
                    url: URL(string: "www.apple.com")!,
                    name: "Test4",
                    fileExtension: ".mp3"
                )
            ]
        )
    )
}
