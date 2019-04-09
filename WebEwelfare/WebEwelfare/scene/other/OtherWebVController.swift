//
//  OtherWebVController.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit
import WebKit

class OtherWebVController: BaseVController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    private var wkWebView: WKWebView!
    private var newWkWebView: WKWebView?

    var shopUrl: String!
    var titleText: String?
    
    override func loadView() {
        super.loadView()
        
        wkWebView = WKWebView(frame: containerView.frame, configuration: getWebViewConfiguration())
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.scrollView.delegate = self
        
        containerView.addSubview(wkWebView)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: wkWebView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wkWebView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wkWebView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wkWebView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        loadUrl(urlPath: shopUrl)
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        if wkWebView.canGoBack {
            wkWebView.goBack()
        }
    }
    
    @IBAction func onClickClose(_ sender: UIButton) {
        let alertController = UIAlertController(title: "e복지", message: "e복지 페이지로 돌아가시겠습니까?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
        }))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            self.dismiss(animated: false, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func initView() {
        if titleText != nil {
            lbTitle.text = titleText!
        }
    }
    
    private func getWebViewConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
//        let userScript = WKUserScript(
//            source: "sendLoginAction()",
//            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
//            forMainFrameOnly: true
//        )
//        contentController.addUserScript(userScript)
//        contentController.add(self, name:"sendLoginAction")
//        config.userContentController = contentController
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.javaScriptEnabled = true
        config.preferences = preferences
        
        return config
    }
    
    func loadUrl(urlPath: String) {
        guard let url = URL(string: urlPath) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("iOS", forHTTPHeaderField: "platform")
        request.addValue(AppManager.instance.bundleIdentifier!, forHTTPHeaderField: "package")
        request.addValue(AppManager.instance.appVersion!, forHTTPHeaderField: "version")
        if let token = AccountManager.instance.token {
            request.addValue(token, forHTTPHeaderField: "token-ewelfare")
        }
        
//        var cookies = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies(for: request.url!)!)
//        if let value = cookies["Cookie"] {
//            request.addValue(value, forHTTPHeaderField: "Cookie")
//        }
        
        wkWebView.load(request)
    }

}


extension OtherWebVController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "e복지", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "e복지", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "e복지", message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            }
            else {
                completionHandler(defaultText)
            }
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}


extension OtherWebVController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        newWkWebView = WKWebView(frame: webView.frame, configuration: configuration)
        newWkWebView!.scrollView.bounces = self.wkWebView.scrollView.bounces
        newWkWebView!.uiDelegate = self.wkWebView.uiDelegate
        newWkWebView!.navigationDelegate = self.wkWebView.navigationDelegate
        containerView.addSubview(newWkWebView!)
        return newWkWebView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == newWkWebView! {
            newWkWebView!.removeFromSuperview()
            newWkWebView = nil
        }
    }
    
    // 중복적으로 리로드 방지
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        // iOS10 신한, 삼성, NH 등 앱카드 관련 ///////////////////
        let device = UIDevice.current
        var backgroundSupported = false
        
        if device.responds(to: #selector(getter: UIDevice.isMultitaskingSupported)){
            backgroundSupported = device.isMultitaskingSupported
        }
        NSLog("backgroundSupported ==>%@", backgroundSupported ? "YES" : "NO")
        
        if !backgroundSupported {
            let alertController = UIAlertController(title: "e복지", message: "멀티테스킹을 지원하는 기기 또는 어플만 공인인증서비스가 가능합니다.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            }))
            
            decisionHandler(.allow)
            return
        }
        
        /*
        // 스마트 신한앱 다운로드 url
        let sh_url = "http://itunes.apple.com/us/app/id360681882?mt=8" //신한Mobile앱 결제 다운로드 url
        let sh_url2 = "https://itunes.apple.com/kr/app/sinhan-mobilegyeolje/id572462317?mt=8"
         
        // 현대 다운로드 url
        let hd_url = "http://itunes.apple.com/kr/app/id362811160?mt=8"
         
        // 스마트 신한 url 스키마
        let sh_appname = "smshinhanansimclick" //스마트 신한앱 url 스키마
        let sh_appname2 = "shinhan-sr-ansimclick"
         
        // 현대카드 url
        let hd_appname = "smhyundaiansimclick" //현대카드 url
        let hd_vbv = "ansimclick.hyundaicard.com"
        */
        
        if let urlStr = navigationAction.request.url?.absoluteString {
            print("요청된 URL ==> \(urlStr)")
            
            let nsStringUrlStr = urlStr as NSString

            if Int(nsStringUrlStr.range(of: "ansimclick.hyundaicard.com").location ) != NSNotFound {
                decisionHandler(.allow)
                return
            }
            else {
                if Int(nsStringUrlStr.range(of: "http://itunes.apple.com").location) != NSNotFound {
                    print("1. 앱설치 url 입니다. ==>%@",urlStr)
                    UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    
                    if newWkWebView != nil {
                        webViewDidClose(newWkWebView!)
                    }
                    return
                }
            }

            if Int(nsStringUrlStr.range(of: "ansimclick").location ) != NSNotFound {
                print("2. 앱설치 url 입니다. ==>%@",urlStr)
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }

            if Int(nsStringUrlStr.range(of: "appfree").location ) != NSNotFound {
                print("3. 앱설치 url 입니다. ==>%@",urlStr)
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
}


extension OtherWebVController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    }
    
}


extension OtherWebVController: UIScrollViewDelegate {
    
    // disable zooming in webview
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
}
