//
//  AuthManager.swift
//  InstaPost
//
//  Created by Vaibhav Khatri on 24/04/24.
//

import FirebaseAuth
import Foundation

class AuthManager{
    static let shared = AuthManager()
    
    private let auth = Auth.auth()
    private var verificationId: String?
    
    public func startAuth(phoneNumber: String, completion: @escaping (Bool) -> Void){
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationId, error in
            guard let verificationId = verificationId, error == nil else{
                return
            }
            self?.verificationId = verificationId
            completion(true)
        }
    }
    
    public func verifyCode(smsCode: String, completion: @escaping (Bool) -> Void){
        guard let verificationId = self.verificationId else {
            completion(false)
            return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
        auth.signIn(with: credential) { result, error in
            if error != nil {
                print("Error In Verification: \(error)")
                completion(false)
                return
            }
            guard result != nil else{
                completion(false)
                return
            }
            completion(true)
        }
        
    }
}
