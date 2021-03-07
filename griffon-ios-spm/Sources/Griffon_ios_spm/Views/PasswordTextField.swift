//
//  PasswordTextField.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 14.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import UIKit

public class PasswordTextField: UITextField {
    
    var isSecure: Bool = true
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addRightButton(img: UIImage(named: "show_password")!)
        self.isSecureTextEntry = isSecure
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addRightButton(img: UIImage(named: "show_password")!)
        self.isSecureTextEntry = isSecure
    }
 
    private func addRightButton(img: UIImage) {
         let button = UIButton(type: .custom)
         button.setImage(img, for: .normal)
         button.imageView?.contentMode = .scaleAspectFit
         button.imageEdgeInsets = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
         button.addTarget(self, action: #selector(self.changePasswordTFSecurity), for: .touchUpInside)
         self.rightView = button
         self.rightViewMode = .always
     }
     
     @IBAction func changePasswordTFSecurity(_ sender: Any) {
         let securityButton: UIButton = sender as! UIButton
         let imageName = (self.isSecureTextEntry) ? ("hide_password") : ("show_password")
         securityButton.setImage(UIImage(named: imageName), for: .normal)
         self.isSecure = !self.isSecure
         self.isSecureTextEntry = self.isSecure
     }
}
