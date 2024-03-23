//
//  SelectBirthdayView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/13/24.
//

import SwiftUI

struct SelectBirthdayView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Binding var birthday: Date
    @Binding var path: [SignUpPath]
    var onDismiss: (() -> Void)?
    
    var body: some View {
        birthdayView
    }
    
    private var birthdayView: some View {
        VStack(spacing: 0) {
            DatePicker(
                "",
                selection: $birthday,
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.wheel)
            Spacer()
            continueBirthdayButton
        }
        .padding()
        .navigationTitle("Select your Birthday")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isDismissable {
                    dismissButton
                }
            }
        }
        .interactiveDismissDisabled()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var continueBirthdayButton: some View {
        NavigationLink(value: SignUpPath.birthday) {
            Button {
                path.append(.role)
            } label: {
                Text("Continue")
                    .fontWeight(.bold)
                    .padding(.vertical, 6)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var dismissButton: some View {
        Button {
            onDismiss?() ?? dismiss()
        } label: {
            Image(systemName: "x.circle.fill")
        }
        .foregroundStyle(.white)
    }
    
    private var isDismissable: Bool {
        onDismiss != nil
    }
}
