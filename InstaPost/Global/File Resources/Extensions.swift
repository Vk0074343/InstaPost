//
//  Extensions.swift
//  InstaPost
//
//  Created by Vaibhav Khatri on 26/04/24.
//

import Foundation

extension String{
    func isBlank() -> Bool {
        if self.trimmingCharacters(in: .whitespaces).count == 0 {
            return true
        } else {
            return false
        }
    }
}
