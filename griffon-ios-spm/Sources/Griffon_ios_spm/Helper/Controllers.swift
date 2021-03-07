//
//  Controllers.swift
//  OAuthSwift
//
//  Created by Farabi Bimbetov on 06.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    public func showAlert(title: String?, description: String?, completion:((UIAlertAction)->(Void))? = nil) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel, handler: completion)
        alert.addAction(okButton)
        
        self.present(alert, animated: true)
    }
}
