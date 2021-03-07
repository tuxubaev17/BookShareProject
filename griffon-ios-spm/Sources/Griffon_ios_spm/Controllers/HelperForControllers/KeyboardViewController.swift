//
//  KeyboardViewController.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 08.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import UIKit

public class KeyboardViewController: UIViewController {

    var hideKeyboardOnClick = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if hideKeyboardOnClick {
            let tapRecognizer = UITapGestureRecognizer()
            tapRecognizer.delegate = self
            tapRecognizer.cancelsTouchesInView = false
            tapRecognizer.addTarget(self, action: #selector(self.didTapView))
            self.view.addGestureRecognizer(tapRecognizer)
        }
        
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboardNotifications()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterFromKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        fatalError("method must be overridden")
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        fatalError("method must be overridden")
    }
    
    @objc func didTapView(){
        self.view.endEditing(true)
    }
    
}

extension KeyboardViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let isControllTapped = touch.view is UIControl
        return !isControllTapped
    }
}
