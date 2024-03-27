//
//  String+Extension.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/10/24.
//

import Foundation

extension String {
    // https://github.com/jason-dubon/SupabaseSwift/blob/main/SupabaseAuth/SignIn/SignInViewModel.swift
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    var toJPG: String {
        self + ".jpg"
    }
}
