//
//  WebViewController.swift
//  griffon-sdk
//
//  Created by Farabi Bimbetov on 10.09.2020.
//  Copyright © 2020 Dar. All rights reserved.
//

import UIKit
import WebKit

protocol WebViewThirdPClientDelegate {
    func successAuthorize(state: String, code: String)
    func failureAuthorize()
}

class WebViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var url: URL?
    var thirdPClientDelegate: WebViewThirdPClientDelegate?
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = self.url else { return }
        let urlRequest = URLRequest(url: url) 
        webView.load(urlRequest)
        webView.allowsBackForwardNavigationGestures = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WebViewController: UIWebViewDelegate {
   
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?

        defer {
            decisionHandler(action ?? .allow)
        }
        guard let url = navigationAction.request.url else { return }
        if url.absoluteString.hasPrefix("https://griffon.dar-dev.zone/connect") {
            action = .cancel
            self.webView.stopLoading()
            let urlParams = url.params()
            if let state = urlParams["state"] as? String, let code = urlParams["code"] as? String {
                thirdPClientDelegate?.successAuthorize(state: state, code: code)
            } else {
                thirdPClientDelegate?.failureAuthorize()
            }            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

