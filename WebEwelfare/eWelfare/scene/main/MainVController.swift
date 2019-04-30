//
//  MainVController.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit
import WebKit
import SideMenu

class MainVController: BaseVController {

    @IBOutlet weak var ivTitle: UIImageView!
    @IBOutlet weak var lbTitleText: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var vLeftButtons: UIView!
    @IBOutlet weak var rightButtons: UIView!
    
    private var presenter: MainPresenter!
    
    private var wkWebView: WKWebView!
    private var newWkWebView: WKWebView?
    
    private let imageLoadingPopup = ImageLoadingPopup().create()
    
    var tid: String?
    
    override func loadView() {
        super.loadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadHome), name: Notification.Name("loadHome"), object: nil)
        
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
        
        // fcm
        FcmHelper.instance.fcmTopic()
        
        initView()
        
        presenter = MainPresenter(view: self, model: MainModel())
    }
    
    private func initView() {
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuWidth = UIScreen.main.bounds.width * 0.8
    }
    
    @IBAction func onActionBack(_ sender: Any) {
        if wkWebView.canGoBack {
            wkWebView.goBack()
        }
    }
    
    @IBAction func onActionHome(_ sender: Any) {
        presenter.loadHome()
    }
    
    @IBAction func onActionMenu(_ sender: Any) {
        presenter.loadSetting()
    }
    
    @IBAction func onActionSearch(_ sender: Any) {
        presenter.loadSearch()
    }
    
    @objc func loadHome(noti: NSNotification) {
        presenter.loadHome()
    }
    
    private func getWebViewConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        contentController.add(self, name:"sendLoginAction")
        contentController.add(self, name:"aspGet")
        contentController.add(self, name:"aspPost")
        contentController.add(self, name:"checkMainPage")
        contentController.add(self, name:"showLoading")
        contentController.add(self, name:"tokenError")
        config.userContentController = contentController
        
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
    
    private func parseStringComponents(_ param: String) -> [String: String] {
        var dict: [String: String] = [:]
        
        if !param.isEmpty {
            for item: String in param.components(separatedBy: "&") {
                let parsedParam = item.components(separatedBy: "=")
                dict[parsedParam[0]] = parsedParam[1]
            }
        }
        
        return dict
    }
    
    private func makePostData(text: String?) -> String {
        var postData = ""
        
        if let jsonDic = convertToDictionary(text: text) {
            for data in jsonDic {
                if postData.count > 0 {
                    postData += "&"
                }
                
                if let value = data.value as? String {
                    postData += String(format: "%@=%@", data.key, value)
                }
                else if let value = data.value as? Int {
                    postData += String(format: "%@=%d", data.key, value)
                }
            }
        }
        
        return postData
    }
    
    private func convertToDictionary(text: String?) -> [String: AnyObject]? {
        if text == nil {
            return nil
        }
        
        if let data = text!.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch {
                // Handle Error
            }
        }
        return nil
    }

}


extension MainVController: WKUIDelegate {
    
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


extension MainVController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("Main - createWebViewWith")
        
        newWkWebView = WKWebView(frame: webView.frame, configuration: configuration)
        newWkWebView!.scrollView.bounces = self.wkWebView.scrollView.bounces
        newWkWebView!.uiDelegate = self.wkWebView.uiDelegate
        newWkWebView!.navigationDelegate = self.wkWebView.navigationDelegate
        containerView.addSubview(newWkWebView!)
        return newWkWebView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        print("Main - webViewDidClose")
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
        
        if let urlStr = navigationAction.request.url?.absoluteString {
            print("Main 요청된 URL ==> \(urlStr)")
        }
        
        // iOS10 신한, 삼성, NH 등 앱카드 관련 ///////////////////
        let device = UIDevice.current
        var backgroundSupported = false
        
        if device.responds(to: #selector(getter: UIDevice.isMultitaskingSupported)){
            backgroundSupported = device.isMultitaskingSupported
        }
        NSLog("backgroundSupported ==>%@", backgroundSupported ? "YES" : "NO")
        
