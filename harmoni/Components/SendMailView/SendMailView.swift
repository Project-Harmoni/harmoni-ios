//
//  SendMailView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/11/24.
//  Referenced: https://github.com/egesucu/SendMailApp/blob/main/SendMailApp/Views/MailView.swift

import MessageUI
import SwiftUI

struct SendMailView : UIViewControllerRepresentable {
    var content: String
    var to: String
    var subject: String
    var onCompletion: (() -> Void)?
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        if MFMailComposeViewController.canSendMail() {
            let view = MFMailComposeViewController()
            view.mailComposeDelegate = context.coordinator
            view.setToRecipients([to])
            view.setSubject(subject)
            view.setMessageBody(content, isHTML: false)
            return view
        } else {
            return MFMailComposeViewController()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator : NSObject, MFMailComposeViewControllerDelegate {
        var parent : SendMailView
        
        init(_ parent: SendMailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
            if result == .sent {
                parent.onCompletion?()
            }
        }
    }
}
