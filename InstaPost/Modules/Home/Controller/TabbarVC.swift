//
//  TabbarVC.swift
//  InstaPost
//
//  Created by Vaibhav Khatri on 25/04/24.
//

import UIKit

class TabbarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = AppName
    }
    
}
