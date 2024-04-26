//
//  LoginVC.swift
//  InstaPost
//
//  Created by Vaibhav Khatri on 24/04/24.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var textFieldPhoneNumber: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var textFieldVerificationCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFieldVerificationCode.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if isLoggedIn {
            let tabbarVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "TabbarVC") as! TabbarVC
            let navigationViewController = UINavigationController(rootViewController: tabbarVC)
            UIApplication.shared.windows.first?.rootViewController = navigationViewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    
    @IBAction func buttonLoginOrSignUpAction(_ sender: UIButton) {
        if let text = textFieldVerificationCode.text, !text.isEmpty{
            let code = text
            AuthManager.shared.verifyCode(smsCode: code) { [weak self] success in
                guard success else { return }
                DispatchQueue.main.async {
                    guard let VC =  UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "TabbarVC") as? TabbarVC else {
                        return
                    }
                    UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                    self?.navigationController?.pushViewController(VC, animated: true)
                }
            }
        } else {
            if self.textFieldPhoneNumber.text?.isEmpty ?? false{
                showDefaultAlertView(viewController: self, title: AppName, message: StringConstant.enter_phoneNuber)
            } else if (textFieldVerificationCode.text?.isEmpty ?? false){
                showDefaultAlertView(viewController: self, title: AppName, message: StringConstant.enter_valid_otp)
            }
        }
    }
}

//MARK: - TextField Delegate
extension LoginVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textFieldPhoneNumber{
            textField.resignFirstResponder()
            
            if let text = textField.text, !text.isEmpty{
                let number = "+91\(text)"
                AuthManager.shared.startAuth(phoneNumber: number) { [weak self] success in
                    guard success else { return }
                    DispatchQueue.main.async {
                        self?.textFieldVerificationCode.isHidden = false
                        self?.textFieldPhoneNumber.isUserInteractionEnabled = false
                        self?.buttonLogin.setTitle(StringConstant.Submit, for: .normal)
                    }
                }
            } else {
                showDefaultAlertView(viewController: self, title: AppName, message: StringConstant.enter_phoneNuber)
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.textFieldPhoneNumber{
            let maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString

            self.textFieldVerificationCode.isHidden = true
            return newString.length <= maxLength
        }
        return true
    }
    
}