        if !backgroundSupported {
            let alertController = UIAlertController(title: "e단비", message: "멀티테스킹을 지원하는 기기 또는 어플만 공인인증서비스가 가능합니다.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            }))
            
            decisionHandler(.allow)
            return
        }
        
        if let urlStr = navigationAction.request.url?.absoluteString {
            // print("요청된 URL ==> \(urlStr)")
            
            if urlStr.hasPrefix("ispmobile://") {  // 모바일ISP 호출 처리
                NSLog("ispmobile ");
                
                // ispmobile://?TID=SMTPAY001m01011708181134147103
                // tid 저장
                tid = urlStr.components(separatedBy: "TID=")[1]
                
                if let ispMobileAppURL = URL(string: urlStr) {
                    UIApplication.shared.open(ispMobileAppURL, options: [:]) { isSuccess in
                        if !isSuccess {
                            if let ispMobileAppDownloadURL = URL(string: "http://itunes.apple.com/kr/app/id369125087?mt=8") {
                                UIApplication.shared.open(ispMobileAppDownloadURL, options: [:], completionHandler: nil)
                            }
                        }
                    }
                }
                decisionHandler(.cancel)
                return
            }
                // else if urlStr.hasPrefix("bankpay://") {  // 금결원 APP 호출 처리
            else if urlStr.hasPrefix("kftc-bankpay://") {  // 금결원 APP 호출 처리
                //    kftc-bankpay://eftpay?callbackfunc=http://203.81.9.4:1880/RequestBankpay.do&approve_no=21900260&serial_no=0000000&amount=1004&hd_ep_type=SECUCERT&firm_name=(%EC%A3%BC)%EC%8A%A4%EB%A7%88%ED%8A%B8%EB%A1%9C&receipt_yn=N&user_key=SMTPAY001m02011708251359568455&title=&sbp_service_use=Y&sbp_tab_first=Y&fixed_bank_code=&callbackparam1=380902&returnURL=&method=POST&
                
                if let kftcMobileAppURL = URL(string: urlStr) {
                    UIApplication.shared.open(kftcMobileAppURL, options: [:]) { isSuccess in
                        if !isSuccess {
                            if let kftcMobileAppDownloadURL = URL(string: "http://itunes.apple.com/kr/app/id398456030?mt=8") {
                                UIApplication.shared.open(kftcMobileAppDownloadURL, options: [:], completionHandler: nil)
                            }
                        }
                    }
                }
                decisionHandler(.cancel)
                return
            }
            else if urlStr.range(of: "itunes.apple.com") != nil || urlStr.range(of: "phobos.apple.com") != nil {
                if self.openUrl(urlStr) {
                    decisionHandler(.cancel)
                    return
                }
            }
            else if !urlStr.hasPrefix("http://") && !urlStr.hasPrefix("https://") && !urlStr.hasPrefix("about:") {
                if self.openUrl(urlStr) {
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
}


extension MainVController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("[[ JavaScript ]] name : \(message.name), body : \(message.body)")
        
        if message.name == "sendLoginAction" {
            AccountManager.instance.token = message.body as? String
            AppManager.instance.requestFcmToken()
        }
        else if message.name == "aspGet" {
            if let body = message.body as? String {
                let params = parseStringComponents(body)
                if let title = params["title"], let url = params["url"] {
                    let vc = storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
                    vc.shopUrl = url
                    vc.titleText = title
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else if message.name == "aspPost" {
            if let body = message.body as? String {
                let params = parseStringComponents(body)
                if let title = params["title"], let url = params["url"], let json = params["data"] {
                    let vc = storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
                    vc.shopUrl = url
                    vc.titleText = title
                    vc.postParams = makePostData(text: json)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else if message.name == "checkMainPage" {
            if let body = message.body as? String, !body.isEmpty {
                vLeftButtons.isHidden = true
                lbTitleText.text = nil
                ivTitle.isHidden = false
                ivTitle.sd_setImage(with: URL(string: body)) { image, error, cacheType, imageURL in
                }
            }
            else {
                vLeftButtons.isHidden = false
                lbTitleText.text = wkWebView.title
                ivTitle.isHidden = true
            }
            // print("wkWebView.title : \(wkWebView.title)")
        }
        else if message.name == "showLoading" {
            if let body = message.body as? String, body == "open" {
                imageLoadingPopup.show()
            }
            else {
                imageLoadingPopup.hide()
            }
        }
        else if message.name == "tokenError" {
            self.alertPopup(message: "로그인 세션이 종료되어 로그인 화면으로 이동됩니다.") {
                self.goLogin()
            }
        }
    }
    
}


extension MainVController: UIScrollViewDelegate {
    
    // disable zooming in webview
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
}
